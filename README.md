# Powershell script utils

To use those scripts, following
```ps1
...
. "path\to\utils\powershell\MainUtils.ps1"
...
```

## Add Aliases

1. Go to `$HOME\Documents\WindowsPowerShell\profile.ps1`
2. Create if not exist `Profile.ps1`
3. Insert

```powershell
function np {
    C:\Windows\notepad.exe
}
```

Where `np` is the name of the alias.