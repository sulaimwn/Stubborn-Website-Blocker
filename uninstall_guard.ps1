# SocialBlocker uninstall guard
# This script prevents easy uninstallation

$installDir = "C:\Program Files\SocialBlocker"

# Set permissions to prevent deletion
$acl = Get-Acl $installDir
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")
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

Set-ItemProperty -Path $runPath -Name "SocialBlocker" -Value $runValue -Force
Set-ItemProperty -Path $runOncePath -Name "SocialBlocker" -Value $runValue -Force
Set-ItemProperty -Path $runServicesPath -Name "SocialBlocker" -Value $runValue -Force

# Add environment variable
$envPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($envPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$envPath;$installDir", "User")
}
