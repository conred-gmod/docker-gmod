

$DownloadSrv = $true

$ServerProcess = $null

Set-Location $env:STEAMCMDDIR

trap {
    while ($true) {

        if($DownloadSrv) {
            Write-Host "Downloading/updating server..."

            ./steamcmd.sh `
                +force_install_dir "/srv" `
                +login anonymous `
                +app_update 4020 validate `
                +quit
        }

        Write-Host "Starting server..."

        $SrvArgs = @(
            "-strictportbind",
            "-port", "27015",
            #"-tv_port", "27020",
            "-clientport", "27005",
            #"-sport", "26900",
            "-console",
            "+sv_setsteamaccount", $(Get-Content "/run/secrets/glst"),
            "-game", "garrysmod",
            "-maxplayers", $env:MaxPlayers,
            "+host_workshop_collection", $env:CollectionID,
            "+gamemode", "sandbox",
            "+map", "gm_construct"
        )

        if($env:Testing) {
            $SrvArgs += @("+hide_server", "1")
        }

        $ServerProcess = Start-Process -FilePath "/srv/srcds" `
            -ArgumentList $SrvArgs`
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