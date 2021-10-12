# # Supress network location Prompt
# New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force
#
# # Set network to private
# $ifaceinfo = Get-NetConnectionProfile
# Set-NetConnectionProfile -InterfaceIndex $ifaceinfo.InterfaceIndex -NetworkCategory Private
#
# # Set up WinRM and configure some things
# winrm quickconfig -q
# winrm s "winrm/config" '@{MaxTimeoutms="1800000"}'
# winrm s "winrm/config/winrs" '@{MaxMemoryPerShellMB="2048"}'
# winrm s "winrm/config/service" '@{AllowUnencrypted="true"}'
# winrm s "winrm/config/service/auth" '@{Basic="true"}'
#
# # Enable the WinRM Firewall rule, which will likely already be enabled due to the 'winrm quickconfig' command above
# Enable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"
#
# sc.exe config winrm start= auto
#
# exit 0

$NetworkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$Connections = $NetworkListManager.GetNetworkConnections()
$Connections | ForEach-Object { $_.GetNetwork().SetCategory(1) }

Enable-PSRemoting -Force
winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'
netsh advfirewall firewall set rule group="Windows Remote Administration" new enable=yes
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=allow
Set-Service winrm -startuptype "auto"
Restart-Service winrm
