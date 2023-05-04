#Important Notice (Please run as Admin)
#If you face errors while running this script check if ExecutionPolicy is set to "Restricted"
#Run Get-ExecutionPolicy
#If it outputs "Restricted" 
#Run Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser


#FuruteIterations
#Kashem's Automator V1.0.0 HotFix-1 {moderate Bug Fixes (Successor to V1.0.0)}
#Minor Reformatting of code {Will be included in V1.0.0 HotFix-2}
#CheckPreviousRunSession{Will be included in V1.1.0}
#CheckPreviousGenerationSession(checks if the command was actually run and the vm exists on host){Will be included in V1.1.1}
#ImageVerification{Will be included in V1.2.0}


#ListOfBugFixes(HotFix-1)
#Command generation fail due to $ not being escaped
#Variable having residual values from previous run if the shell session was not terminated since global values were not cleared (set to null)
#Minimum memory error when command was executed the minimum and startup bytes were reconfigured
#Units get added up by each pass of the session this is fixed
#Fixed storage path for both multiple and single creation wizards
#Fixed auto resetting memory variables

#ListOfMinorChanges(HotFix-1a)
#Minor Documentation correction
#Title Display Correction



#AdminPrivilageCheck
#Requires -RunAsAdministrator

#EnvironmentSetup
$host.UI.RawUI.WindowTitle = "Kashem's Automator V1.0.0 HotFix-1a"

#CheckHyper-VStatus
$chkhV = {
    Write-Warning "Checking Hyper-V Status"
    $hVStat = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V | Select-Object -ExpandProperty State
    Start-Sleep 1
    if ($hVStat -ne "enabled") {
        [System.Console]::Beep(400, 250)
        Write-Host "Error: Hyper-V is not Enabled on this System" -ForegroundColor Red
        Write-Host $null
        Write-Host "Do you want to enable Hyper-V Service?"
        $hvdsc = Read-Host -Prompt "[Y]es, [N]o. Default [N]o"
        if ($hvdsc -eq "y") {
            [System.Console]::Beep(1000, 100)
            Write-Warning "Enabling Hyper-V on this system"
            Start-Sleep 1
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
        }
        else {
            Clear-Host
            Write-Warning "Exiting"
            Start-Sleep 1
            [System.Console]::Beep(2000, 100)
            [System.Console]::Beep(500, 100)
            [System.Console]::Beep(2000, 100)
            [System.Console]::Beep(500, 100)
        }
    }
    elseif ($hVStat -eq "enabled") {
        [System.Console]::Beep(1000, 100)
        Write-Host "Hyper-V is enabled on this system" -ForegroundColor Green
        Start-Sleep 1
        Write-Host $null
    }
    else {
        [System.Console]::Beep(400, 250)
        [System.Console]::Beep(400, 250)
        [System.Console]::Beep(400, 250)
        Write-Host "Something went wrong" -ForegroundColor Red
    }
}

#VariableSetup

#ReturnExitDialogue
$Global:ds1 = {
    $ipn = Read-Host "Press [E] to exit [R] to return to main menu"
    if ($ipn -eq "r") {
        Clear-Host
        &$base
        &$selection
    }
    elseif ($ipn -eq "e") {
        Write-Host "Exiting"
        Start-Sleep 1
        [System.Console]::Beep(2000, 100)
        [System.Console]::Beep(500, 100)
        [System.Console]::Beep(2000, 100)
        [System.Console]::Beep(500, 100)
    }
    else {
        Write-Host "Try again"
        &$ds1
    }
}

#HomeScreen
$Global:base = {
    [System.Console]::Beep(250, 300)
    Write-Host "1. Show Existing VM's"
    Write-Host "2. Create a Single VM"
    Write-Host "3. Create Multiple VM's"
    Write-Host "4. Get VM information"
    Write-Host "5. Exit"
}

#ExistingVMInfo
$Global:sysvm = {
    $existing = Get-VM * | Select-Object Name,State,Status | Sort-Object -Property "Name"
    $existing | Format-Table -AutoSize 
}

#VersionInfo
$Global:psproc = {
    Clear-Host
    Write-Warning "This Script is running with Administrator privilages"
    $major = $PSVersionTable | Select-Object -ExpandProperty PSVersion | Select-Object -ExpandProperty Major
    $minor = $PSVersionTable | Select-Object -ExpandProperty PSVersion | Select-Object -ExpandProperty Minor
    $patch = $PSVersionTable | Select-Object -ExpandProperty PSVersion | Select-Object -ExpandProperty Patch
    Write-Host "Current PowerShell Version "-NoNewline 
    Write-Host " $major.$minor.$patch " -ForegroundColor Black -BackgroundColor Cyan
    Write-Host $null
    Start-Sleep 1
}

#VMDetailedView
$Global:gdtvmvue = {
    $existing = Get-VM * | Select-Object Name, State, Status | Sort-Object -Property "Name"
    $existing | Format-Table -AutoSize
    $vmnm = Read-Host -Prompt "Please Copy and Paste VM Name"
    Write-Warning "Generating Report"
    Start-Sleep 1
    [System.Console]::Beep(1000, 100)
    Write-Host "Done !" -ForegroundColor Green
    Start-Sleep 2
    Clear-Host
    $ddts = Get-VM $vmnm | Select-Object *
    $ddts | Format-List
    $ipn = Read-Host -Prompt "[R]etry, [E]xit to main menu. Default [R]etry"
    if ($ipn -eq "e") {
        Clear-Host
        [System.Console]::Beep(1000, 300)
        Write-Host "Exiting"
        &$base
        &$selection
    }
    else {
        &$gdtvmvue
    }
}

#CmdExportStageSingleVM
$Global:fcommandgenS = {
    [System.Console]::Beep(1000, 100)
    Clear-Host
    Write-Warning "Formatting Variables"
    Start-Sleep 1

    $maxram = $maxram -replace "GB", ""
    $maxram = "$maxram-GB" 
    $Global:maxram = $maxram -replace "-", ""

    $disksize = $disksize -replace "GB", ""
    $disksize = "$disksize-GB"
    $Global:disksize = $disksize -replace "-", ""

    $Global:disklocation = "$strgpath$machineid\$machineid.vhdx"

    [System.Console]::Beep(1000, 100)
    Write-Host "Done !" -ForegroundColor Green
    Write-Host $null

    if ($baseram -gt 64) {
        $baseram = $baseram -replace "[^0-9]", ""
        $baseram = "$baseram-MB"
        $Global:baseram = $baseram -replace "-", ""
    }
    else {
        $baseram = $baseram -replace "[^0-9]", ""
        $baseram = "$baseram-GB"
        $Global:baseram = $baseram -replace "-", ""
    }
    
    if ($startram -gt 64) {
        $startram = $startram -replace "MB", ""
        $startram = "$startram-MB"
        $Global:startram = $startram -replace "-", ""
    }
    else {
        $startram = $startram -replace "GB", ""
        $startram = "$startram-GB"
        $Global:startram = $startram -replace "-", ""
    }
    Write-Host "Final VM Creation Stage"
    Write-Host "Displaying VM information before generating command"
    Write-Host $null
    Start-Sleep 2
    Write-Host  "VM ID - $machineid"
    Start-Sleep -Milliseconds 500
    Write-Host "VM CPU-info. CoreCount - $cpu, Reserve - $reserve%, MaxUtilization - $maximum%, SystemPriority - $relwght"
    Start-Sleep -Milliseconds 500
    Write-Host "VM RAM-info. MaxMemory - $Global:maxram, MinMemory - $Global:baseram, StartupMemory - $Global:startram, SystemPriority - $prty"
    Start-Sleep -Milliseconds 500
    Write-Host "Absolute VM Path - $strgpath"
    Start-Sleep -Milliseconds 500
    Write-Host "VHD Size - $Global:disksize"
    Start-Sleep -Milliseconds 500
    Write-Host "VHD Location - $disklocation"
    Start-Sleep -Milliseconds 500
    Write-Host "External Adapter Name - $switchid"
    Write-Host "VM Boot Image path - $imagepath"
    Start-Sleep -Milliseconds 500
    Write-Host $null
    Write-Warning "Creating Log File"
    Start-Sleep 1
    $dt = Get-Date -Format "dddd-dd_mm_yyyy-HH_mm_ss"
    $nm = "$machineid-$dt-sgvm"
    $wtrfl = {
        New-Item -Path .\kashem_auto -ItemType File -Name $nm
        Add-Content -Path .\kashem_auto\$nm -Value "Script type - SingleVM"
        Add-Content -Path .\kashem_auto\$nm -Value "VM ID - $machineid"
        Add-Content -Path .\kashem_auto\$nm -Value "VM CPU-info. CoreCount - $cpu, Reserve - $reserve%, MaxUtilization - $maximum%, SystemPriority - $relwght"
        Add-Content -Path .\kashem_auto\$nm -Value "VM RAM-info. MaxMemory - $Global:maxram, MinMemory - $Global:baseram, StartupMemory - $Global:startram, SystemPriority - $prty"
        Add-Content -Path .\kashem_auto\$nm -Value "Absolute VM Path - $strgpath"
        Add-Content -Path .\kashem_auto\$nm -Value "VHD Size - $Global:disksize"
        Add-Content -Path .\kashem_auto\$nm -Value "VHD Location - $disklocation"
        Add-Content -Path .\kashem_auto\$nm -Value "VM Boot Image path - $imagepath"
        Add-Content -Path .\kashem_auto\$nm -Value "External Adapter Name - $switchid"
        Add-Content -Path .\kashem_auto\$nm -Value "Creation Date - $dt"
        Add-Content -Path .\kashem_auto\$nm -Value "Script Version - KA_V1.0"
    }
    $flcs = Test-Path .\kashem_auto
    if ($flcs -eq $true) {
        &$wtrfl
    }
    else {
        New-Item -Name "kashem_auto" -ItemType Directory
        &$wtrfl
    }
    [System.Console]::Beep(1000, 100)
    Write-Host "Log Generation Complete" -ForegroundColor Green
    Write-Host $null
    Write-Warning "Generating Command" 
    Start-Sleep 1
    [System.Console]::Beep(1000, 100)
    Write-Host "Command Generation Complete" -ForegroundColor Green
    Write-Host $null

    $fnlcmd = "New-VM -VMName $machineid -Path $strgpath ; Set-VMMemory -VMName $machineid -DynamicMemoryEnabled `$true -MinimumBytes $Global:baseram -StartupBytes $Global:startram -MaximumBytes $Global:maxram -Priority $prty ; Set-VMProcessor -VMName $machineid -Count $cpu -Reserve $reserve -Maximum $maximum -RelativeWeight $relwght -ExposeVirtualizationExtensions `$true ; New-VHD -Path $disklocation -SizeBytes $Global:disksize ; Add-VMHardDiskDrive -VMName $machineid -Path $disklocation ; Connect-VMNetworkAdapter -VMName $machineid -SwitchName $switchid ; Add-VMDvdDrive -VMName $machineid -Path $imagepath"
    
    Write-Host "Do you want to export command to file?"
    $dscrs = Read-Host -Prompt "[Y]es, [N]o. Default [N]o"
    if ($dscrs -eq "y") {
        Clear-Host
        Write-Host "Exporting Command"
        Start-Sleep 1
        Add-Content -Path .\kashem_auto\$nm -Value " "
        Add-Content -Path .\kashem_auto\$nm -Value " "
        Add-Content -Path .\kashem_auto\$nm -Value " "
        Add-Content -Path .\kashem_auto\$nm -Value " "
        Add-Content -Path .\kashem_auto\$nm -Value "VM Generation Command"
        Add-Content -Path .\kashem_auto\$nm -Value "-----------------------------------------------"
        Add-Content -Path .\kashem_auto\$nm -Value " "
        Add-Content -Path .\kashem_auto\$nm -Value $fnlcmd
        Add-Content -Path .\kashem_auto\$nm -Value " "
        Add-Content -Path .\kashem_auto\$nm -Value "-----------------------------------------------"
        Write-Host $null
        Write-Host "-----------------------------------------------"
        Write-Host $null
        $fnlcmd
        Write-Host $null
        Write-Host "-----------------------------------------------"
        Write-Host $null
        Write-Host "Exiting"
        Start-Sleep 1
        [System.Console]::Beep(2000, 100)
        [System.Console]::Beep(500, 100)
        [System.Console]::Beep(2000, 100)
        [System.Console]::Beep(500, 100)
        Remove-Variable baseram
        Remove-Variable startram
        Remove-Variable maxram
        Remove-Variable disksize
        &$base
        &$selection
    }
    else {
        Clear-Host
        Write-Host "-----------------------------------------------"
        Write-Host $null
        $fnlcmd
        Write-Host $null
        Write-Host "-----------------------------------------------"
        Write-Host $null
        $trashcache = Read-Host -Prompt "Press any key to exit to main menu"
        Write-Host "Exiting"
        Start-Sleep 1
        [System.Console]::Beep(2000, 100)
        [System.Console]::Beep(500, 100)
        [System.Console]::Beep(2000, 100)
        [System.Console]::Beep(500, 100)
        Remove-Variable baseram
        Remove-Variable startram
        Remove-Variable maxram
        Remove-Variable disksize
        &$base
        &$selection
    }
}

