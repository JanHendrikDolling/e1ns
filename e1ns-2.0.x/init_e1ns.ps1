$scio_client = "https://www.hidrive.strato.com/wget/pTrO0OOq"
$scio_server = "https://www.hidrive.strato.com/wget/8ELu0vwv"
$scio_db = "https://www.hidrive.strato.com/wget/S1LuUd2Q"
$e1ns = "https://www.hidrive.strato.com/wget/SeLuUBuL" 
$e1ns_config = "https://www.hidrive.strato.com/wget/Y4rOUbCN"  
 

New-Item -ItemType Directory -Force -Path c:\setup
Invoke-WebRequest -Method Get -Uri $scio_server -OutFile c:\setup\setup_scio_server.exe ;
Invoke-WebRequest -Method Get -Uri $scio_client -OutFile c:\setup\setup_scio_client.exe ;
Invoke-WebRequest -Method Get -Uri $scio_db -OutFile c:\setup\db.zip ;
Invoke-WebRequest -Method Get -Uri $e1ns -OutFile c:\setup\setup_e1ns.exe ;
Invoke-WebRequest -Method Get -Uri $e1ns_config -OutFile c:\setup\e1ns_config.yml ;

start-Process c:\setup\setup_scio_client.exe -ArgumentList '/s /z"TARGETDIR=C:\Program Files (x86)\PLATO AG\SCIO; shortcutsdesk=1; shortcutsprog=1; company=PLATO; lang= en; plugins = 0;Instance=default"' -Wait ;
start-Process c:\setup\setup_scio_server.exe -ArgumentList '/s /z"TARGETDIR=C:\Program Files\PLATO AG\SCIO; company=PLATO; Instance=default"' -Wait ;
start-Process c:\setup\setup_e1ns.exe -ArgumentList '/s /v"DOUPDATE=1 IGNORENOTSTOPPED=1 IGNOREPENDINGRESTART=1"' -Wait ;

New-Item -ItemType Directory -Force -Path "C:\ProgramData\PLATO AG\SCIO_DB"
Expand-Archive c:\setup\db.zip -DestinationPath "C:\ProgramData\PLATO AG\SCIO_DB"


$scio_bin = "C:\Program Files\PLATO AG\SCIO\Server\bin"
$db_name = "testgetdat"
$db_dir = "C:\ProgramData\PLATO AG\SCIO_DB\DB_TestDataArchivGenDat"
$out_dir = "c:\setup"

$start_p = $scio_bin + "\sciodbinstall.exe"
$working_dir = $scio_bin
$arg = "-i -D " + '"' + $db_dir + '"' + " -P " + $db_name
$stdout = $out_dir + "\stdout.txt" 
$stderr = $out_dir + "\stderr.txt" 

$process = Start-Process $start_p  -WorkingDirectory $working_dir -ArgumentList $arg  -NoNewWindow -PassThru -Wait -RedirectStandardOutput $stdout -RedirectStandardError $stderr

Write-Host "exit code: " + $p.ExitCode

start-Process "C:\Program Files (x86)\PLATO AG\e1ns\e1ns.config\cli\configurator.exe" -ArgumentList '--config="c:\setup\e1ns_config.yml"' -Wait ;


start-Process "C:\Program Files (x86)\PLATO AG\e1ns\e1ns.config\services\services.exe" -ArgumentList 'start --all' -Wait ;
start-Process "C:\Program Files (x86)\PLATO AG\e1ns\e1ns.config\services\services.exe" -ArgumentList 'start --all' -Wait ;

New-NetFirewallRule -DisplayName “https inbound” -Direction Inbound -Action Allow -LocalPort 443 -Protocol TCP -Enabled True




