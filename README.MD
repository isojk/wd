My way of automating _Windows_ system setup and personalization

This repository contains:
- Scripts for system configuration (modifying registries, removing junk etc.)
- Scripts for system personalization (localization, date & time formatting, power settings, context menus / shell handlers, default explorer views etc.)
- Scripts for installing various applications
- Application-specific configuration files (in a similar fashion to dotfiles)

Use at your own risk

### Bootstraping the library on a clean machine

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString("https://github.com/isojk/wd/blob/trunk/bootstrap.ps1?raw=true"))
```
