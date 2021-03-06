﻿param (
    [string]$adminUser = "plato",
    [string]$vmDB = "vm-db",
    [string]$vmLB = "vm-lb",
    [string]$vmUi1 = "vm-ui1",
    [string]$vmUi2 = "vm-ui2",
    [string]$vmRep = "vm-rep",
    [string]$vmIndex = "vm-index",
    [Parameter(Mandatory=$true)][SecureString]$adminPw
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


# init script items
$localScriptPath = $FolderName + "\setup"
$scriptPath = "\\" + $vmDB + "\data\setup"
$items = @()

$obj = New-Object System.Object
$obj | Add-Member -type NoteProperty -name server -value $vmLB
$obj | Add-Member -type NoteProperty -name role -value "lb"
$items += $obj 

$obj = New-Object System.Object
$obj | Add-Member -type NoteProperty -name server -value $vmUi1
$obj | Add-Member -type NoteProperty -name role -value "ui"
$items += $obj 

$obj = New-Object System.Object
$obj | Add-Member -type NoteProperty -name server -value $vmUi2
$obj | Add-Member -type NoteProperty -name role -value "ui"
$items += $obj 

$obj = New-Object System.Object
$obj | Add-Member -type NoteProperty -name server -value $vmDB
$obj | Add-Member -type NoteProperty -name role -value "db"
$items += $obj 

$obj = New-Object System.Object
$obj | Add-Member -type NoteProperty -name server -value $vmRep
$obj | Add-Member -type NoteProperty -name role -value "rep"
$items += $obj 

$obj = New-Object System.Object
$obj | Add-Member -type NoteProperty -name server -value $vmIndex
$obj | Add-Member -type NoteProperty -name role -value "index"
$items += $obj 


# install software
workflow parallelCheckServer {
    param (
        $items,
        $dbServer,
        $localScriptPath,
        [SecureString]$vmcred
    )
    foreach -parallel($item in $items)
    {
        $server = $item.server
        $setupScriptPath = $localScriptPath + "\setup.ps1"

        #arguments for script
        $argumentlist = @()
        $argumentlist += $dbServer
        $argumentlist += $item.role

        #invoce local script on remoute computer
        Invoke-Command -ComputerName $server -credential $vmcred -FilePath $setupScriptPath -argumentlist $argumentlist
    }
}
parallelCheckServer -items $items -dbServer $vmDB -localScriptPath $localScriptPath -vmcred $vmcred


# configure software


# start System
