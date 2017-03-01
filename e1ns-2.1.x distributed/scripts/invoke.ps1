param (
    [Parameter(Mandatory=$true)] [string] $server,
    [Parameter(Mandatory=$true)] [string] $command,
    [Parameter(Mandatory=$true)] [SecureString] $vmcred
)

Invoke-Command -ComputerName $server -ScriptBlock {Invoke-Expression "$command"} -credential $vmcred