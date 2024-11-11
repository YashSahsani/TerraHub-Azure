param (
    [string]$hostname,
    [string]$user,
    [string]$identityFile
)

# Define the SSH configuration text
$configText = @"
Host $hostname
    HostName $hostname
    User $user
    IdentityFile $identityFile
"@

# Append to the SSH config file
$configText | Out-File -FilePath "$HOME\.ssh\config" -Append -Encoding UTF8
