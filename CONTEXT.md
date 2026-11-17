# Project Context

## Project name
SocialBlocker

## What this project is
A Windows 11 blocker for Instagram and TikTok that behaves like malware.
It should be impossible to disable or uninstall through normal user actions.
It must block Instagram and TikTok in Chrome, Edge, and Firefox.

## Target platform
Windows 11

## Blocked websites
- instagram.com
- www.instagram.com
- tiktok.com
- www.tiktok.com

## Supported browsers
- Chrome
- Edge
- Firefox

## Install folder
C:\Program Files\SocialBlocker

## Scheduled tasks (instead of Windows service)
- SocialBlockerRestore
  - Runs at startup and user logon.
  - Restores the service, install files, and hosts entries if they are missing.
- SocialBlockerWatchdog
  - Runs every 5 minutes.
  - Checks that SocialBlockerService is running and that the block is still active.

## Blocking method
- Edit the Windows hosts file at C:\Windows\System32\drivers\etc\hosts.
- Point the blocked domains to 127.0.0.1.
- block_hosts.ps1 is responsible for adding or restoring those entries.
- SocialBlockerWatchdog scheduled task re-applies the block when it detects the hosts file was changed.

## Persistence and anti-uninstall behaviour
- installer.ps1 installs the files, registers the Windows service, creates the scheduled tasks.
- uninstall_guard.ps1 protects the install from being removed or disabled.
- The scheduled tasks should restore each other if one is deleted or stopped.
- There is no normal visible uninstaller unless one is explicitly added later.

## Exact project file list
- CONTEXT.md
- installer.ps1
- block_hosts.ps1
- uninstall_guard.ps1

## File responsibilities
- CONTEXT.md: stores the full project context so work can continue after a chat clear.
- installer.ps1: installs SocialBlocker into C:\Program Files\SocialBlocker, registers the service, creates the scheduled tasks, and applies the initial block.
- block_hosts.ps1: adds or restores the hosts file entries for the blocked domains.
- uninstall_guard.ps1: prevents the blocker from being easily disabled or uninstalled.

## Current status
- Project context is defined.
- No implementation files have been created yet.

## Next part to work on
Define installer.ps1.

## Continue rule
On a new session, read this file and continue from "Next part to work on".
Work on only one part at a time.
After finishing a part, update this file with the new status and the next part.