#CmdExportStageMultiVM
$Global:fcommandgenM = {
    [System.Console]::Beep(1000, 100)
    Clear-Host
    Write-Warning "Formatting Variables"
    Start-Sleep 1

    $maxram = $maxram -replace "GB", ""
    $maxram = "$maxram-GB"
    $Global:maxram = $maxram -replace "-", ""

    $disksize = $disksize -replace "GB", ""
    $disksize = "$disksize-GB"
    $Global:disksize = $disksize -replace "-", ""

    $Global:disklocation = "$strgpath$machineid`$_\$machineid`$_.vhdx"

    [System.Console]::Beep(1000, 100)
    Write-Host "Done !" -ForegroundColor Green
    Write-Host $null
    if ($baseram -gt 64) {
        $baseram = $baseram -replace "[A-Z]", ""
        $baseram = "$baseram-MB"
        $Global:baseram = $baseram -replace "-", ""
    }
    else {
        $baseram = $baseram -replace "[A-Z]", ""
        $baseram = "$baseram-GB"
        $Global:baseram = $baseram -replace "-", ""
    }
    $compensatednumvm = $numvm - 1
    if ($startram -gt 64) {
        $startram = $startram -replace "MB", ""
        $startram = "$startram-MB"
        $Global:startram = $startram -replace "-", ""
    }
    else {
        $startram = $startram -replace "GB", ""
        $startram = "$startram-GB"
        $Global:startram = $startram -replace "-", ""
    }
    Write-Host "Final VM Creation Stage"
    Write-Host "Displaying VM information before generating command"
    Write-Host $null
    Start-Sleep 2
    Write-Host  "VM ID - $machineid"
    Start-Sleep -Milliseconds 500
    Write-Host "VM CPU-info. CoreCount - $cpu, Reserve - $reserve%, MaxUtilization - $maximum%, SystemPriority - $relwght"
    Start-Sleep -Milliseconds 500
    Write-Host "VM RAM-info. MaxMemory - $Global:maxram, MinMemory - $Global:baseram, StartupMemory - $Global:startram, SystemPriority - $prty"
    Start-Sleep -Milliseconds 500
    Write-Host "Absolute VM Path - $strgpath"
    Start-Sleep -Milliseconds 500
    Write-Host "VHD Size - $Global:disksize"
    Start-Sleep -Milliseconds 500
    Write-Host "VHD Location - $disklocation"
    Start-Sleep -Milliseconds 500
    Write-Host "External Adapter Name - $switchid"
    Write-Host "VM Boot Image path - $imagepath"
    Start-Sleep -Milliseconds 500
    Write-Host $null
    Write-Host "Number of Guests $numvm"
    Start-Sleep -Milliseconds 500
    Write-Host $null
    Write-Warning "Creating Log File"
    Start-Sleep 1
    $dt = Get-Date -Format "dddd-dd_mm_yyyy-HH_mm_ss"
    $nm = "$machineid-$dt-mulvm"
    $wtrfl = {
        New-Item -Path .\kashem_auto -ItemType File -Name $nm
        Add-Content -Path .\kashem_auto\$nm -Value "Script Type - MultiVM"
        Add-Content -Path .\kashem_auto\$nm -Value "VM ID - $machineid"
        Add-Content -Path .\kashem_auto\$nm -Value "VM CPU-info. CoreCount - $cpu, Reserve - $reserve%, MaxUtilization - $maximum%, SystemPriority - $relwght"
        Add-Content -Path .\kashem_auto\$nm -Value "VM RAM-info. MaxMemory - $Global:maxram, MinMemory - $Global:baseram, StartupMemory - $Global:startram, SystemPriority - $prty"
        Add-Content -Path .\kashem_auto\$nm -Value "Absolute VM Path - $strgpath"
        Add-Content -Path .\kashem_auto\$nm -Value "VHD Size - $Global:disksize"
        Add-Content -Path .\kashem_auto\$nm -Value "VHD Location - $disklocation"
        Add-Content -Path .\kashem_auto\$nm -Value "VM Boot Image path - $imagepath"
        Add-Content -Path .\kashem_auto\$nm -Value "External Adapter Name - $switchid"
        Add-Content -Path .\kashem_auto\$nm -Value "Creation Date - $dt"
        Add-Content -Path .\kashem_auto\$nm -Value "Script Version - KA_V1.0"
    }
    $flcs = Test-Path .\kashem_auto
    if ($flcs -eq $true) {
        &$wtrfl
    }
    else {
        New-Item -Name "kashem_auto" -ItemType Directory
        &$wtrfl
    }
    [System.Console]::Beep(1000, 100)
    Write-Host "Log Generation Complete" -ForegroundColor Green
    Write-Host $null
    Write-Warning "Generating Command" 
    Start-Sleep 1
    [System.Console]::Beep(1000, 100)
    Write-Host "Command Generation Complete" -ForegroundColor Green
    Write-Host $null

    $fnlcmd = "0..$compensatednumvm | ForEach-Object { New-VM -VMName $machineid`$_ -Path $strgpath ; Set-VMMemory -VMName $machineid`$_ -DynamicMemoryEnabled `$true -MinimumBytes $Global:baseram -StartupBytes $Global:startram -MaximumBytes $Global:maxram -Priority $prty ; Set-VMProcessor -VMName $machineid`$_ -Count $cpu -Reserve $reserve -Maximum $maximum -RelativeWeight $relwght -ExposeVirtualizationExtensions `$true ; New-VHD -Path $disklocation -SizeBytes $Global:disksize ; Add-VMHardDiskDrive -VMName $machineid`$_ -Path $disklocation ; Connect-VMNetworkAdapter -VMName $machineid`$_ -SwitchName $switchid ; Add-VMDvdDrive -VMName $machineid`$_ -Path $imagepath }"
    
    Write-Host "Do you want to export command to file?"
    $dscrs = Read-Host -Prompt "[Y]es, [N]o. Default [N]o"
    if ($dscrs -eq "y") {
        Clear-Host
        Write-Host "Exporting Command"
        Start-Sleep 1
        Add-Content -Path .\kashem_auto\$nm -Value " "
        Add-Content -Path .\kashem_auto\$nm -Value " "
        Add-Content -Path .\kashem_auto\$nm -Value " "
        Add-Content -Path .\kashem_auto\$nm -Value " "
        Add-Content -Path .\kashem_auto\$nm -Value "VM Generation Command"
        Add-Content -Path .\kashem_auto\$nm -Value "-----------------------------------------------"
        Add-Content -Path .\kashem_auto\$nm -Value " "
        Add-Content -Path .\kashem_auto\$nm -Value $fnlcmd
        Add-Content -Path .\kashem_auto\$nm -Value " "
        Add-Content -Path .\kashem_auto\$nm -Value "-----------------------------------------------"
        Write-Host $null
        Write-Host "-----------------------------------------------"
        Write-Host $null
        $fnlcmd
        Write-Host $null
        Write-Host "-----------------------------------------------"
        Write-Host $null
        Write-Host "Exiting"
        Start-Sleep 1
        [System.Console]::Beep(2000, 100)
        [System.Console]::Beep(500, 100)
        [System.Console]::Beep(2000, 100)
        [System.Console]::Beep(500, 100)
        Remove-Variable baseram
        Remove-Variable startram
        Remove-Variable maxram
        Remove-Variable disksize
        &$base
        &$selection
    }
    else {
        Clear-Host
        Write-Host "-----------------------------------------------"
        Write-Host $null
        $fnlcmd
        Write-Host $null
        Write-Host "-----------------------------------------------"
        Write-Host $null
        $trashcache = Read-Host -Prompt "Press any key to exit to main menu"
        Write-Host "Exiting"
        Start-Sleep 1
        [System.Console]::Beep(2000, 100)
        [System.Console]::Beep(500, 100)
        [System.Console]::Beep(2000, 100)
        [System.Console]::Beep(500, 100)
        Remove-Variable baseram
        Remove-Variable startram
        Remove-Variable maxram
        Remove-Variable disksize
        &$base
        &$selection
    }
}

