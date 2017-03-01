
# import variables
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
. $scriptPath/variables.ps1


New-Item -ItemType Directory -Force -Path $SetupFolderName

Invoke-WebRequest -Method Get -Uri $scio_server -OutFile $SetupFolderName\setup_scio_server.exe ;
Invoke-WebRequest -Method Get -Uri $scio_client -OutFile $SetupFolderName\setup_scio_client.exe ;
Invoke-WebRequest -Method Get -Uri $scio_db -OutFile $SetupFolderName\db.zip ;
Invoke-WebRequest -Method Get -Uri $e1ns -OutFile $SetupFolderName\setup_e1ns.exe ;
Invoke-WebRequest -Method Get -Uri $e1ns_config -OutFile $SetupFolderName\e1ns_config.yml ;
Invoke-WebRequest -Method Get -Uri $setup_script -OutFile $SetupFolderName\setup.ps1 ;

start-Process $SetupFolderName\setup_scio_client.exe -ArgumentList '/s /z"TARGETDIR=C:\Program Files (x86)\PLATO AG\SCIO; shortcutsdesk=1; shortcutsprog=1; company=PLATO; lang= en; plugins = 0;Instance=default"' -Wait ;
start-Process $SetupFolderName\setup_scio_server.exe -ArgumentList '/s /z"TARGETDIR=C:\Program Files\PLATO AG\SCIO; company=PLATO; Instance=default"' -Wait ;
start-Process $SetupFolderName\setup_e1ns.exe -ArgumentList '/s /v"DOUPDATE=1 IGNORENOTSTOPPED=1 IGNOREPENDINGRESTART=1"' -Wait ;