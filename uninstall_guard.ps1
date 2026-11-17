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