#SingleVMSetup
$Global:singlevm = {

    Write-Host "This script is for creating linux based VM's" 
    Start-Sleep 1
    Write-Warning "This will consume system resourses. Proceed with caution" 
    $ds2 = {
        $ipn = Read-Host -Prompt "Press [Y] to proceed and [R] to return to main menu"
        if ($ipn -eq "y") {
            $idinitial = {
                $vmclsn = {
                    $machineid = Read-Host -Prompt "Please enter the VM's ID (No spaces or special characters)"
                    $machineid = $machineid.ToLower()
                    $Global:machineid = $machineid -replace "[^a-zA-Z0-9_]", ""
                    Write-Host "Checking VM ID for Collisions"
                    Start-Sleep 1
                    Get-VM * | Select-Object -ExpandProperty Name | ForEach-Object {
                        if ($machineid -like $_) {
                            [System.Console]::Beep(400, 250)
                            Clear-Host
                            Write-Host "Error: VM ID collision" -ForegroundColor Red
                            Write-Host "Please set another VM ID"
                            Write-Warning "Resetting ID variable"
                            Start-Sleep 1
                            $machineid = $null
                            Write-Host $null
                            &$vmclsn
                        }
                        elseif ($machineid -eq "") {
                            [System.Console]::Beep(400, 250)
                            Clear-Host
                            Write-Host "Error: VM ID can not be Empty" -ForegroundColor Red
                            Write-Host "Please Re-Enter VM ID"
                            Write-Warning "Resetting ID variable"
                            Start-Sleep 1
                            $machineid = $null
                            Write-Host $null
                            &$vmclsn
                        }
                    }
                }
                &$vmclsn  
                Write-Warning "Applying VM ID"
                Start-Sleep 1
                $Global:machineid = $machineid
                [System.Console]::Beep(1000, 100)
                Write-Host "Your VM ID is " -NoNewline 
                Write-Host "$machineid" -ForegroundColor Yellow
                Write-Host "Done !" -ForegroundColor Green
                Start-Sleep 2
                Clear-Host
            }
            &$idinitial
            $cpuperf = Read-Host "Is your system CPU intensive? [Y]es or [N]o. Default [N]o"
            if ($cpuperf -eq "y") {
                Start-Sleep 1
                $Global:reserve = 40
                $Global:maximum = 90
                $Global:relwght = 250
                Write-Warning "Applying High Performance Settings"
                Start-Sleep 1
                [System.Console]::Beep(1000, 100)
                Write-Host "Done !" -ForegroundColor Green
                Start-Sleep 1
                Clear-Host
                $dsccpu = {
                    $Global:logicalcorecount = (Get-CimInstance Win32_ComputerSystem | Select-Object -ExpandProperty NumberOfLogicalProcessors)
                    $tmpmaxcore = $logicalcorecount * 0.5
                    $Global:maxcore = [int]$tmpmaxcore
                    Write-Host "The Host System has " -NoNewline
                    Write-Host $logicalcorecount -ForegroundColor Yellow -NoNewline
                    Write-Host " Cores"
                    $subdsccpu = {
                        Write-Warning "Please do not exceed $maxcore Cores"
                        Write-Host "2 Cores suggested for basic workloads"
                        $tmpcpu = Read-Host -Prompt "Enter Core Count (Minimum 2 Cores)"
                        Write-Warning "Checking CPU CC Variable"
                        Start-Sleep 1
                        $cctype = [Microsoft.VisualBasic.Information]::IsNumeric($tmpcpu)   #CheckIfVariableIsNeumeric
                        if ($cctype -eq $true) {
                            [System.Console]::Beep(1000, 100)
                            Clear-Host
                            Write-Host "CPU CC Var-Type Pass" -ForegroundColor Green
                            $tmpcpu = [int]$tmpcpu
                            Write-Warning "Validating User Specified CPU CC"
                            Start-Sleep 1
                            if ($tmpcpu -gt $maxcore) {
                                [System.Console]::Beep(400, 250)
                                Clear-Host
                                Write-Host "Error: CPU CC exceeded System limits" -ForegroundColor Red
                                Write-Warning "Resetting CPU CC Variable"
                                Start-Sleep 1
                                $tmpcpu = $null
                                Write-Host $null
                                &$subdsccpu
                            }
                            elseif ($tmpcpu -eq 0) {
                                [System.Console]::Beep(400, 250)
                                Clear-Host
                                Write-Host "Error: CPU CC is Zero/Empty" -ForegroundColor Red
                                Write-Warning "Resetting CPU CC Variable"
                                Start-Sleep 1
                                $tmpcpu = $null
                                Write-Host $null
                                &$subdsccpu
                            }
                            elseif ($tmpcpu -lt 2) {
                                [System.Console]::Beep(400, 250)
                                Clear-Host
                                Write-Host "Error: CPU CC is less than 2" -ForegroundColor Red
                                Write-Warning "Resetting CPU CC Variable"
                                Start-Sleep 1
                                $tmpcpu = $null
                                Write-Host $null
                                &$subdsccpu
                            }
                            else {
                                Write-Warning "Applying User Specified Cores to Guest OS"
                                Start-Sleep 1
                                $Global:cpu = $tmpcpu
                                [System.Console]::Beep(1000, 100)
                                Write-Host "$cpu " -ForegroundColor Yellow -NoNewline
                                Write-Host "Cores assigned to Guest OS"
                                Write-Host "Done !" -ForegroundColor Green
                                Start-Sleep 2
                                Clear-Host
                            }
                        }
                        else {
                            [System.Console]::Beep(400, 250)
                            Clear-Host
                            Write-Host "Error: CPU CC Var-Type Fail" -ForegroundColor Red
                            Write-Host "CPU CC Must be a Neumeric Value"
                            Write-Host $null
                            Start-Sleep 1
                            &$subdsccpu
                        }
                    }
                    &$subdsccpu
                }
                &$dsccpu
            }
            else {
                Write-Warning "Applying Default Performance Settings"
                Start-Sleep 1
                Write-Warning "Assigning Default Cores to Guest OS"
                Start-Sleep 1
                $Global:cpu = 1
                $Global:reserve = 10
                $Global:maximum = 30
                $Global:relwght = 150
                Write-Host "$cpu " -ForegroundColor Yellow -NoNewline
                Write-Host "Core assigned to Guest OS"
                [System.Console]::Beep(1000, 100)
                Write-Host "Done !" -ForegroundColor Green
                Start-Sleep 2
                Clear-Host
            }
            $ramperf = Read-Host "Is your system Memory intensive? [Y]es or [N]o. Default [N]o"
            if ($ramperf -eq "y") {
                Write-Warning "Setting Guest OS Memory Performance Profile"
                Start-Sleep 1
                Write-Warning "High Performance Mode is set for Guest OS"
                Start-Sleep 1
                $Global:baseram = 1
                $Global:startram = 2
                $Global:prty = 90
                [System.Console]::Beep(1000, 100)
                Write-Host "Done !" -ForegroundColor Green
                Start-Sleep 2
                Clear-Host
                $dscram = {
                    $tmpphysicalmem = (Get-CimInstance Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory)
                    $cvphysicalmem = $tmpphysicalmem / 1024 / 1024 / 1024
                    $Global:physicalmem = [int]$cvphysicalmem
                    $tampmaxallowedram = $physicalmem * 0.2
                    $maxallowedram = [int]$tampmaxallowedram
                    Write-Host "Your System Memory is " -NoNewline 
                    Write-Host $physicalmem -ForegroundColor Yellow -NoNewline
                    Write-Host " GB"
                    Write-Host "Calculating Max Allowed System Ram For This Host"
                    Start-Sleep 1
                    $subdscram = {
                        Write-Warning "Do not allot more than $maxallowedram GB of Memory for the VM"
                        $tmpmaxram = Read-Host -Prompt "Enter the amount of RAM to be allocated to the machine (Minimum 3GB)"
                        Write-Warning "Checking GOS VMem Variable"
                        Start-Sleep 1
                        $ramtype = [Microsoft.VisualBasic.Information]::IsNumeric($tmpmaxram)
                        if ($ramtype -eq $true) {
                            [System.Console]::Beep(1000, 100)
                            Clear-Host
                            Write-Host "GOS VMem Var-Type Pass" -ForegroundColor Green
                            [int]$maxram = $tmpmaxram
                            Write-Warning "Validating User Specified GOS VMem"
                            Start-Sleep 1
                            if ($maxram -lt 3) {
                                [System.Console]::Beep(400, 250)
                                Clear-Host
                                Write-Host "Error: Insufficient System Memory for Guest OS" -ForegroundColor Red
                                Write-Warning "Resetting Memory Variable" 
                                Start-Sleep 1
                                $tmpmaxram = $null
                                $maxram = $null
                                Write-Host $null
                                &$subdscram
                            }
                            elseif ($maxram -gt $maxallowedram) {
                                [System.Console]::Beep(400, 250)
                                Clear-Host
                                Write-Host "Error: User specified Memory exceeded System limits" -ForegroundColor Red
                                Write-Warning "Resetting Memory Variable"
                                Start-Sleep 1
                                $tmpmaxram = $null
                                $maxram = $null
                                Write-Host $null
                                &$subdscram
                            }
                            else {
                                Write-Warning "Applying Guest Memory Amount"
                                Start-Sleep 1
                                $Global:maxram = $maxram
                                $Global:baseram = 1
                                $Global:startram = 2
                                $Global:prty = 80
                                [System.Console]::Beep(1000, 100)
                                Write-Host "Done !" -ForegroundColor Green
                                Start-Sleep 2
                                Clear-Host
                            } 
                        }
                        else {
                            [System.Console]::Beep(400, 250)
                            Clear-Host
                            Write-Host "Error: GOS VMem Var-Type Fail" -ForegroundColor Red
                            Write-Host "GOS VMem Must be a Neumeric Value"
                            Write-Host $null
                            Start-Sleep 1
                            &$subdscram
                        }
                    }
                    &$subdscram
                }
                &$dscram
            }
            else {
                Write-Warning "Setting Default Memory Profile for Guest OS"
                Start-Sleep 1
                Write-Warning "Setting Guest RAM Limit to 2GB"
                Start-Sleep 1
                $Global:maxram = 2
                $Global:baseram = 512
                $Global:startram = 1
                $Global:prty = 40
                [System.Console]::Beep(1000, 100)
                Write-Host "Done !" -ForegroundColor Green
                Start-Sleep 2
                Clear-Host
            }
            $dsstr = {
                $Global:slc = 1
                $Global:systemdrives = Get-Volume | Select-Object -ExpandProperty DriveLetter
                $numdrives = $systemdrives.Length
                $Global:rawsysdrv = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty SystemDrive
                Write-Warning "Scanning System for Usable Volumes"
                Start-Sleep 1
                [System.Console]::Beep(1000, 100)
                Write-Host " $numdrives " -NoNewline -ForegroundColor Black -BackgroundColor Yellow
                Write-Host " Drives Found"
                Write-Host $null
                Get-Volume | Select-Object -ExpandProperty DriveLetter | ForEach-Object {
                    Write-Host "Volume - $slc "
                    Write-Warning "Scanning Drive $_"
                    Start-Sleep 2
                    $rawtotalspace = Get-Volume $_ | Select-Object -ExpandProperty Size
                    [int]$Global:totalspace = $rawtotalspace / 1024 / 1024 / 1024
                    $tmsl = {
                        if ($totalspace -lt 50) {
                            Write-Host "Partition Size Insufficent" -ForegroundColor Red
                        }
                        else {
                            Write-Host "Partition Size Sufficient" -ForegroundColor Green
                        }
                    }
                    $rawfreesize = Get-Volume $_ | Select-Object -ExpandProperty SizeRemaining
                    [int]$Global:freespace = $rawfreesize / 1024 / 1024 / 1024
                    $nslft = {
                        $acfsp = $totalspace * 0.25
                        $acfsp = [int]$acfsp
                        if ($acfsp -gt $freespace) {
                            Write-Host "Insufficient Space Remaining" -ForegroundColor Red
                        }
                        else {
                            Write-Host "Sufficient Free Space Available" -ForegroundColor Green
                        }
                    }
                    $format = Get-Volume $_ | Select-Object -ExpandProperty FileSystemType
                    $Global:stat = Get-Volume $_ | Select-Object -ExpandProperty HealthStatus
                    $drsts = {
                        if ($stat -cnotlike "Healthy") {
                            Write-Host "WARNING : Drive Status - Not Healthy" -ForegroundColor Red
                        }
                        else {
                            Write-Host "Drive Status - Healthy" -ForegroundColor Green
                        }
                    }
                    $Global:mnttyp = Get-Volume $_ | Select-Object -ExpandProperty DriveType
                    $ublty = {
                        if ($_ -clike $rawsysdrv[0]) {
                            Write-Warning "This is OS drive. Modification not reccomended."
                        }
                        else {
                            if ($mnttyp -clike "Removable") {
                                Write-Warning "This is a Removable Device."
                            } 
                            else {
                                Write-Host "This Drive may be used as VM Storage Pool" -ForegroundColor Green
                                &$tmsl
                                &$nslft
                            }
                        }
                    }
                    $tmppartuuid = Get-Volume $_ | Select-Object -ExpandProperty UniqueId
                    $uuid = $tmppartuuid.Replace("\\?\Volume{", "").Replace("}\", "")
                    $label = Get-Volume $_ | Select-Object -ExpandProperty FileSystemLabel
                    $lbl = {
                        if ($label -eq "") {
                            Write-Host "Partition Name - " -NoNewline
                            Write-Host "No Name Specified" -ForegroundColor Red
                        }
                        else {
                            Write-Host "Partition Name - " -NoNewline 
                            Write-Host " $label " -ForegroundColor Yellow
                        }
                    }
                    Write-Host "Drive Letter - $_"
                    Write-Host "Partition Format - $format"
                    Write-Host "Total Size - $totalspace GB"
                    Write-Host "Free Space - $freespace GB"
                    &$drsts 
                    &$lbl 
                    &$ublty
                    Write-Host "Partition ID - $uuid"
                    Write-Host $null
                    $slc++
                }
                $stup = {
                    $szscl = {
                        $dskc = $null
                        $rawfreesize = Get-Volume $tmstrp | Select-Object -ExpandProperty SizeRemaining
                        [int]$finalSize = $rawfreesize / 1024 / 1024 / 1024
                        $maxvoltmp = $finalSize * 0.5
                        $maxvol = [int]$maxvoltmp
                        Write-Host "You have $finalSize GB Remaining in drive $tmstrp"
                        Write-Host "Calculating maximum allowed Virtual Hard Drive size"
                        Start-Sleep 1
                        $subsdcstrgplsz = {
                            Write-Host "Specify a Virtual Disk size less than $maxvol GB"
                            $dskc = Read-Host -Prompt "Enter Volume size in GigaBytes"
                            $szchk = [Microsoft.VisualBasic.Information]::IsNumeric($dskc)
                            Write-Warning "Checking VM StrPoolRawSize"
                            Start-Sleep 1
                            if ($szchk -eq $true) {
                                [System.Console]::Beep(1000, 100)
                                Clear-Host
                                Write-Host "VM StrPoolRawSize Var-Type Pass" -ForegroundColor Green
                                $dskc = [int]$dskc
                                Write-Warning "Validating User Specified VM StrPoolRawSize"
                                Start-Sleep 1
                                if ($dskc -gt $maxvol) {
                                    [System.Console]::Beep(400, 250)
                                    Clear-Host
                                    Write-Host "Error: Specified Disk size exceeded the maximum allowable amount" -ForegroundColor Red
                                    Write-Warning "Resetting Storage Variable to 0 B"
                                    Start-Sleep 1
                                    Write-Host $null
                                    &$subsdcstrgplsz
                                }
                                elseif ($dskc -lt 10) {
                                    [System.Console]::Beep(400, 250)
                                    Clear-Host
                                    Write-Host "Error: This is less than Guest OS requirements" -ForegroundColor Red
                                    Start-Sleep 1
                                    Write-Host $null
                                    &$subsdcstrgplsz
                                }
                                else {
                                    Write-Warning "Setting Storage Space to $dskc GB"
                                    Start-Sleep 1
                                    $Global:disksize = $dskc
                                    [System.Console]::Beep(1000, 100)
                                    Write-Host "Done !" -ForegroundColor Green
                                    Start-Sleep 2
                                    Clear-Host
                                }
                            }
                            else {
                                [System.Console]::Beep(400, 250)
                                Clear-Host
                                Write-Host "Error: VM StrPoolRawSize Var-Type Fail" -ForegroundColor Red
                                Write-Host "VM StrPoolRawSize Must be a Neumeric Value"
                                Write-Host $null
                                Start-Sleep 1
                                &$subsdcstrgplsz
                            }
                        }
                        &$subsdcstrgplsz
                    }
                    $strp = $tmstrp + ":\"
                    Write-Warning "$tmstrp Drive has been selected"
                    $stropn = Read-Host -Prompt "Set the Current Drive as VM disk Root [Y]es or [N]o. Default [N]o"
                    if ($stropn -eq "y") {
                        Write-Warning "Setting $strp as VM Root"
                        Start-Sleep 1
                        $Global:strgpath = $strp
                        [System.Console]::Beep(1000, 100)
                        Write-Host "Done !" -ForegroundColor Green
                        Start-Sleep 2
                        Clear-Host
                        &$szscl
                    }
                    else {
                        $strgpath = $strp
                        $flclp = {
                            $flcopn = Read-Host "[L]ist items or [C]reate New Path. Default [L]ist items"
                            if ($flcopn -eq "C") {
                                $fllp = {
                                    $flnm = Read-Host -Prompt "Enter Folder Name"
                                    $Global:flnm = $flnm -replace "[^a-zA-Z0-9_]", ""
                                    Get-ChildItem $strgpath | Select-Object -ExpandProperty Name | ForEach-Object {
                                        if ($flnm -like $_) {
                                            [System.Console]::Beep(400, 250)
                                            Write-Host "Error: This Folder Already Exists" -ForegroundColor Red
                                            Write-Host $null
                                            $flnm = $null
                                            &$fllp
                                        }
                                        if ($flnm -eq "") {
                                            [System.Console]::Beep(400, 250)
                                            Write-Host "Error: Name can not be empty" -ForegroundColor Red
                                            Write-Host $null
                                            $flnm = $null
                                            &$fllp
                                        }
                                    }
                                }
                                &$fllp
                                Write-Warning "Creating Directory $flnm at Drive $strgpath"
                                New-Item -Path $strgpath -Name $flnm -ItemType Directory
                                Write-Host $null
                                Start-Sleep 1
                                Write-Warning "Setting new Path Variable"
                                Start-Sleep 1
                                [System.Console]::Beep(1000, 100)
                                Write-Host "Done !" -ForegroundColor Green
                                $strgpath = $strp + $flnm + "\"
                                $Global:strgpath = $strgpath
                                Write-Host "New Path Variable is $strgpath"
                                Start-Sleep 2
                                Clear-Host
                                &$szscl
                            }
                            else {
                                [System.Console]::Beep(400, 250)
                                Clear-Host
                                $contents = Get-ChildItem -Path $strgpath
                                $contents
                                Write-Host $null
                                &$flclp
                            }
                        }
                        &$flclp
                    }
                }
                $ssgl = {
                    [System.Console]::Beep(1000, 100)
                    $cssp = Read-Host -Prompt "Please Select a Drive Letter"
                    Write-Warning "Checking specified path"
                    Start-Sleep 1
                    if ($cssp -ne ".") {
                        $tmstrp = $cssp.ToUpper()
                        $aplstrp = $tmstrp + ":\"
                        $pathstatus = Test-Path $aplstrp
                        if ($pathstatus -ne $true) {
                            [System.Console]::Beep(400, 250)
                            Write-Host "Invalid / Non-Existant path" -ForegroundColor Red
                            Start-Sleep 1
                            Clear-Host
                            &$ssgl
                        }
                        else {
                            $Global:mnttyp = Get-Volume $tmstrp | Select-Object -ExpandProperty DriveType
                            $Global:stat = Get-Volume $tmstrp | Select-Object -ExpandProperty HealthStatus
                            $rawtotalspace = Get-Volume $tmstrp | Select-Object -ExpandProperty Size
                            [int]$Global:totalspace = $rawtotalspace / 1024 / 1024 / 1024
                            $rawfreesize = Get-Volume $tmstrp | Select-Object -ExpandProperty SizeRemaining
                            [int]$Global:freespace = $rawfreesize / 1024 / 1024 / 1024
                            $acfsp = $totalspace * 0.25
                            $acfsp = [int]$acfsp
                            if ($mnttyp -clike "Removable") {
                                [System.Console]::Beep(400, 250)
                                Write-Host "Error: This is a Removable Device. Installation not recommended" -ForegroundColor Red
                                Start-Sleep 1
                                &$ssgl
                            }
                            if ($stat -cnotlike "Healthy") {
                                [System.Console]::Beep(400, 250)
                                Write-Warning "Drive Status - Not Healthy"
                                Write-Host "Installation not recommended" -ForegroundColor Red
                                Start-Sleep 1
                                &$ssgl
                            }
                            if ($totalspace -lt 50) {
                                [System.Console]::Beep(400, 250)
                                Write-Host "Partition Size Insufficent" -ForegroundColor Red
                                &$ssgl
                            }
                            if ($acfsp -gt $freespace) {
                                [System.Console]::Beep(400, 250)
                                Write-Host "Insufficient Space Remaining" -ForegroundColor Red
                                &$ssgl
                            }
                            if ($tmstrp -clike $rawsysdrv[0]) {
                                [System.Console]::Beep(400, 250)
                                Write-Warning "This is the OS Drive"
                                $ks = Read-Host -Prompt "Do you want to proceed? [Y]es or [No]. Default [N]o"
                                if ($ks -eq "y") {
                                    &$stup
                                }
                                else {
                                    Write-Host "Returning to Drive Selection" -ForegroundColor Red
                                    Start-Sleep 1
                                    &$ssgl
                                }
                            }
                            else {
                                &$stup
                            }
                        }
                    }
                    else {
                        [System.Console]::Beep(400, 250)
                        Write-Host "Invalid / Non-Existant path" -ForegroundColor Red
                        Start-Sleep 1
                        Clear-Host
                        &$ssgl
                    }
                }
                &$ssgl
            }
            &$dsstr
            $dssvmsws = {
                $tmpsws = Get-VMSwitch
                if ($tmpsws -eq $null) {
                    [System.Console]::Beep(400, 250)
                    Write-Host "Error: No VMSwitch Found!" 
                    Write-Host "Check if Hyper-V has network access"
                    Exit
                }
                else {
                    [System.Console]::Beep(1000, 100)
                    $swcnt = Get-VMSwitch | Select-Object -ExpandProperty Name
                    Write-Host $swcnt.Count -ForegroundColor Yellow -NoNewline
                    Write-Host " VMSwitch Detected"
                    Start-Sleep 1
                    Write-Warning "Searching For External Switches"
                    Start-Sleep 1
                    $scrtc = Get-VMSwitch | Select-Object -ExpandProperty SwitchType | Where-Object { $_ -eq "external" }
                    if ($scrtc -eq "external") {
                        [System.Console]::Beep(1000, 100)
                        Write-Host "External Switch Found" -ForegroundColor Green
                        $swc = Get-VMSwitch | Select-Object -ExpandProperty Name
                        for ($i = 0; $i -lt $swc.Count) {
                            $swtextr = Get-VMSwitch $swc[$i] | Select-Object -ExpandProperty SwitchType
                            if ($swtextr -eq "external") {
                                [System.Console]::Beep(1000, 100)
                                Write-Host "External Switch Check Pass!" -ForegroundColor Green
                                [string]$scs = $swc[$i]
                                Write-Warning "Setting $scs as VM Switch"
                                Start-Sleep 1
                                $Global:switchid = $swc[$i]
                                [System.Console]::Beep(1000, 100)
                                Write-Host "Done !" -ForegroundColor Green
                                Start-Sleep 2
                                break
                                Clear-Host
                            }
                            $i++
                        }
                    }
                    else {
                        [System.Console]::Beep(400, 250)
                        Write-Host "Error: No External Switch Detected"
                        Write-Warning "Launching VMSwitch Creator"
                        Start-Sleep 1
                        $swsnm = Read-Host "Specify External Switch Name"
                        $Global:switchid = $swsnm -replace "[^a-zA-Z0-9_]", ""
                        [System.Console]::Beep(1000, 100)
                        Write-Warning "Creating External Switch $switchid"
                        Start-Sleep 1
                        New-VMSwitch -name $switchid  -NetAdapterName Ethernet -AllowManagementOS $true
                        [System.Console]::Beep(1000, 100)
                        Write-Host "Done !" -ForegroundColor Green
                        Start-Sleep 2
                        Clear-Host
                    }
                }
            }
            &$dssvmsws
            $imgchk = {
                
                Write-Host "Go to image, right-click and select copy as path"
                $tmpimgpath = Read-Host "Enter Image Path"
                $tmpimgpath = $tmpimgpath -replace "`"", ""
                $lvlx = Test-Path $tmpimgpath 
                if ($lvlx -eq $true) {
                    Write-Warning "Setting image path"
                    $Global:imagepath = $tmpimgpath
                    [System.Console]::Beep(1000, 100)
                    Write-Host "Done !" -ForegroundColor Green
                    Start-Sleep 2
                    Clear-Host
                }
                else {
                    Clear-Host
                    [System.Console]::Beep(400, 250)
                    Write-Host "Error:Invalid image path" -ForegroundColor Red
                    Write-Host $null
                    &$imgchk
                }
            }
            &$imgchk
            &$fcommandgenS
        }
        elseif ($ipn -eq "r") {
            Clear-Host
            &$base
            &$selection
        }
        else {
            Write-Host "Try again"
            &$ds2
        }
    }
    &$ds2
}

#MultiVMSetup
$Global:multivm = {
    Write-Host "This script is for creating linux based VM's" 
    Start-Sleep 1
    Write-Warning "This will consume system resourses. Proceed with caution" 
    $ds2 = {
        $ipn = Read-Host -Prompt "Press [Y] to proceed and [R] to return to main menu"
        if ($ipn -eq "y") {
            $Global:numvm = Read-Host -Prompt "Enter the number of VM's to create"
            $idinitial = {
                $vmclsn = {
                    $machineid = Read-Host -Prompt "Please enter the VM's ID (No spaces or special characters)"
                    $machineid = $machineid.ToLower()
                    $Global:machineid = $machineid -replace "[^a-zA-Z0-9_]", ""
                    Write-Host "Checking VM ID for Collisions"
                    Start-Sleep 1
                    Get-VM * | Select-Object -ExpandProperty Name | ForEach-Object {
                        if ($machineid -like $_) {
                            [System.Console]::Beep(400, 250)
                            Clear-Host
                            Write-Host "Error: VM ID collision" -ForegroundColor Red
                            Write-Host "Please set another VM ID"
                            Write-Warning "Resetting ID variable"
                            Start-Sleep 1
                            $machineid = $null
                            Write-Host $null
                            &$vmclsn
                        }
                        elseif ($machineid -eq "") {
                            [System.Console]::Beep(400, 250)
                            Clear-Host
                            Write-Host "Error: VM ID can not be Empty" -ForegroundColor Red
                            Write-Host "Please Re-Enter VM ID"
                            Write-Warning "Resetting ID variable"
                            Start-Sleep 1
                            $machineid = $null
                            Write-Host $null
                            &$vmclsn
                        }
                    }
                }
                &$vmclsn  
                Write-Warning "Applying VM ID"
                Start-Sleep 1
                $Global:machineid = $machineid
                [System.Console]::Beep(1000, 100)
                Write-Host "Your VM ID is " -NoNewline 
                Write-Host "$machineid" -ForegroundColor Yellow
                Write-Host "Done !" -ForegroundColor Green
                Start-Sleep 2
                Clear-Host
            }
            &$idinitial
            $cpuperf = Read-Host "Is your system CPU intensive? [Y]es or [N]o. Default [N]o"
            if ($cpuperf -eq "y") {
                Start-Sleep 1
                $Global:reserve = 40
                $Global:maximum = 90
                $Global:relwght = 250
                Write-Warning "Applying High Performance Settings"
                Start-Sleep 1
                [System.Console]::Beep(1000, 100)
                Write-Host "Done !" -ForegroundColor Green
                Start-Sleep 1
                Clear-Host
                $dsccpu = {
                    $Global:logicalcorecount = (Get-CimInstance Win32_ComputerSystem | Select-Object -ExpandProperty NumberOfLogicalProcessors)
                    $tmpmaxcore = $logicalcorecount * 0.5
                    $Global:maxcore = [int]$tmpmaxcore
                    Write-Host "The Host System has " -NoNewline
                    Write-Host $logicalcorecount -ForegroundColor Yellow -NoNewline
                    Write-Host " Cores"
                    $subdsccpu = {
                        Write-Warning "Please do not exceed $maxcore Cores"
                        Write-Host "2 Cores suggested for basic workloads"
                        $tmpcpu = Read-Host -Prompt "Enter Core Count (Minimum 2 Cores)"
                        Write-Warning "Checking CPU CC Variable"
                        Start-Sleep 1
                        $cctype = [Microsoft.VisualBasic.Information]::IsNumeric($tmpcpu)   #CheckIfVariableIsNeumeric
                        if ($cctype -eq $true) {
                            [System.Console]::Beep(1000, 100)
                            Clear-Host
                            Write-Host "CPU CC Var-Type Pass" -ForegroundColor Green
                            $tmpcpu = [int]$tmpcpu
                            Write-Warning "Validating User Specified CPU CC"
                            Start-Sleep 1
                            if ($tmpcpu -gt $maxcore) {
                                [System.Console]::Beep(400, 250)
                                Clear-Host
                                Write-Host "Error: CPU CC exceeded System limits" -ForegroundColor Red
                                Write-Warning "Resetting CPU CC Variable"
                                Start-Sleep 1
                                $tmpcpu = $null
                                Write-Host $null
                                &$subdsccpu
                            }
                            elseif ($tmpcpu -eq 0) {
                                [System.Console]::Beep(400, 250)
                                Clear-Host
                                Write-Host "Error: CPU CC is Zero/Empty" -ForegroundColor Red
                                Write-Warning "Resetting CPU CC Variable"
                                Start-Sleep 1
                                $tmpcpu = $null
                                Write-Host $null
                                &$subdsccpu
                            }
                            elseif ($tmpcpu -lt 2) {
                                [System.Console]::Beep(400, 250)
                                Clear-Host
                                Write-Host "Error: CPU CC is less than 2" -ForegroundColor Red
                                Write-Warning "Resetting CPU CC Variable"
                                Start-Sleep 1
                                $tmpcpu = $null
                                Write-Host $null
                                &$subdsccpu
                            }
                            else {
                                Write-Warning "Applying User Specified Cores to Guest OS"
                                Start-Sleep 1
                                $Global:cpu = $tmpcpu
                                [System.Console]::Beep(1000, 100)
                                Write-Host "$cpu " -ForegroundColor Yellow -NoNewline
                                Write-Host "Cores assigned to Guest OS"
                                Write-Host "Done !" -ForegroundColor Green
                                Start-Sleep 2
                                Clear-Host
                            }
                        }
                        else {
                            [System.Console]::Beep(400, 250)
                            Clear-Host
                            Write-Host "Error: CPU CC Var-Type Fail" -ForegroundColor Red
                            Write-Host "CPU CC Must be a Neumeric Value"
                            Write-Host $null
                            Start-Sleep 1
                            &$subdsccpu
                        }
                    }
                    &$subdsccpu
                }
                &$dsccpu
            }
            else {
                Write-Warning "Applying Default Performance Settings"
                Start-Sleep 1
                Write-Warning "Assigning Default Cores to Guest OS"
                Start-Sleep 1
                $Global:cpu = 1
                $Global:reserve = 10
                $Global:maximum = 30
                $Global:relwght = 150
                Write-Host "$cpu " -ForegroundColor Yellow -NoNewline
                Write-Host "Core assigned to Guest OS"
                [System.Console]::Beep(1000, 100)
                Write-Host "Done !" -ForegroundColor Green
                Start-Sleep 2
                Clear-Host
            }
            $ramperf = Read-Host "Is your system Memory intensive? [Y]es or [N]o. Default [N]o"
            if ($ramperf -eq "y") {
                Write-Warning "Setting Guest OS Memory Performance Profile"
                Start-Sleep 1
                Write-Warning "High Performance Mode is set for Guest OS"
                Start-Sleep 1
                $Global:baseram = 1
                $Global:startram = 2
                $Global:prty = 90
                [System.Console]::Beep(1000, 100)
                Write-Host "Done !" -ForegroundColor Green
                Start-Sleep 2
                Clear-Host
                $dscram = {
                    $tmpphysicalmem = (Get-CimInstance Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory)
                    $cvphysicalmem = $tmpphysicalmem / 1024 / 1024 / 1024
                    $Global:physicalmem = [int]$cvphysicalmem
                    $tampmaxallowedram = $physicalmem * 0.2
                    $maxallowedram = [int]$tampmaxallowedram
                    Write-Host "Your System Memory is " -NoNewline 
                    Write-Host $physicalmem -ForegroundColor Yellow -NoNewline
                    Write-Host " GB"
                    Write-Host "Calculating Max Allowed System Ram For This Host"
                    Start-Sleep 1
                    $subdscram = {
                        Write-Warning "Do not allot more than $maxallowedram GB of Memory for the VM"
                        $tmpmaxram = Read-Host -Prompt "Enter the amount of RAM to be allocated to the machine (Minimum 3GB)"
                        Write-Warning "Checking GOS VMem Variable"
                        Start-Sleep 1
                        $ramtype = [Microsoft.VisualBasic.Information]::IsNumeric($tmpmaxram)
                        if ($ramtype -eq $true) {
                            [System.Console]::Beep(1000, 100)
                            Clear-Host
                            Write-Host "GOS VMem Var-Type Pass" -ForegroundColor Green
                            [int]$maxram = $tmpmaxram
                            Write-Warning "Validating User Specified GOS VMem"
                            Start-Sleep 1
                            if ($maxram -lt 3) {
                                [System.Console]::Beep(400, 250)
                                Clear-Host
                                Write-Host "Error: Insufficient System Memory for Guest OS" -ForegroundColor Red
                                Write-Warning "Resetting Memory Variable" 
                                Start-Sleep 1
                                $tmpmaxram = $null
                                $maxram = $null
                                Write-Host $null
                                &$subdscram
                            }
                            elseif ($maxram -gt $maxallowedram) {
                                [System.Console]::Beep(400, 250)
                                Clear-Host
                                Write-Host "Error: User specified Memory exceeded System limits" -ForegroundColor Red
                                Write-Warning "Resetting Memory Variable"
                                Start-Sleep 1
                                $tmpmaxram = $null
                                $maxram = $null
                                Write-Host $null
                                &$subdscram
                            }
                            else {
                                Write-Warning "Applying Guest Memory Amount"
                                Start-Sleep 1
                                $Global:maxram = $maxram
                                $Global:baseram = 1
                                $Global:startram = 2
                                $Global:prty = 80
                                [System.Console]::Beep(1000, 100)
                                Write-Host "Done !" -ForegroundColor Green
                                Start-Sleep 2
                                Clear-Host
                            } 
                        }
                        else {
                            [System.Console]::Beep(400, 250)
                            Clear-Host
                            Write-Host "Error: GOS VMem Var-Type Fail" -ForegroundColor Red
                            Write-Host "GOS VMem Must be a Neumeric Value"
                            Write-Host $null
                            Start-Sleep 1
                            &$subdscram
                        }
                    }
                    &$subdscram
                }
                &$dscram
            }
            else {
                Write-Warning "Setting Default Memory Profile for Guest OS"
                Start-Sleep 1
                Write-Warning "Setting Guest RAM Limit to 2GB"
                Start-Sleep 1
                $Global:maxram = 2
                $Global:baseram = 512
                $Global:startram = 1
                $Global:prty = 40
                [System.Console]::Beep(1000, 100)
                Write-Host "Done !" -ForegroundColor Green
                Start-Sleep 2
                Clear-Host
            }
            $dsstr = {
                $Global:slc = 1
                $Global:systemdrives = Get-Volume | Select-Object -ExpandProperty DriveLetter
                $numdrives = $systemdrives.Length
                $Global:rawsysdrv = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty SystemDrive
                Write-Warning "Scanning System for Usable Volumes"
                Start-Sleep 1
                [System.Console]::Beep(1000, 100)
                Write-Host " $numdrives " -NoNewline -ForegroundColor Black -BackgroundColor Yellow
                Write-Host " Drives Found"
                Write-Host $null
                Get-Volume | Select-Object -ExpandProperty DriveLetter | ForEach-Object {
                    Write-Host "Volume - $slc "
                    Write-Warning "Scanning Drive $_"
                    Start-Sleep 2
                    $rawtotalspace = Get-Volume $_ | Select-Object -ExpandProperty Size
                    [int]$Global:totalspace = $rawtotalspace / 1024 / 1024 / 1024
                    $tmsl = {
                        if ($totalspace -lt 50) {
                            Write-Host "Partition Size Insufficent" -ForegroundColor Red
                        }
                        else {
                            Write-Host "Partition Size Sufficient" -ForegroundColor Green
                        }
                    }
                    $rawfreesize = Get-Volume $_ | Select-Object -ExpandProperty SizeRemaining
                    [int]$Global:freespace = $rawfreesize / 1024 / 1024 / 1024
                    $nslft = {
                        $acfsp = $totalspace * 0.25
                        $acfsp = [int]$acfsp
                        if ($acfsp -gt $freespace) {
                            Write-Host "Insufficient Space Remaining" -ForegroundColor Red
                        }
                        else {
                            Write-Host "Sufficient Free Space Available" -ForegroundColor Green
                        }
                    }
                    $format = Get-Volume $_ | Select-Object -ExpandProperty FileSystemType
                    $Global:stat = Get-Volume $_ | Select-Object -ExpandProperty HealthStatus
                    $drsts = {
                        if ($stat -cnotlike "Healthy") {
                            Write-Host "WARNING : Drive Status - Not Healthy" -ForegroundColor Red
                        }
                        else {
                            Write-Host "Drive Status - Healthy" -ForegroundColor Green
                        }
                    }
                    $Global:mnttyp = Get-Volume $_ | Select-Object -ExpandProperty DriveType
                    $ublty = {
                        if ($_ -clike $rawsysdrv[0]) {
                            Write-Warning "This is OS drive. Modification not reccomended."
                        }
                        else {
                            if ($mnttyp -clike "Removable") {
                                Write-Warning "This is a Removable Device."
                            } 
                            else {
                                Write-Host "This Drive may be used as VM Storage Pool" -ForegroundColor Green
                                &$tmsl
                                &$nslft
                            }
                        }
                    }
                    $tmppartuuid = Get-Volume $_ | Select-Object -ExpandProperty UniqueId
                    $uuid = $tmppartuuid.Replace("\\?\Volume{", "").Replace("}\", "")
                    $label = Get-Volume $_ | Select-Object -ExpandProperty FileSystemLabel
                    $lbl = {
                        if ($label -eq "") {
                            Write-Host "Partition Name - " -NoNewline
                            Write-Host "No Name Specified" -ForegroundColor Red
                        }
                        else {
                            Write-Host "Partition Name - " -NoNewline 
                            Write-Host " $label " -ForegroundColor Yellow
                        }
                    }
                    Write-Host "Drive Letter - $_"
                    Write-Host "Partition Format - $format"
                    Write-Host "Total Size - $totalspace GB"
                    Write-Host "Free Space - $freespace GB"
                    &$drsts 
                    &$lbl 
                    &$ublty
                    Write-Host "Partition ID - $uuid"
                    Write-Host $null
                    $slc++
                }
                $stup = {
                    $szscl = {
                        $dskc = $null
                        $rawfreesize = Get-Volume $tmstrp | Select-Object -ExpandProperty SizeRemaining
                        [int]$finalSize = $rawfreesize / 1024 / 1024 / 1024
                        $maxvoltmp = $finalSize * 0.5
                        $maxvol = [int]$maxvoltmp
                        Write-Host "You have $finalSize GB Remaining in drive $tmstrp"
                        Write-Host "Calculating maximum allowed Virtual Hard Drive size"
                        Start-Sleep 1
                        $subsdcstrgplsz = {
                            Write-Host "Specify a Virtual Disk size less than $maxvol GB"
                            $dskc = Read-Host -Prompt "Enter Volume size in GigaBytes"
                            $szchk = [Microsoft.VisualBasic.Information]::IsNumeric($dskc)
                            Write-Warning "Checking VM StrPoolRawSize"
                            Start-Sleep 1
                            if ($szchk -eq $true) {
                                [System.Console]::Beep(1000, 100)
                                Clear-Host
                                Write-Host "VM StrPoolRawSize Var-Type Pass" -ForegroundColor Green
                                $dskc = [int]$dskc
                                Write-Warning "Validating User Specified VM StrPoolRawSize"
                                Start-Sleep 1
                                if ($dskc -gt $maxvol) {
                                    [System.Console]::Beep(400, 250)
                                    Clear-Host
                                    Write-Host "Error: Specified Disk size exceeded the maximum allowable amount" -ForegroundColor Red
                                    Write-Warning "Resetting Storage Variable to 0 B"
                                    Start-Sleep 1
                                    Write-Host $null
                                    &$subsdcstrgplsz
                                }
                                elseif ($dskc -lt 10) {
                                    [System.Console]::Beep(400, 250)
                                    Clear-Host
                                    Write-Host "Error: This is less than Guest OS requirements" -ForegroundColor Red
                                    Start-Sleep 1
                                    Write-Host $null
                                    &$subsdcstrgplsz
                                }
                                else {
                                    Write-Warning "Setting Storage Space to $dskc GB"
                                    Start-Sleep 1
                                    $Global:disksize = $dskc
                                    [System.Console]::Beep(1000, 100)
                                    Write-Host "Done !" -ForegroundColor Green
                                    Start-Sleep 2
                                    Clear-Host
                                }
                            }
                            else {
                                [System.Console]::Beep(400, 250)
                                Clear-Host
                                Write-Host "Error: VM StrPoolRawSize Var-Type Fail" -ForegroundColor Red
                                Write-Host "VM StrPoolRawSize Must be a Neumeric Value"
                                Write-Host $null
                                Start-Sleep 1
                                &$subsdcstrgplsz
                            }
                        }
                        &$subsdcstrgplsz
                    }
                    $strp = $tmstrp + ":\"
                    Write-Warning "$tmstrp Drive has been selected"
                    $stropn = Read-Host -Prompt "Set the Current Drive as VM disk Root [Y]es or [N]o. Default [N]o"
                    if ($stropn -eq "y") {
                        Write-Warning "Setting $strp as VM Root"
                        Start-Sleep 1
                        $Global:strgpath = $strp
                        [System.Console]::Beep(1000, 100)
                        Write-Host "Done !" -ForegroundColor Green
                        Start-Sleep 2
                        Clear-Host
                        &$szscl
                    }
                    else {
                        $strgpath = $strp
                        $flclp = {
                            $flcopn = Read-Host "[L]ist items or [C]reate New Path. Default [L]ist items"
                            if ($flcopn -eq "C") {
                                $fllp = {
                                    $flnm = Read-Host -Prompt "Enter Folder Name"
                                    $Global:flnm = $flnm -replace "[^a-zA-Z0-9_]", ""
                                    Get-ChildItem $strgpath | Select-Object -ExpandProperty Name | ForEach-Object {
                                        if ($flnm -like $_) {
                                            [System.Console]::Beep(400, 250)
                                            Write-Host "Error: This Folder Already Exists" -ForegroundColor Red
                                            Write-Host $null
                                            $flnm = $null
                                            &$fllp
                                        }
                                        if ($flnm -eq "") {
                                            [System.Console]::Beep(400, 250)
                                            Write-Host "Error: Name can not be empty" -ForegroundColor Red
                                            Write-Host $null
                                            $flnm = $null
                                            &$fllp
                                        }
                                    }
                                }
                                &$fllp
                                Write-Warning "Creating Directory $flnm at Drive $strgpath"
                                New-Item -Path $strgpath -Name $flnm -ItemType Directory
                                Write-Host $null
                                Start-Sleep 1
                                Write-Warning "Setting new Path Variable"
                                Start-Sleep 1
                                [System.Console]::Beep(1000, 100)
                                Write-Host "Done !" -ForegroundColor Green
                                $strgpath = $strp + $flnm + "\"
                                $Global:strgpath = $strgpath
                                Write-Host "New Path Variable is $strgpath"
                                Start-Sleep 2
                                Clear-Host
                                &$szscl
                            }
                            else {
                                [System.Console]::Beep(400, 250)
                                Clear-Host
                                $contents = Get-ChildItem -Path $strgpath
                                $contents
                                Write-Host $null
                                &$flclp
                            }
                        }
                        &$flclp
                    }
                }
                $ssgl = {
                    [System.Console]::Beep(1000, 100)
                    $cssp = Read-Host -Prompt "Please Select a Drive Letter"
                    Write-Warning "Checking specified path"
                    Start-Sleep 1
                    if ($cssp -ne ".") {
                        $tmstrp = $cssp.ToUpper()
                        $Global:aplstrp = $tmstrp + ":\"
                        $pathstatus = Test-Path $aplstrp
                        if ($pathstatus -ne $true) {
                            [System.Console]::Beep(400, 250)
                            Write-Host "Invalid / Non-Existant path" -ForegroundColor Red
                            Start-Sleep 1
                            Clear-Host
                            &$ssgl
                        }
                        else {
                            $Global:mnttyp = Get-Volume $tmstrp | Select-Object -ExpandProperty DriveType
                            $Global:stat = Get-Volume $tmstrp | Select-Object -ExpandProperty HealthStatus
                            $rawtotalspace = Get-Volume $tmstrp | Select-Object -ExpandProperty Size
                            [int]$Global:totalspace = $rawtotalspace / 1024 / 1024 / 1024
                            $rawfreesize = Get-Volume $tmstrp | Select-Object -ExpandProperty SizeRemaining
                            [int]$Global:freespace = $rawfreesize / 1024 / 1024 / 1024
                            $acfsp = $totalspace * 0.25
                            $acfsp = [int]$acfsp
                            if ($mnttyp -clike "Removable") {
                                [System.Console]::Beep(400, 250)
                                Write-Host "Error: This is a Removable Device. Installation not recommended" -ForegroundColor Red
                                Start-Sleep 1
                                &$ssgl
                            }
                            if ($stat -cnotlike "Healthy") {
                                [System.Console]::Beep(400, 250)
                                Write-Warning "Drive Status - Not Healthy"
                                Write-Host "Installation not recommended" -ForegroundColor Red
                                Start-Sleep 1
                                &$ssgl
                            }
                            if ($totalspace -lt 50) {
                                [System.Console]::Beep(400, 250)
                                Write-Host "Partition Size Insufficent" -ForegroundColor Red
                                &$ssgl
                            }
                            if ($acfsp -gt $freespace) {
                                [System.Console]::Beep(400, 250)
                                Write-Host "Insufficient Space Remaining" -ForegroundColor Red
                                &$ssgl
                            }
                            if ($tmstrp -clike $rawsysdrv[0]) {
                                [System.Console]::Beep(400, 250)
                                Write-Warning "This is the OS Drive"
                                $ks = Read-Host -Prompt "Do you want to proceed? [Y]es or [No]. Default [N]o"
                                if ($ks -eq "y") {
                                    &$stup
                                }
                                else {
                                    Write-Host "Returning to Drive Selection" -ForegroundColor Red
                                    Start-Sleep 1
                                    &$ssgl
                                }
                            }
                            else {
                                &$stup
                            }
                        }
                    }
                    else {
                        [System.Console]::Beep(400, 250)
                        Write-Host "Invalid / Non-Existant path" -ForegroundColor Red
                        Start-Sleep 1
                        Clear-Host
                        &$ssgl
                    }
                }
                &$ssgl
            }
            &$dsstr
            $dssvmsws = {
                $tmpsws = Get-VMSwitch
                if ($tmpsws -eq $null) {
                    [System.Console]::Beep(400, 250)
                    Write-Host "Error: No VMSwitch Found!" 
                    Write-Host "Check if Hyper-V has network access"
                    Exit
                }
                else {
                    [System.Console]::Beep(1000, 100)
                    $swcnt = Get-VMSwitch | Select-Object -ExpandProperty Name
                    Write-Host $swcnt.Count -ForegroundColor Yellow -NoNewline
                    Write-Host " VMSwitch Detected"
                    Start-Sleep 1
                    Write-Warning "Searching For External Switches"
                    Start-Sleep 1
                    $scrtc = Get-VMSwitch | Select-Object -ExpandProperty SwitchType | Where-Object { $_ -eq "external" }
                    if ($scrtc -eq "external") {
                        [System.Console]::Beep(1000, 100)
                        Write-Host "External Switch Found" -ForegroundColor Green
                        $swc = Get-VMSwitch | Select-Object -ExpandProperty Name
                        for ($i = 0; $i -lt $swc.Count) {
                            $swtextr = Get-VMSwitch $swc[$i] | Select-Object -ExpandProperty SwitchType
                            if ($swtextr -eq "external") {
                                [System.Console]::Beep(1000, 100)
                                Write-Host "External Switch Check Pass!" -ForegroundColor Green
                                [string]$scs = $swc[$i]
                                Write-Warning "Setting $scs as VM Switch"
                                Start-Sleep 1
                                $Global:switchid = $swc[$i]
                                [System.Console]::Beep(1000, 100)
                                Write-Host "Done !" -ForegroundColor Green
                                Start-Sleep 2
                                break
                                Clear-Host
                            }
                            $i++
                        }
                    }
                    else {
                        [System.Console]::Beep(400, 250)
                        Write-Host "Error: No External Switch Detected"
                        Write-Warning "Launching VMSwitch Creator"
                        Start-Sleep 1
                        $swsnm = Read-Host "Specify External Switch Name"
                        $Global:switchid = $swsnm -replace "[^a-zA-Z0-9_]", ""
                        [System.Console]::Beep(1000, 100)
                        Write-Warning "Creating External Switch $switchid"
                        Start-Sleep 1
                        New-VMSwitch -name $switchid  -NetAdapterName Ethernet -AllowManagementOS $true
                        [System.Console]::Beep(1000, 100)
                        Write-Host "Done !" -ForegroundColor Green
                        Start-Sleep 2
                        Clear-Host
                    }
                }
            }
            &$dssvmsws
            $imgchk = {
                Write-Host "Go to image, right-click and select copy as path"
                $tmpimgpath = Read-Host "Enter Image Path"
                $tmpimgpath = $tmpimgpath -replace "`"", ""
                $lvlx = Test-Path $tmpimgpath 
                if ($lvlx -eq $true) {
                    Write-Warning "Setting image path"
                    $Global:imagepath = $tmpimgpath
                    [System.Console]::Beep(1000, 100)
                    Write-Host "Done !" -ForegroundColor Green
                    Start-Sleep 2
                    Clear-Host
                }
                else {
                    Clear-Host
                    [System.Console]::Beep(400, 250)
                    Write-Host "Error: Invalid image path" -ForegroundColor Red
                    Write-Host $null
                    &$imgchk
                }
            }
            &$imgchk
            $valprov = {
                [System.Console]::Beep(1000, 100)
                Write-Warning "Validating Guest Settings with respect to System Resources"
                Start-Sleep 5
                $Global:logicalcorecount = (Get-CimInstance Win32_ComputerSystem | Select-Object -ExpandProperty NumberOfLogicalProcessors)
                $crtst = $logicalcorecount * 0.8
                [int]$gtbcpu = $Global:numvm * $cpu 

                $tmpphysicalmem = (Get-CimInstance Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory)
                $cvphysicalmem = $tmpphysicalmem / 1024 / 1024 / 1024
                $Global:physicalmem = [int]$cvphysicalmem
                $memtst = $Global:physicalmem * 0.8
                $gtbmaxram = $Global:numvm * $Global:maxram
                $gtbstartram = ($Global:numvm * $Global:startram) / 1024 / 1024
                $gtbbaseram = $Global:numvm * $Global:baseram

                $rawfreesize = Get-Volume $aplstrp[0] | Select-Object -ExpandProperty SizeRemaining
                [int]$finalSize = $rawfreesize / 1024 / 1024 / 1024
                $szrtst = $finalSize * 0.8
                $gtbdisksize = $Global:disksize * $Global:numvm

                $rstcpu = {
                    $Global:cpu = Read-Host -Prompt "Re-Specify VM CPU CC"
                    [int]$gtbcpu = $Global:numvm * $Global:cpu
                    if ($Global:cpu -lt 1) {
                        [System.Console]::Beep(400, 250)
                        Write-Host "Insufficient for Guest OS" -ForegroundColor Red
                        &$rstcpu
                    }
                    if ($gtbcpu -gt $crtst) {
                        [System.Console]::Beep(400, 250)
                        Write-Host "Too many cores assigned" -ForegroundColor Red
                        &$rstcpu
                    }
                }

                $rstmaxram = {
                    $Global:maxram = Read-Host -Prompt "Re-Specify VM Mem upper limit (GB)"
                    [int]$gtbmaxram = $Global:numvm * $Global:maxram
                    if ($gtbmaxram -gt $memtst) {
                        [System.Console]::Beep(400, 250)
                        Write-Host "Error: Insufficient system memory" -ForegroundColor Red
                        $Global:maxram = 0
                        &$rstmaxram
                    }
                }

                $rstbaseram = {
                    $Global:baseram = Read-Host -Prompt "Respecify VM Mem lower limit (GB)"
                    [int]$gtbbaseram = $Global:numvm * $Global:baseram
                    if ($gtbbaseram -gt $memtst) {
                        [System.Console]::Beep(400, 250)
                        Write-Host "Error: Unstable Boot condition" -ForegroundColor Red
                        $Global:baseram = 0
                        &$rstbaseram
                    }
                }

                $rststartram = {
                    [System.Console]::Beep(500, 70)
                    [System.Console]::Beep(500, 70)
                    Write-Host "Is the guest os Memory Intensive?"
                    $dscstrram = Read-Host -Prompt "[Y]es, [N]o. Default [N]o"
                    if ($dscstrram -eq "y") {
                        Write-Warning "Setting VM Boot Mem to 1GB"
                        Start-Sleep 1
                        $Global:startram = 1
                        [System.Console]::Beep(1000, 100)
                        Write-Host "Done !" -ForegroundColor Green
                        Start-Sleep 2
                        Clear-Host
                    }
                    else {
                        Write-Warning "Setting VM Boot Mem to 512MB"
                        Start-Sleep 1
                        $Global:startram = 512
                        [System.Console]::Beep(1000, 100)
                        Write-Host "Done !" -ForegroundColor Green
                        Start-Sleep 2
                        Clear-Host
                    }
                }

                $rststrg = {
                    $Global:disksize = Read-Host -Prompt "Re-Specify VM Disk Size (GB)"
                    $gtbdisksize = ($Global:numvm * $Global:disksize)
                    if ([int]$Global:disksize -lt 10) {
                        [System.Console]::Beep(400, 250)
                        Write-Host "Insifficient for Guest OS" -ForegroundColor Red
                        $Global:disksize = 0
                        &$rststrg
                    }
                    elseif ($gtbdisksize -gt $szrtst) {
                        [System.Console]::Beep(400, 250)
                        Write-Host "Error: Insufficient System Storage" -ForegroundColor Red
                        $Global:disksize = 0
                        &$rststrg
                    }
                }
    
                if ($gtbcpu -gt $crtst) {
                    [System.Console]::Beep(400, 250)
                    Write-Host "Error: Insufficient system cores" -ForegroundColor Red
                    &$rstcpu
                }
                if ($gtbmaxram -gt $memtst) {
                    [System.Console]::Beep(400, 250)
                    Write-Host "Error: Insufficient system memory" -ForegroundColor Red
                    &$rstmaxram
                }
                if ($gtbbaseram -gt $memtst) {
                    [System.Console]::Beep(400, 250)
                    Write-Host "Error: Unstable Boot condition" -ForegroundColor Red
                    &$rstbaseram
                }
                if ($gtbstartram -gt $memtst) {
                    [System.Console]::Beep(400, 250)
                    Write-Host "Error: Insufficient System Resources" -ForegroundColor Red
                    Write-Host "Error: Fatal Boot State"
                    &$rststartram
                }
                if ($gtbdisksize -gt $szrtst) {
                    [System.Console]::Beep(400, 250)
                    Write-Host "Error: Insufficient System Storage" -ForegroundColor Red
                    &$rststrg
                }

                [System.Console]::Beep(1000, 100)
                Write-Host "Validation Complete !" -ForegroundColor Green
                Start-Sleep 2
                Clear-Host

            }
            &$valprov
            &$fcommandgenM
        }
        elseif ($ipn -eq "r") {
            Clear-Host
            &$base
            &$selection
        }
        else {
            Write-Host "Try again"
            &$ds2
        }
    }
    &$ds2
}

#MainMenu
$Global:selection = {
    $options = Read-Host -Prompt "Select an option"
    if ($options -eq 1) {
        Clear-Host
        [System.Console]::Beep(250, 300)
        &$sysvm
        &$ds1
    }
    elseif ($options -eq 2) {
        Clear-Host
        [System.Console]::Beep(250, 300)
        Write-Warning "Initiating Single VM Creation Wizard"
        Start-Sleep 1
        &$singlevm
    }
    elseif ($options -eq 3) {
        Clear-Host
        [System.Console]::Beep(250, 300)
        Write-Warning "Initiating Multiple VM Creation Wizard"
        &$multivm
        Start-Sleep 1
    }
    elseif ($options -eq 4) {
        Clear-Host
        [System.Console]::Beep(250, 300)
        &$gdtvmvue
        Start-Sleep 1
    }
    elseif ($options -eq 5) {
        Write-Host "Exiting"
        Start-Sleep 1
        [System.Console]::Beep(2000, 100)
        [System.Console]::Beep(500, 100)
        [System.Console]::Beep(2000, 100)
        [System.Console]::Beep(500, 100)
    }
    else {
        Write-Host "Please Try Again"
        Start-Sleep 1
        Clear-Host
        &$base
        &$selection
    }
}


#InitiateShell
&$psproc
&$chkhV
&$base
&$selection
