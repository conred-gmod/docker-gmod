

$DownloadSrv = $true

$ServerProcess = $null

trap {
    while ($true) {

        if($DownloadSrv) {
            Write-Host "Downloading/updating server..."

            /opt/steamcmd/steamcmd `
                +force_install_dir "/srv" `
                +login anonymous `
                +app_update 4020 validate `
                +quit
        }

        Write-Host "Starting server..."

        $ServerProcess = Start-Process -FilePath "/srv/srcds" `
            -ArgumentList "-strictportbind",
                "-port", "27015",
                "-tv_port", "27020",
                "-clientport", "27005",
                "-sport", "26900",
                "-console",
                "+sv_setsteamaccount", $env:GLST,
                "-game", "garrysmod",
                "-maxplayers", $env:MaxPlayers,
                "+host_workshop_collection", $env:CollectionID,
                "+gamemode", "sandbox",
                "+map", "gm_construct" `
            -PassThru

        Wait-Process $ServerProcess

        $CorrectlyFinished = $?
        if($CorrectlyFinished) {
            Write-Host "Server exited correctly."
        } else {
            Write-Host "Server failed with code $($LASTEXITCODE)"
        }

        $DownloadSrv = $CorrectlyFinished
    }
} finally {
    if($ServerProcess -ne $null) {
        Write-Host "Stopping server..."
        
        $ServerProcess.StandardInput.WriteLine("quit") 
        Wait-Process $ServerProcess

        Write-Host "Server is stopped."
    }
}