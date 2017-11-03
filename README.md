# PSTruPortal

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/erwindevreugd)

A PowerShell module for the Interlogix TruPortal API.

## Cmdlet Name Collision

To avoid name collision between the cmdlet in this module and other cmdlets you can import this module with a prefix.

```powershell
Import-Module -Name PSTruPortal -Prefix TP
```

## Getting Started

### Getting a Session Key

Before you can send commands to the TruPortal you need to get a session key. 
You can save than save the session key to the script context so subsequent commands will be able to use the session key as long as the key is valid.

```powershell
Invoke-LoginUser -Host 192.168.1.1 -Username user -Password 1234 | Set-ScriptContext
```

To signout a session key that is saved to the script context you can retrieve the key and pipe it to the logout cmdlet.

```powershell
Get-SessionKeyFromScriptContext | Invoke-LogoutUser
```

## Trademark Acknowledgements

* Interlogix and TruPortal are registered trademarks of Interlogix United Technologies.

## Donation

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://paypal.me/erwindevreugd)