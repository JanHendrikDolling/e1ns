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

$securepassword = ConvertTo-SecureString $adminPw -AsPlainText -Force
$vmcred = new-object -typename System.Management.Automation.PSCredential -argumentlist $adminUser, $securepassword

$scriptPath = "\\" + $vmDB + "\data\setup\setup.ps1"
$argumentList = " -vmName " + $vmUi1 + " -vmDB " + $vmDB

Invoke-Command -ComputerName $vmUi1 -ScriptBlock {NEW-ITEM "c:\test123" -type Directory} -credential $vmcred
Invoke-Command -ComputerName $vmUi2 -ScriptBlock {NEW-ITEM "c:\test123" -type Directory} -credential $vmcred

# {Invoke-Expression "$scriptPath $argumentList"}