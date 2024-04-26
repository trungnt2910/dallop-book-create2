rem configure.cmd VNC_USER_PASSWORD VNC_PASSWORD NGROK_AUTH_TOKEN TAILSCALE_AUTHKEY

rem Install and setup ngrok
choco install ngrok
ngrok authtoken %3
echo Starting ngrok...
powershell -Command "Start-Process Powershell -ArgumentList '-Noexit -Command "ngrok.exe tcp 3389"'"

rem Enable RDP
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
powershell -Command "Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'"
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f

rem Enable services for RDP
net config server /srvcomment:"Windows Server 2022"
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /V EnableAutoTray /T REG_DWORD /D 0 /F
net user RDP_USER %1 /add
net localgroup administrators RDP_USER /add
net user administrator /active:yes
net user installer /delete
diskperf -Y
sc config Audiosrv start= auto
sc start audiosrv
ICACLS C:\Windows\Temp /grant RDP_USER:F
ICACLS C:\Windows\installer /grant RDP_USER:F

rem Install and setup Tailscale
curl -SLOJ https://pkgs.tailscale.com/stable/tailscale-setup-latest-amd64.msi
powershell -Command "Start-Process msiexec.exe -Wait -ArgumentList '/passive /i tailscale-setup-*-amd64.msi'"
RefreshEnv
tailscale up --authkey %4

rem Other stuff
