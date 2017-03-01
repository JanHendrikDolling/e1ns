param (
    [string]$adminUser = "plato",
    [string]$vmDB = "vm-db",
    [string]$vmLB = "vm-lb",
    [string]$vmUi1 = "vm-ui1",
    [string]$vmUi2 = "vm-ui2",
    [string]$vmRep = "vm-rep",
    [string]$vmIndex = "vm-index",
    [string]$adminPw = "plato"
 )

$FolderName = "C:\share"
$ShareName = "data"

# create local folders
if (!(TEST-PATH $FolderName)) { 
    NEW-ITEM $FolderName -type Directory
}
$SetupFolderName = $FolderName + "\setup"
New-Item -ItemType Directory -Force -Path $SetupFolderName

# download setup files
$scio_client = "https://www.hidrive.strato.com/wget/lCLuU2G7"
$scio_server = "https://www.hidrive.strato.com/wget/UAru0rve"
$scio_db = "https://www.hidrive.strato.com/wget/LBLuUBRG"
$e1ns = "https://www.hidrive.strato.com/wget/s7LO0GH0" 
$e1ns_config = "https://www.hidrive.strato.com/wget/HpLO0mAk"
$setup_script = "https://raw.githubusercontent.com/JanHendrikDolling/e1ns/master/e1ns-2.1.x%20distributed/scripts/setup.ps1"

Invoke-WebRequest -Method Get -Uri $scio_server -OutFile $SetupFolderName\setup_scio_server.exe ;
Invoke-WebRequest -Method Get -Uri $scio_client -OutFile $SetupFolderName\setup_scio_client.exe ;
Invoke-WebRequest -Method Get -Uri $scio_db -OutFile $SetupFolderName\db.zip ;
Invoke-WebRequest -Method Get -Uri $e1ns -OutFile $SetupFolderName\setup_e1ns.exe ;
Invoke-WebRequest -Method Get -Uri $e1ns_config -OutFile $SetupFolderName\e1ns_config.yml ;
Invoke-WebRequest -Method Get -Uri $setup_script -OutFile $SetupFolderName\setup.ps1 ;


# create share
New-SmbShare –Name $ShareName –Path $FolderName –FullAccess Everyone 


# add machines to the trusted hosts list using winrm

Get-Item WSMan:\localhost\Client\TrustedHosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $vmLB -Concatenate -force -confirm:$false
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $vmUi1 -Concatenate -force -confirm:$false
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $vmUi2 -Concatenate -force -confirm:$false
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $vmRep -Concatenate -force -confirm:$false
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $vmIndex -Concatenate -force -confirm:$false

# login credentials
$securepassword = ConvertTo-SecureString $adminPw -AsPlainText -Force
$vmcred = new-object -typename System.Management.Automation.PSCredential -argumentlist $adminUser, $securepassword

# install software 
$scriptPath = "\\" + $vmDB + "\data\setup\setup.ps1"
Invoke-Command -ComputerName $vmUi1 -ScriptBlock {Invoke-Expression "$scriptPath -vmDB $vmDB -role 'ui'"} -credential $vmcred
Invoke-Command -ComputerName $vmUi2 -ScriptBlock {Invoke-Expression "$scriptPath -vmDB $vmDB -role 'ui'"} -credential $vmcred
Invoke-Command -ComputerName $vmDB -ScriptBlock {Invoke-Expression "$scriptPath -vmDB $vmDB -role 'db'"} -credential $vmcred
Invoke-Command -ComputerName $vmRep -ScriptBlock {Invoke-Expression "$scriptPath -vmDB $vmDB -role 'rep'"} -credential $vmcred
Invoke-Command -ComputerName $vmIndex -ScriptBlock {Invoke-Expression "$scriptPath -vmDB $vmDB -role 'index'"} -credential $vmcred
Invoke-Command -ComputerName $vmLB -ScriptBlock {Invoke-Expression "$scriptPath -vmDB $vmDB -role 'lb'"} -credential $vmcred

# configure software


# start System
