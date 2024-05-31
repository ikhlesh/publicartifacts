# Variables
$LocalPath = "C:\Tools"
$folders = "Teams", "RemoteDesktopWebRTC"
Set-Location -Path $LocalPath

# Create directory if it doesn't exist
New-Item -Path "C:\Tools" -ItemType Directory -Force -ErrorAction SilentlyContinue
$folders | ForEach-Object { New-Item -Path (Join-Path -Path $basePath -ChildPath $_) -ItemType Directory -Force }


# install webSoc svc
$webSocketsURL = 'https://aka.ms/msrdcwebrtcsvc/msi'
$webSocketsInstallerMsi = 'MsRdcWebRTCSvc_HostSetup_1.50.2402.29001_x64'
 write-host 'AIB Customization: Install the Teams WebSocket Service' 
 $outputPath = $LocalPath + '\RemoteDesktopWebRTC\' + $webSocketsInstallerMsi
 Invoke-WebRequest -Uri $webSocketsURL -OutFile $outputPath
 Start-Process -FilePath msiexec.exe -Args "/I $outputPath /quiet /norestart /log webSocket.log" -Wait
 write-host 'AIB Customization: Finished Install the Teams WebSocket Service'

#Teams
$teamsURL = 'https://go.microsoft.com/fwlink/?linkid=2196106'
$teamsMsix = 'MSTeams-x64.msix'
$outputPath = $LocalPath + '\Teams\' + $teamsMsix
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Name IsWVDEnvironment -PropertyType DWORD -Value 1 -Force

# Download the Teams MSIX file
Invoke-WebRequest -Uri $teamsURL -OutFile $outputPath -ErrorAction Stop

# Install Teams quietly using Add-AppxPackage
Add-AppxPackage -Path $outputPath

#Enable hardware encode for Teams on Azure Virtual Desktop
$registryPath = "HKCU:\SOFTWARE\Microsoft\Terminal Server Client\Default\AddIns\WebRTC Redirector"
New-Item -Path $registryPath -Force | Out-Null
Set-ItemProperty -Path $registryPath -Name "UseHardwareEncoding" -Value 1

#newchange