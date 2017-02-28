param (
    [string]$adminUser = "plato",
    [string]$vmDB = "vm-db",
    [string]$vmLB = "vm-lb",
    [string]$vmUi1 = "vm-ui1",
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

Invoke-WebRequest -Method Get -Uri $scio_server -OutFile $SetupFolderName\setup_scio_server.exe ;
Invoke-WebRequest -Method Get -Uri $scio_client -OutFile $SetupFolderName\setup_scio_client.exe ;
Invoke-WebRequest -Method Get -Uri $scio_db -OutFile $SetupFolderName\db.zip ;
Invoke-WebRequest -Method Get -Uri $e1ns -OutFile $SetupFolderName\setup_e1ns.exe ;
Invoke-WebRequest -Method Get -Uri $e1ns_config -OutFile $SetupFolderName\e1ns_config.yml ;


# create share
New-SmbShare –Name $ShareName –Path $FolderName –FullAccess Everyone 