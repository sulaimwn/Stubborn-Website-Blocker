# SocialBlocker

A Windows site blocker that behaves like stubborn malware. You pick the sites, it blocks them across every browser, and it keeps restoring the block if something tries to remove it.

I built this because normal blockers never stuck for me. They were always one uninstall away, so the second I wanted to scroll, I'd just turn them off. The point of this one is to put enough friction between me and the off-switch that impulse alone isn't enough to get past it.

## What it does

- Blocks any sites you list (Instagram, TikTok, X, or whatever you add) across Chrome, Edge, Firefox, and everything else on the machine.
- Reapplies itself automatically. If the block gets removed or edited, a background task puts it back within a few minutes.
- Runs at the system level, so it isn't tied to one browser or one user profile.
- Is stubborn to uninstall - there's no easy "off switch".

## How it works

The blocking itself is simple and boring on purpose, which is what makes it reliable:

1. **Hosts file.** The installer adds entries to the Windows hosts file (`C:\Windows\System32\drivers\etc\hosts`) that point each blocked domain at `127.0.0.1`. Because the hosts file is read by the OS before any DNS lookup, this blocks the sites in every browser and app at once, no extensions required.
2. **Scheduled tasks** run in the background as SYSTEM on a short interval. They check that the hosts entries are still there and reapplies them if they're missing. This is the "stubborn" part: deleting the block by hand doesn't last, because the task restores it on the next pass.
3. **Startup trigger.** The tasks also run at boot and logon, so the block survives restarts.
4. **Multiple persistence layers** - registry entries, environment variables, confusing folders, and more make it hard to completely uninstall.

That's the whole mechanism. No kernel drivers, no firmware tricks, nothing hidden from you. It's friction, not a trap (see Removing it below).

## Requirements

- Windows 10 or 11
- Administrator rights (it edits system files and registers scheduled tasks)
- PowerShell (built into Windows)

## Install

1. Download the latest release or clone this repo.
2. Double-click `SocialBlocker.ps1` to run it.
3. If prompted for administrator privileges, click "Yes".
4. The GUI will appear - select which sites to block and add custom sites if needed.
5. Click "OK" and you're done!

## Configuring the blocked sites

During installation, you can:
- Select from default sites (Instagram, TikTok, X, etc.)
- Add custom sites by typing them in the text box (one per line)
- The installer automatically adds both the bare domain and `www.` version

## How this was built

This was built using PowerShell and various tools:

- **Language:** PowerShell
- **GUI:** Windows Forms
- **Persistence:** Scheduled tasks, registry entries, environment variables
- **Uninstall complexity:** Multiple folders, registry entries, and shortcuts

## Warnings

- **Antivirus may flag it.** A tool that edits the hosts file and runs self-restoring scheduled tasks looks, to a scanner, a lot like the techniques unwanted software uses. That's expected. Read the source (it's all plain PowerShell) and decide for yourself before running it.
- **Admin-level changes.** This modifies system files and registers scheduled tasks. Run it on your own machine, understand what each script does first, and keep the hosts backup it creates.
- **Use on your own device only.** This is a self-control tool. Installing something like this on someone else's computer without their knowledge is a different thing entirely, and not what this is for.
- **Hard to uninstall.** There's no uninstaller. You have to find and disable multiple scheduled tasks, registry entries, environment variables, and hidden folders. It's meant to be stubborn!

## License

MIT. Do what you want with it, no warranty.
