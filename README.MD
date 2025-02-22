Scripts for automating Windows system configuration and installation of common applications,
tailored for my own needs.

Available features:
- Streamlined installation and configuration of all common applications and libraries I do use on a daily basis
- Tracking applications settings under version control, in a similar fashion to dotfiles
- Setting privacy options and turning off all sorts of telemetry features
- Managing / removing pre-installed vendor and third-party applications (including OneDrive)
- Configuring autoruns (e.g. turning off Edge running in background)
- Management of environment variables
- Configuring localization (date & time formatting)
- Configuring explorer (views, context menus / shell handlers)
- Personalization

Use at your own risk

## Bootstraping on a new machine

@TODO
<!--
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12; iex ((New-Object System.Net.WebClient).DownloadString("https://github.com/isojk/wd/blob/trunk/bootstrap.ps1?raw=true"))
```
-->

## Usage

See `wd -Help` for more information

## Troubleshooting

Some applications do not support relative path arguments or values in their setting files. Having absolute paths there
makes it less fit for storing their configuration in the version control. To work around this issue the script defines
environment variable `DOTFILES` with an absolute path to the `Apps` directory. When troubleshooting always make sure
this variable is set, using `wd EnumEnvVars` command.
