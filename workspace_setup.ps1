if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function Check-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# -----------------------------------------------------------------------------
$computerName = Read-Host 'Enter New Computer Name'
Write-Host "Renaming this computer to: " $computerName  -ForegroundColor Yellow
Rename-Computer -NewName $computerName
# -----------------------------------------------------------------------------
# Remove Rubbish packages
# -----------------------------------------------------------------------------

# To list all appx packages:
# Get-AppxPackage | Format-Table -Property Name,Version,PackageFullName
Write-Host "Removing UWP Rubbish..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$uwpRubbishApps = @(
    "king.com.CandyCrushSaga",
    "Fitbit.FitbitCoach")

foreach ($uwp in $uwpRubbishApps) {
    Get-AppxPackage -Name $uwp | Remove-AppxPackage
}
# -----------------------------------------------------------------------------
# Start intallation of Choco and libraries
# -----------------------------------------------------------------------------

if (Check-Command -cmdname 'choco') {
    Write-Host "Choco is already installed, skip installation."
}
else {
    Write-Host ""
    Write-Host "Installing Chocolate for Windows..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

Write-Host ""
Write-Host "Installing Applications..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

$Apps = @(
    "7zip.install",
    "git",
    "potplayer",
    "dotnetcore-sdk",
    "wget",
    "openssl.light",
    "vscode",
    "notepadplusplus.install",
    "wireshark",
    "postman",
    "nuget.commandline",
    "kdiff3",
    "filezilla",
    "zoom",
    "microsoft-teams.install",
    "motrix",
    "github-desktop",
    "drawio",
    "vscode-drawio",	
    "nodejs-lts",
    "azure-cli",
    "docker-desktop",
    "powershell-core")

foreach ($app in $Apps) {
    choco install $app -y
}


# WSL enable
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Install WSL 2 msi
Start-Process msiexec.exe -Wait -ArgumentList '/I C:\Users\siddh\Downloads /quiet'

Write-Host "------------------------------------" -ForegroundColor Green
Read-Host -Prompt "Setup is done, restart is needed, press [ENTER] to restart computer."
Restart-Computer