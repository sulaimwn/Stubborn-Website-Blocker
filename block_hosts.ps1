# SocialBlocker block script
# This script adds entries to the hosts file for selected sites

$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$sitesToBlock = @(
    "instagram.com",
    "www.instagram.com", 
    "tiktok.com",
    "www.tiktok.com",
    "x.com",
    "www.x.com"
)

# Read existing hosts file
$existingContent = Get-Content $hostsPath -ErrorAction SilentlyContinue

# Add entries if they don't exist
foreach ($site in $sitesToBlock) {
    $entry = "127.0.0.1    $site"
    if ($existingContent -notcontains $entry) {
        Add-Content $hostsPath $entry
    }
}
