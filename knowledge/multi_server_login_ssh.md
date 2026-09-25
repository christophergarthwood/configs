---

# PowerShell Script: Multi-Tab SSH Launcher for Windows Terminal

## Summary

This PowerShell script is designed to improve efficiency by automating the process of opening multiple SSH sessions in a single, organized Windows Terminal window.

It securely prompts the user for a password at runtime, then programmatically constructs and executes a single command that instructs Windows Terminal to open a new, dedicated tab for each server defined in the server list. This method avoids the need to store passwords in plain text and prevents the terminal from opening multiple separate windows.

## How It Works

1.  **Secure Password Prompt:** The script begins by securely asking the user for the SSH password. The input is hidden and stored in memory as a `SecureString` object.
2.  **Temporary Password File:** The secure password is then decrypted in memory and immediately written to a unique, randomly named file in the system's temporary directory. This file exists for only a few seconds.
3.  **Command Chaining:** The script loops through the server list and builds a series of `new-tab` commands. These commands are joined together with semicolons into one long string.
4.  **Single Execution:** It executes `wt.exe` (Windows Terminal) just once, passing the entire chained command string. Windows Terminal interprets the semicolons as instructions to perform the next action (open another new tab) within the same window.
5.  **Automatic Cleanup:** After a brief delay to ensure all `plink.exe` instances have started and read the password file, the script automatically deletes the temporary file, ensuring the plain-text password does not remain on the disk.

## PowerShell Script

```powershell
<#
.SYNOPSIS
    This script opens multiple SSH sessions in separate tabs within a single Windows Terminal window.
.DESCRIPTION
    It securely prompts for a password, writes it to a temporary file, then constructs a single
    `wt.exe` command with chained 'new-tab' actions to ensure all tabs open in one window.
.PARAMETER username
    The username for the SSH connections.
.PARAMETER servers
    An array of server IP addresses or hostnames.
#>
param(
    [string]$username = "username",
    [string[]]$servers = @(
        "server1",
        "server2"
    )
)

# --- SCRIPT ---

# --- SECURELY PROMPT FOR PASSWORD ---
$securePassword = Read-Host -AsSecureString -Prompt "Enter SSH password for user '$username'"

# --- DECRYPT PASSWORD AND CREATE ONE TEMP FILE FOR THE WHOLE SCRIPT ---
# Define a path for a single temporary password file
$tempPwFile = Join-Path $env:TEMP ([System.IO.Path]::GetRandomFileName())

try {
    # Convert the SecureString to plain text for the file
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

    # Write the password to the single temp file
    $password | Out-File -FilePath $tempPwFile -Encoding ASCII -NoNewline
    
    # Clear the plain-text password variable from memory as soon as it's written
    Clear-Variable -Name password
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)


    Write-Host "Building Windows Terminal command..."

    # --- BUILD THE CHAINED COMMAND ---
    $wtCommands = @()
    foreach ($server in $servers) {
        # Create the command fragment for each server.
        $command = "new-tab --title $server plink.exe $username@$server -pwfile $tempPwFile"
        $wtCommands += $command
    }
    
    # Join all the commands with a semicolon, which wt.exe interprets as "do the next action in the same window".
    $finalCommand = $wtCommands -join ' ; '
    
    Write-Host "Launching all sessions in a single window..."
    
    # Execute the single, chained command.
    # We use Start-Process to handle the complex command string reliably.
    Start-Process wt.exe -ArgumentList $finalCommand

    Write-Host "All sessions launched. Waiting for 5 seconds before cleanup..."
    # Give the new terminal window a generous amount of time to launch and for all plink instances to read the file.
    Start-Sleep -Seconds 5
}
finally {
    # --- FINAL CLEANUP ---
    if (Test-Path $tempPwFile) {
        Remove-Item $tempPwFile -Force
        Write-Host "Temporary password file has been deleted."
    }
}

Write-Host "Script finished."
```