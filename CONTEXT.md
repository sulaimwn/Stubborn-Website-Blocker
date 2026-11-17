# Project Context

## Project name
SocialBlocker

## What this project is
A Windows 11 site blocker that behaves like stubborn malware.
It should be impossible to disable or uninstall through normal user actions.
It must block specified sites in Chrome, Edge, and Firefox.

## Target platform
Windows 11

## Core features
- GUI-based site selection during installation
- Persistent blocking that survives reboots and logins
- Stubborn uninstall protection
- Minimal system footprint

## Blocked websites
- Configurable via GUI during installation
- Default: instagram.com, www.instagram.com, tiktok.com, www.tiktok.com, x.com, www.x.com

## Supported browsers
- Chrome
- Edge
- Firefox

## Install folder
C:\Program Files\SocialBlocker

## Persistence mechanisms (malware-like behaviour)
1. Scheduled tasks
   - SocialBlockerRestore: Runs at startup and user logon
   - SocialBlockerWatchdog: Runs every 5 minutes
   - Both tasks run the block script to ensure persistence

2. Anti-uninstall protection
   - Folder is hidden and has restricted permissions
   - Users can only read/execute, not modify or delete
   - No uninstaller provided (users must discover it exists first)

3. Hosts file protection
   - Entries are added to C:\Windows\System32\drivers\etc\hosts
   - Point blocked domains to 127.0.0.1
   - No easy way for users to identify/modify these entries

4. Registry persistence (future enhancement)
   - Add registry entries for extra startup persistence

## Blocking method
- Edit the Windows hosts file at C:\Windows\System32\drivers\etc\hosts
- Point the blocked domains to 127.0.0.1
- block_hosts.ps1 is responsible for adding or restoring those entries
- SocialBlockerWatchdog scheduled task re-applies the block when needed

## Anti-uninstall behaviour
- installer.ps1 installs files and creates scheduled tasks
- uninstall_guard.ps1 protects the install from being removed or disabled
- The scheduled tasks should restore each other if one is deleted
- No normal visible uninstaller - users must discover SocialBlocker exists
- Folder is hidden: users can't easily find it in C:\Program Files

## Current limitations
- No registry persistence
- Tasks can be disabled through Task Scheduler
- Hosts file entries can be manually edited
- No way to prevent users from deleting scheduled tasks

## Exact project file list
- CONTEXT.md
- installer.ps1
- block_hosts.ps1
- uninstall_guard.ps1

## File responsibilities
- CONTEXT.md: Stores project context and current status
- installer.ps1: Installs SocialBlocker, creates scheduled tasks, applies initial block
- block_hosts.ps1: Adds/restores hosts file entries for blocked domains
- uninstall_guard.ps1: Sets folder permissions and hides it

## Current status
- Basic blocking functionality implemented
- GUI site selection working
- Scheduled tasks for persistence
- Anti-uninstall protection in place
- Missing: registry persistence, task restoration, hosts file protection

## Next part to work on
Enhance persistence mechanisms:
1. Make scheduled tasks restore each other if deleted
2. Add hosts file entry protection
3. Add registry persistence

## Continue rule
On a new session, read this file and continue from "Next part to work on".
Work on only one part at a time.
After finishing a part, update this file with the new status and the next part.
