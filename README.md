<div align="center">
  <h1>🏰 Valhalla Homelab</h1>
  <p>The central hub for infrastructure, media automation, and network management.</p>
</div>

---

## 🏗️ Architecture Overview

The Homelab runs on an **HP EliteBook 850 G6** (Bare-Metal) acting as the main virtualization node.

* **Valhalla (Proxmox VE)**: The hypervisor handling hardware resources (`10.0.0.250`).
* **Midgard (Ubuntu VM)**: The primary Docker engine hosting all critical services (`10.0.0.251`).
* **Heimdall (LXC)**: Dedicated container for AdGuard Home DNS (`10.0.0.252`).

All external traffic is routed through **Nginx Proxy Manager**, securely gated by **Authelia** (SSO/2FA), and accessible via the `valhalla-lab.duckdns.org` domain. Remote internal access is provided securely via a **Tailscale Subnet Router**.

---

## 🌐 1. Public HTTPS Endpoints (Domain Links)

| Service | HTTPS URL | Auth / Protection |
| :--- | :--- | :--- |
| **Dashy Dashboard** | [dashy.valhalla-lab.duckdns.org](https://dashy.valhalla-lab.duckdns.org) | 🔒 Authelia 2FA / SSO |
| **Authelia SSO Portal** | [auth.valhalla-lab.duckdns.org](https://auth.valhalla-lab.duckdns.org) | 🔒 SSO Identity Provider |
| **Plex Media Server** | [plex.valhalla-lab.duckdns.org](https://plex.valhalla-lab.duckdns.org) | 🛡️ Native Plex Auth |
| **Dockge Manager** | [dockge.valhalla-lab.duckdns.org](https://dockge.valhalla-lab.duckdns.org) | 🔒 Authelia 2FA / SSO |
| **BirdNET Analyzer** | [birdnet.valhalla-lab.duckdns.org](https://birdnet.valhalla-lab.duckdns.org) | 🔒 Authelia 2FA / SSO |
| **Uptime Kuma Status** | [kuma.valhalla-lab.duckdns.org](https://kuma.valhalla-lab.duckdns.org) | 🔒 Authelia 2FA / SSO |

---

## 🖥️ 2. Local Infrastructure & Docker Services

These services are only accessible within the local LAN (`10.0.0.0/24`) or via Tailscale.

| Service / Container | Local Endpoint | Function |
| :--- | :--- | :--- |
| **Proxmox VE** | `https://10.0.0.250:8006` | Bare-Metal Hypervisor (`valhalla`) |
| **AdGuard Home** | `http://10.0.0.252:80` | Network-wide Adblocker (`heimdall`) |
| **Tailscale Router** | `bifroest` | VPN Subnet Router |
| **UniFi Controller** | `https://10.0.0.251:8443` | Ubiquiti Network App |
| **Tautulli** | `http://10.0.0.251:8181` | Plex Analytics |
| **Overseerr** | `http://10.0.0.251:5055` | Media Requests |
| **Radarr** | `http://10.0.0.251:7878` | Movie Automation |
| **Sonarr** | `http://10.0.0.251:8989` | TV Show Automation |
| **SABnzbd** | `http://10.0.0.251:8085` | Usenet Downloader |
| **Prowlarr** | `http://10.0.0.251:9696` | Indexer Manager |
| **Redbot** | *(Headless)* | Discord Bot |
| **DuckDNS** | *(Headless)* | DynDNS |

---

## 📁 3. Docker Volume Strategy

All containers run inside `/opt/stacks/` on `midgard`. 

> **Important Security Note:** The `docker-compose.yml` files are versioned in a separate repository (`midgard-stacks`). However, all persistent data and configuration files are located inside `*/config/` or `*/data/` directories, which are explicitly ignored via `.gitignore` to prevent secret leakage. Passwords in compose files are sourced dynamically via `.env` files.

Media is mounted directly to the VM via NTFS:
* `/mnt/media/MOVIES`
* `/mnt/media/TV`
* `/mnt/media/Downloads/usenet`

The ARRR stack (Radarr, Sonarr, SABnzbd) all map the volume as `- /mnt/media:/mnt/media` to enable **atomic hardlinks**, ensuring zero storage waste and instant file transfers.

---

## ⚡ 4. Management Script (`homelab.ps1`)

Included in this repository is `homelab.ps1`, a custom PowerShell control center designed to be run from any Windows machine in the network.

**Features:**
* 1-Click SSH into Proxmox or Docker VM
* 1-Click Web-UI launches for all services
* Live TCP Port Health Checks for the entire stack
* Architecture Map visualization

### Usage:
```powershell
.\homelab.ps1
```
