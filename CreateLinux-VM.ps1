#Requires -RunAsAdministrator
#Requires -Modules Hyper-V

$Name = "kali-linux-2024.1-hyperv-amd64"
$Description = "Kali Rolling (2024.1) x64
2024-02-25

- - - - - - - - - - - - - - - - - -

Username: kali
Password: kali
(US keyboard layout)

- - - - - - - - - - - - - - - - - -

* Kali Homepage:
https://www.kali.org/

* Kali Documentation:
https://www.kali.org/docs/

* Kali Tools:
https://www.kali.org/tools/

* Forum/Community Support:
https://forums.kali.org/

* Community Chat:
https://discord.kali.org"

New-VM `
  -Generation 2 `
  -Name "$Name" `
  -MemoryStartupBytes 2048MB `
  -SwitchName "Default Switch" `
  -VHDPath ".\kali-linux-2024.1-hyperv-amd64.vhdx"

Set-VM -Name "$Name" -Notes "$Description"
Set-VM -Name "$Name" -EnhancedSessionTransportType HVSocket
Set-VMFirmware -VMName "$Name" -EnableSecureBoot Off
Set-VMProcessor -VMName "$Name" -Count 2
Enable-VMIntegrationService -VMName "$Name" -Name "Guest Service Interface"

Write-Host ""
Write-Host "Your Kali Linux virtual machine is ready."
Write-Host "In order to use it, please start: Hyper-V Manager"
Write-Host "For more information please see:"
Write-Host "https://www.kali.org/docs/virtualization/import-premade-hyper-v/"
Write-Host ""
