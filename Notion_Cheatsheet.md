# 🏰 Valhalla Homelab - Notion Cheatsheet

> **Hardware**: HP EliteBook 850 G6 Laptop  
> **Domain**: `valhalla-lab.duckdns.org`  
> **VPN**: Tailscale Subnet Router (`10.0.0.0/24`)

---

## 🌐 1. Public HTTPS Endpoints (Domain Links)

| Service | HTTPS URL | Auth / Protection | Status |
| :--- | :--- | :--- | :---: |
| **Dashy Dashboard** | [dashy.valhalla-lab.duckdns.org](https://dashy.valhalla-lab.duckdns.org) | Authelia 2FA / SSO | 🟢 |
| **Authelia SSO Portal** | [auth.valhalla-lab.duckdns.org](https://auth.valhalla-lab.duckdns.org) | SSO Identity Provider | 🟢 |
| **Plex Media Server** | [plex.valhalla-lab.duckdns.org](https://plex.valhalla-lab.duckdns.org) | Native Plex Auth (Direct Play) | 🟢 |
| **Dockge Manager** | [dockge.valhalla-lab.duckdns.org](https://dockge.valhalla-lab.duckdns.org) | Authelia 2FA / SSO | 🟢 |
| **BirdNET Analyzer** | [birdnet.valhalla-lab.duckdns.org](https://birdnet.valhalla-lab.duckdns.org) | Authelia 2FA / SSO | 🟢 |
| **Uptime Kuma Status** | [kuma.valhalla-lab.duckdns.org](https://kuma.valhalla-lab.duckdns.org) | Authelia 2FA / Public Status Page | 🟢 |
| **Tautulli** | [tautulli.valhalla-lab.duckdns.org](https://tautulli.valhalla-lab.duckdns.org) | Authelia 2FA / SSO | 🟢 |

---

## 🖥️ 2. Local Infrastructure & Admin Web Interfaces

| Service / Node | Local IP & Port | Function | Host / Location |
| :--- | :--- | :--- | :--- |
| **Proxmox VE** | [https://10.0.0.250:8006](https://10.0.0.250:8006) | Bare-Metal Hypervisor (`valhalla`) | Laptop Hardware |
| **Ubuntu Docker VM** | [http://10.0.0.251](http://10.0.0.251) | Docker Host (`midgard`) | Proxmox VM 100 |
| **AdGuard Home** | [http://10.0.0.252](http://10.0.0.252) | DNS & Ad-Blocker (`heimdall`) | Proxmox LXC 101 |
| **Tailscale VPN Router** | https://login.tailscale.com | VPN Subnet Router (`bifroest`) | Docker Container |
| **Uptime Kuma** | [http://10.0.0.251:3001](http://10.0.0.251:3001) | System & Uptime Monitoring | Docker Container |
| **BirdNET Go** | [http://10.0.0.251:8082](http://10.0.0.251:8082) | Bird Song AI Classification | Docker Container |
| **Tautulli** | [http://10.0.0.251:8181](http://10.0.0.251:8181) | Plex Monitoring & Stats | Docker Container |
| **Overseerr** | [http://10.0.0.251:5055](http://10.0.0.251:5055) | Media Request Management | Docker Container |
| **Radarr** | [http://10.0.0.251:7878](http://10.0.0.251:7878) | Movie Management | Docker Container |
| **Sonarr** | [http://10.0.0.251:8989](http://10.0.0.251:8989) | TV Show Management | Docker Container |
| **SABnzbd** | [http://10.0.0.251:8085](http://10.0.0.251:8085) | Usenet Downloader | Docker Container |
| **Prowlarr** | [http://10.0.0.251:9696](http://10.0.0.251:9696) | Usenet Indexer Manager | Docker Container |
| **Nginx Proxy Manager** | [http://10.0.0.251:81](http://10.0.0.251:81) | Reverse Proxy Admin | Docker Container |
| **Dockge Manager** | [http://10.0.0.251:5001](http://10.0.0.251:5001) | Compose Stack Manager | Docker Container |
| **Dashy Dashboard** | [http://10.0.0.251:4000](http://10.0.0.251:4000) | Central Dashboard | Docker Container |
| **Watchtower** | [http://10.0.0.251:8086](http://10.0.0.251:8086) | Auto-Updater API | Docker Container |
| **Authelia Auth** | [http://10.0.0.251:9091](http://10.0.0.251:9091) | SSO Engine | Docker Container |
| **Plex Media Server** | [http://10.0.0.251:32400/web](http://10.0.0.251:32400/web) | Media Server | Docker Container |
| **Router (Gateway)** | [http://10.0.0.199](http://10.0.0.199) | Network Router | Local Hardware |

---

## 🔑 3. SSH & Credentials Reference

| Node / Service | Username | Default Password / Key | SSH Command / URL |
| :--- | :--- | :--- | :--- |
| **Midgard (Docker VM)** | `odin` | `[SECRET]` / SSH Key | `ssh odin@10.0.0.251` |
| **Valhalla (Proxmox)** | `root` | System Password | `ssh root@10.0.0.250` |
| **Heimdall (AdGuard)** | `root` | LXC Root Password | `ssh root@10.0.0.252` |
| **Tailscale Portal** | Google/Microsoft | OAuth Login | [login.tailscale.com](https://login.tailscale.com) |
| **Authelia Portal** | `odin` | `[SECRET]` | *(Web Login)* |
| **NPM Admin** | `admin@example.com` | `changeme` | *(Web Login)* |

---

## 📁 4. Server Folder Structure (`midgard` / `10.0.0.251`)

* `/opt/stacks/arr-stack` $\rightarrow$ ARRR Usenet Stack (Radarr, Sonarr, SABnzbd, Prowlarr, Overseerr)
* `/opt/stacks/tautulli` $\rightarrow$ Tautulli Plex Monitor (`docker-compose.yml`)
* `/opt/stacks/birdnet` $\rightarrow$ BirdNET Bird Analyzer (`docker-compose.yml`)
* `/opt/stacks/tailscale` $\rightarrow$ Tailscale Subnet Router (`bifroest` - `docker-compose.yml`)
* `/opt/stacks/uptime-kuma` $\rightarrow$ Uptime Kuma Monitoring (`docker-compose.yml`)
* `/opt/stacks/watchtower` $\rightarrow$ Auto-Updater (`docker-compose.yml`)
* `/opt/stacks/dashy` $\rightarrow$ Dashy Dashboard (`my-conf.yml`, `docker-compose.yml`)
* `/opt/stacks/authelia` $\rightarrow$ Authelia SSO (`config/configuration.yml`, `users_database.yml`)
* `/opt/stacks/npm` $\rightarrow$ Nginx Proxy Manager
* `/opt/stacks/dockge` $\rightarrow$ Dockge Stack Manager
* `/home/odin/docker/plex` $\rightarrow$ Plex Media Server
* `/mnt/media` $\rightarrow$ NTFS External Media Disk (`MOVIES`, `TV`, etc.)

---

## ⚡ 5. Local Management Script

* **Script Path**: [`homelab.ps1`](file:///c:/Antigravity/HomeLab/homelab.ps1)
* **Quick Launch**:
  ```powershell
  cd C:\Antigravity\HomeLab
  .\homelab.ps1
  ```
