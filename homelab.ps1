<#
.SYNOPSIS
    Homelab Quick Access & Management Tool
    Designed for Valhalla (Proxmox), Midgard (Ubuntu Docker VM) & Heimdall (AdGuard Home LXC)
    Domain: valhalla-lab.duckdns.org
    VPN: Tailscale Subnet Router (10.0.0.0/24)
#>

$ProxmoxIP = "10.0.0.250"
$MidgardIP = "10.0.0.251"
$AdGuardIP = "10.0.0.252"
$Domain    = "valhalla-lab.duckdns.org"

function Show-Header {
    Clear-Host
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "                    VALHALLA HOMELAB CONTROL CENTER                   " -ForegroundColor Yellow
    Write-Host "                    Domain: $Domain                      " -ForegroundColor DarkCyan
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-ArchitectureMap {
    Show-Header
    Write-Host "                HOMELAB ARCHITEKTUR & DIENSTE-UEBERSICHT              " -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  [ HP EliteBook 850 G6 ] (Bare-Metal Laptop Server)" -ForegroundColor White
    Write-Host "    |" -ForegroundColor Gray
    Write-Host "    +-- Proxmox VE (Valhalla - $ProxmoxIP)" -ForegroundColor Cyan
    Write-Host "         |" -ForegroundColor Gray
    Write-Host "         +-- LXC Container: Heimdall ($AdGuardIP)" -ForegroundColor Green
    Write-Host "         |    +-- AdGuard Home DNS & Blocker   -> http://${AdGuardIP}:80" -ForegroundColor Gray
    Write-Host "         |" -ForegroundColor Gray
    Write-Host "         +-- Virtual Machine: Midgard ($MidgardIP)" -ForegroundColor Magenta
    Write-Host "              +-- Docker Engine Environment" -ForegroundColor DarkMagenta
    Write-Host "                   +-- Tailscale VPN Router -> Subnet 10.0.0.0/24 (bifroest)" -ForegroundColor Green
    Write-Host "                   +-- Nginx Proxy Manager  -> http://${MidgardIP}:81 (npm.$Domain)" -ForegroundColor Yellow
    Write-Host "                   +-- Authelia Auth (SSO)  -> http://${MidgardIP}:9091 (auth.$Domain)" -ForegroundColor Yellow
    Write-Host "                   +-- Dashy Dashboard     -> http://${MidgardIP}:4000 (dashy.$Domain)" -ForegroundColor Yellow
    Write-Host "                   +-- Dockge Stack Manager -> http://${MidgardIP}:5001 (dockge.$Domain)" -ForegroundColor Yellow
    Write-Host "                   +-- Uptime Kuma Monitor  -> http://${MidgardIP}:3001 (kuma.$Domain)" -ForegroundColor Yellow
    Write-Host "                   +-- BirdNET Bird Analyzer -> http://${MidgardIP}:8082 (birdnet.$Domain)" -ForegroundColor Yellow
    Write-Host "                   +-- Tautulli Plex Monitor-> http://${MidgardIP}:8181 (tautulli.$Domain)" -ForegroundColor Yellow
    Write-Host "                   +-- Plex Media Server   -> http://${MidgardIP}:32400/web (plex.$Domain)" -ForegroundColor Yellow
    Write-Host "                   |    +-- Festplatte: NTFS /mnt/media" -ForegroundColor Gray
    Write-Host "                   +-- ARRR Stack (Automatisierung)" -ForegroundColor Magenta
    Write-Host "                   |    +-- Overseerr (Requests)  -> http://${MidgardIP}:5055 (overseerr.$Domain)" -ForegroundColor Yellow
    Write-Host "                   |    +-- Radarr (Filme)        -> http://${MidgardIP}:7878 (radarr.$Domain)" -ForegroundColor Yellow
    Write-Host "                   |    +-- Sonarr (Serien)       -> http://${MidgardIP}:8989 (sonarr.$Domain)" -ForegroundColor Yellow
    Write-Host "                   |    +-- SABnzbd (Download)    -> http://${MidgardIP}:8085 (sabnzbd.$Domain)" -ForegroundColor Yellow
    Write-Host "                   |    +-- Prowlarr (Indexer)    -> http://${MidgardIP}:9696 (prowlarr.$Domain)" -ForegroundColor Yellow
    Write-Host "                   +-- UniFi Controller    -> https://${MidgardIP}:8443 (unifi.$Domain)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "----------------------------------------------------------------------" -ForegroundColor DarkCyan
    Write-Host ""
    Pause
}

function Test-HomelabHealth {
    Show-Header
    Write-Host "--- Network & Services Status ---" -ForegroundColor Yellow
    Write-Host ""
    
    $services = @(
        @{ Name = "Proxmox VE (Valhalla)   "; IP = $ProxmoxIP; Port = 8006 },
        @{ Name = "Ubuntu VM (Midgard)      "; IP = $MidgardIP; Port = 22 },
        @{ Name = "Nginx Proxy Manager Admin"; IP = $MidgardIP; Port = 81 },
        @{ Name = "Dashy Dashboard          "; IP = $MidgardIP; Port = 4000 },
        @{ Name = "Dockge Stack Manager     "; IP = $MidgardIP; Port = 5001 },
        @{ Name = "Overseerr Media Requests "; IP = $MidgardIP; Port = 5055 },
        @{ Name = "Radarr Movie Manager     "; IP = $MidgardIP; Port = 7878 },
        @{ Name = "Sonarr TV Manager        "; IP = $MidgardIP; Port = 8989 },
        @{ Name = "SABnzbd Downloader       "; IP = $MidgardIP; Port = 8085 },
        @{ Name = "Prowlarr Indexer Manager "; IP = $MidgardIP; Port = 9696 },
        @{ Name = "Uptime Kuma Monitoring   "; IP = $MidgardIP; Port = 3001 },
        @{ Name = "BirdNET Analyzer         "; IP = $MidgardIP; Port = 8082 },
        @{ Name = "Authelia SSO Auth        "; IP = $MidgardIP; Port = 9091 },
        @{ Name = "Tautulli Plex Monitor    "; IP = $MidgardIP; Port = 8181 },
        @{ Name = "Plex Media Server        "; IP = $MidgardIP; Port = 32400 },
        @{ Name = "AdGuard Home (Heimdall)  "; IP = $AdGuardIP; Port = 80 }
    )

    foreach ($s in $services) {
        $tcp = New-Object System.Net.Sockets.TcpClient
        try {
            $async = $tcp.BeginConnect($s.IP, $s.Port, $null, $null)
            $wait = $async.AsyncWaitHandle.WaitOne(300, $false)
            if ($wait -and $tcp.Connected) {
                Write-Host "  [ ONLINE  ]  " -NoNewline -ForegroundColor Green
                Write-Host "$($s.Name) -> http://$($s.IP):$($s.Port)" -ForegroundColor White
                $tcp.Close()
            } else {
                Write-Host "  [ OFFLINE ]  " -NoNewline -ForegroundColor Red
                Write-Host "$($s.Name) -> $($s.IP):$($s.Port)" -ForegroundColor Gray
            }
        } catch {
            Write-Host "  [ OFFLINE ]  " -NoNewline -ForegroundColor Red
            Write-Host "$($s.Name) -> $($s.IP):$($s.Port)" -ForegroundColor Gray
            if ($tcp) { $tcp.Close() }
        }
    }
    Write-Host ""
    Pause
}

do {
    Show-Header
    Write-Host " [1] SSH -> Ubuntu VM (odin@midgard)" -ForegroundColor Green
    Write-Host " [2] SSH -> Proxmox (root@valhalla)" -ForegroundColor Green
    Write-Host " [3] Web -> Nginx Proxy Manager Admin (:81)" -ForegroundColor Yellow
    Write-Host " [4] Web -> Dashy Dashboard (:4000)" -ForegroundColor Yellow
    Write-Host " [5] Web -> Dockge Stack Manager (:5001)" -ForegroundColor Yellow
    Write-Host " [6] Web -> Uptime Kuma Monitoring (:3001)" -ForegroundColor Yellow
    Write-Host " [7] Web -> BirdNET Bird Analyzer (:8082)" -ForegroundColor Yellow
    Write-Host " [8] Web -> Authelia SSO Portal (:9091)" -ForegroundColor Yellow
    Write-Host " [T] Web -> Tautulli Plex Monitor (:8181)" -ForegroundColor Yellow
    Write-Host " [O] Web -> Overseerr Media Requests (:5055)" -ForegroundColor Yellow
    Write-Host " [R] Web -> Radarr Movie Manager (:7878)" -ForegroundColor Yellow
    Write-Host " [N] Web -> Sonarr TV Manager (:8989)" -ForegroundColor Yellow
    Write-Host " [Z] Web -> SABnzbd Downloader (:8085)" -ForegroundColor Yellow
    Write-Host " [P] Web -> Prowlarr Indexer Manager (:9696)" -ForegroundColor Yellow
    Write-Host " [9] Web -> AdGuard Home (Heimdall)" -ForegroundColor Cyan
    Write-Host " [A] Web -> Plex Server (:32400)" -ForegroundColor Cyan
    Write-Host " [B] Web -> Proxmox Web GUI (:8006)" -ForegroundColor Cyan
    Write-Host " [C] Web -> UniFi Controller (:8443)" -ForegroundColor Cyan
    Write-Host " [S] Live Status-Check (Ports & Ping)" -ForegroundColor Yellow
    Write-Host " [M] Homelab Architektur-Karte (ASCII Map)" -ForegroundColor Magenta
    Write-Host " [Q] Beenden" -ForegroundColor Red
    Write-Host ""
    
    $choice = Read-Host "Wähle eine Option"

    switch ($choice) {
        '1' { Write-Host "Verbinde per SSH zu odin@$MidgardIP..." -ForegroundColor Cyan; ssh odin@$MidgardIP }
        '2' { Write-Host "Verbinde per SSH zu root@$ProxmoxIP..." -ForegroundColor Cyan; ssh root@$ProxmoxIP }
        '3' { Start-Process "http://${MidgardIP}:81" }
        '4' { Start-Process "http://${MidgardIP}:4000" }
        '5' { Start-Process "http://${MidgardIP}:5001" }
        '6' { Start-Process "http://${MidgardIP}:3001" }
        '7' { Start-Process "http://${MidgardIP}:8082" }
        '8' { Start-Process "http://${MidgardIP}:9091" }
        'T', 't' { Start-Process "http://${MidgardIP}:8181" }
        'O', 'o' { Start-Process "http://${MidgardIP}:5055" }
        'R', 'r' { Start-Process "http://${MidgardIP}:7878" }
        'N', 'n' { Start-Process "http://${MidgardIP}:8989" }
        'Z', 'z' { Start-Process "http://${MidgardIP}:8085" }
        'P', 'p' { Start-Process "http://${MidgardIP}:9696" }
        '9' { Start-Process "http://${AdGuardIP}" }
        'A', 'a' { Start-Process "http://${MidgardIP}:32400/web" }
        'B', 'b' { Start-Process "https://${ProxmoxIP}:8006" }
        'C', 'c' { Start-Process "https://${MidgardIP}:8443" }
        'S', 's' { Test-HomelabHealth }
        'M', 'm' { Show-ArchitectureMap }
        'Q', 'q' { Write-Host "Tschüss!" -ForegroundColor Yellow; break }
        default { Write-Host "Ungültige Auswahl!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
} while ($choice -notin @('Q', 'q'))
