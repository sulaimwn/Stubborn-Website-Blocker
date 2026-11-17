# SocialBlocker block script
# This script adds entries to the hosts file for selected sites and restores scheduled tasks

$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$sitesToBlock = @(
    "instagram.com",
    "www.instagram.com", 
    "tiktok.com",
    "www.tiktok.com",
    "x.com",
    "www.x.com"
)

# Function to restore scheduled tasks
function Restore-ScheduledTasks {
    $installDir = "C:\Program Files\SocialBlocker"
    $blockScript = "`"$installDir\block_hosts.ps1`""
    
    # Check if SocialBlockerRestore task exists
    $restoreTaskExists = Get-ScheduledTask -TaskName "SocialBlockerRestore" -ErrorAction SilentlyContinue
    if (-not $restoreTaskExists) {
        Write-Host "Restoring SocialBlockerRestore task..."
        $taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $blockScript"
        $taskTrigger = New-ScheduledTaskTrigger -AtLogOn
        Register-ScheduledTask -TaskName "SocialBlockerRestore" -Action $taskAction -Trigger $taskTrigger -Force
    }
    
    # Check if SocialBlockerWatchdog task exists
    $watchdogTaskExists = Get-ScheduledTask -TaskName "SocialBlockerWatchdog" -ErrorAction SilentlyContinue
    if (-not $watchdogTaskExists) {
        Write-Host "Restoring SocialBlockerWatchdog task..."
        $taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File $blockScript"
        $taskTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration (New-TimeSpan -Days 9999)
        Register-ScheduledTask -TaskName "SocialBlockerWatchdog" -Action $taskAction -Trigger $taskTrigger -Force
    }
}

# Function to protect hosts file entries
function Protect-HostsEntries {
    $hostsPath = "C:\Windows\System32\drivers\etc\hosts"
    
    # Read existing hosts file
    $existingContent = Get-Content $hostsPath -ErrorAction SilentlyContinue
    
    # Add SocialBlocker header if not present
    $headerPresent = $false
    foreach ($line in $existingContent) {
        if ($line -match "# SocialBlocker entries") {
            $headerPresent = $true
            break
        }
    }
    
    if (-not $headerPresent) {
        # Add header before our entries
        $header = "`n# SocialBlocker entries - Do not modify below this line`n"
        Add-Content $hostsPath $header
    }
}

# Restore scheduled tasks first
Restore-ScheduledTasks

# Protect hosts file entries
Protect-HostsEntries

# Read existing hosts file
$existingContent = Get-Content $hostsPath -ErrorAction SilentlyContinue

# Add entries if they don't exist
foreach ($site in $sitesToBlock) {
    $entry = "127.0.0.1    $site"
    if ($existingContent -notcontains $entry) {
        try {
            Add-Content $hostsPath $entry
        } catch {
            Write-Host "Could not add entry for $site, hosts file may be in use"
        }
    }
}
