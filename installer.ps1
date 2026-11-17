# SocialBlocker Installer
# This script installs SocialBlocker with a GUI for selecting sites to block

# Define default blocked sites
$defaultSites = @(
    "instagram.com",
    "www.instagram.com", 
    "tiktok.com",
    "www.tiktok.com",
    "x.com",
    "www.x.com"
)

# Show GUI for site selection
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text = "SocialBlocker Site Selection"
$form.Size = New-Object System.Drawing.Size(400,350)
$form.StartPosition = "CenterScreen"

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(360,20)
$label.Text = "Select sites to block (default: all selected):"
$form.Controls.Add($label)

$checkedListBox = New-Object System.Windows.Forms.CheckedListBox
$checkedListBox.Location = New-Object System.Drawing.Point(10,50)
$checkedListBox.Size = New-Object System.Drawing.Size(360,150)
$checkedListBox.CheckOnClick = $true

# Add default sites to the list
foreach ($site in $defaultSites) {
    $checkedListBox.Items.Add($site)
}

# Select all by default
for ($i = 0; $i -lt $checkedListBox.Items.Count; $i++) {
    $checkedListBox.SetItemChecked($i, $true)
}

$form.Controls.Add($checkedListBox)

# Add text box for custom sites
$customLabel = New-Object System.Windows.Forms.Label
$customLabel.Location = New-Object System.Drawing.Point(10,210)
$customLabel.Size = New-Object System.Drawing.Size(360,20)
$customLabel.Text = "Add custom sites (one per line):"
$form.Controls.Add($customLabel)

$customTextBox = New-Object System.Windows.Forms.TextBox
$customTextBox.Location = New-Object System.Drawing.Point(10,230)
$customTextBox.Size = New-Object System.Drawing.Size(360,50)
$customTextBox.Multiline = $true
$customTextBox.ScrollBars = "Vertical"
$form.Controls.Add($customTextBox)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(150,290)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = "OK"
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $selectedSites = @()
    
    # Get selected default sites
    for ($i = 0; $i -lt $checkedListBox.Items.Count; $i++) {
        if ($checkedListBox.GetItemChecked($i)) {
            $selectedSites += $checkedListBox.Items[$i]
        }
    }
    
    # Get custom sites from text box
    $customSites = $customTextBox.Text.Split("`n") | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    foreach ($site in $customSites) {
        # Add www prefix if not present
        if ($site -notlike "*www.*" -and $site -notlike "*.*") {
            $selectedSites += "www.$site"
        }
        $selectedSites += $site
    }
    
    # Remove duplicates
    $selectedSites = $selectedSites | Select-Object -Unique
} else {
    # If user cancels, use default sites
    $selectedSites = $defaultSites
}

# Install directory
$installDir = "C:\Program Files\SocialBlocker"
if (!(Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir | Out-Null
}

# Copy files (assuming they exist in current directory)
Copy-Item ".\block_hosts.ps1" "$installDir\" -Force
Copy-Item ".\uninstall_guard.ps1" "$installDir\" -Force

# Create block_hosts.ps1 with selected sites
$blockScriptContent = @"
# SocialBlocker block script
# This script adds entries to the hosts file for selected sites

`$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
`$sitesToBlock = @(
"@

foreach ($site in $selectedSites) {
    $blockScriptContent += "    `"$site`",`n"
}

$blockScriptContent += @"
)

# Read existing hosts file
`$existingContent = Get-Content `$hostsPath -ErrorAction SilentlyContinue

# Add entries if they don't exist
foreach (`$site in `$sitesToBlock) {
    `$entry = "127.0.0.1    `$site"
    if (`$existingContent -notcontains `$entry) {
        Add-Content `$hostsPath `$entry
    }
}
"@

$blockScriptContent | Out-File "$installDir\block_hosts.ps1" -Force

# Create uninstall_guard.ps1
$guardScriptContent = @"
# SocialBlocker uninstall guard
# This script prevents easy uninstallation

`$installDir = "C:\Program Files\SocialBlocker"

# Set permissions to prevent deletion
`$acl = Get-Acl `$installDir
`$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users", "ReadAndExecute", "ContainerInherit, ObjectInherit", "None", "Allow")
`$acl.AddAccessRule(`$rule)
Set-Acl -Path `$installDir -AclObject `$acl

# Hide the folder
attrib +h +s "`$installDir"
"@

$guardScriptContent | Out-File "$installDir\uninstall_guard.ps1" -Force

# Create scheduled tasks
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$installDir\block_hosts.ps1`""
$taskTrigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName "SocialBlockerRestore" -Action $taskAction -Trigger $taskTrigger -Force

# Fix for SocialBlockerWatchdog trigger
$taskTrigger2 = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration (New-TimeSpan -Days 9999)
Register-ScheduledTask -TaskName "SocialBlockerWatchdog" -Action $taskAction -Trigger $taskTrigger2 -Force

# Apply initial block
& "$installDir\block_hosts.ps1"

# Show completion message
Add-Type -AssemblyName System.Windows.Forms
$doneForm = New-Object System.Windows.Forms.Form
$doneForm.Text = "Installation Complete"
$doneForm.Size = New-Object System.Drawing.Size(300,150)
$doneForm.StartPosition = "CenterScreen"

$doneLabel = New-Object System.Windows.Forms.Label
$doneLabel.Location = New-Object System.Drawing.Point(20,20)
$doneLabel.Size = New-Object System.Drawing.Size(260,60)
$doneLabel.Text = "SocialBlocker installed successfully!`nBlocked sites: $($selectedSites -join ', ')"
$doneForm.Controls.Add($doneLabel)

$doneButton = New-Object System.Windows.Forms.Button
$doneButton.Location = New-Object System.Drawing.Point(100,90)
$doneButton.Size = New-Object System.Drawing.Size(100,23)
$doneButton.Text = "OK"
$doneButton.Add_Click({
    $doneForm.Close()
})
$doneForm.Controls.Add($doneButton)

[void]$doneForm.ShowDialog()
