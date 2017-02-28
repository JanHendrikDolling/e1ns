﻿param (
    [Parameter(Mandatory=$true)][string]$vmName
 )


$ShareName = "\\vm-db\data"
$ShareSetup = $ShareName + "\setup"


start-Process $ShareSetup\setup_scio_client.exe -ArgumentList '/s /z"TARGETDIR=C:\Program Files (x86)\PLATO AG\SCIO; shortcutsdesk=1; shortcutsprog=1; company=PLATO; lang= en; plugins = 0;Instance=default"' -Wait ;
start-Process $ShareSetup\setup_scio_server.exe -ArgumentList '/s /z"TARGETDIR=C:\Program Files\PLATO AG\SCIO; company=PLATO; Instance=default"' -Wait ;
start-Process $ShareSetup\setup_e1ns.exe -ArgumentList '/s /v"DOUPDATE=1 IGNORENOTSTOPPED=1 IGNOREPENDINGRESTART=1"' -Wait ;
