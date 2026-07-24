<div align="center">
  <h1>🏰 Valhalla Homelab</h1>
  <p><i>The central hub for infrastructure, media automation, and network management.</i></p>
</div>

---

> **Hardware**: HP EliteBook 850 G6 Laptop (Bare-Metal)  
> **Domain**: `valhalla-lab.duckdns.org`  
> **Gateway/Router**: `10.0.0.199`  
> **VPN**: Tailscale Subnet Router (`10.0.0.0/24`)

---

## 🏗️ 1. Architecture Overview

The homelab runs on a single bare-metal node managed by Proxmox VE. 

```mermaid
graph TD
    Hardware[HP EliteBook 850 G6<br>Hardware] --> Valhalla
    
    subgraph Valhalla ["Proxmox VE - 10.0.0.250"]
        Midgard(VM 100: Ubuntu Server<br>10.0.0.251)
        Heimdall(LXC 101: AdGuard Home<br>10.0.0.252)
        Hugin(VM: Tiny11 Windows<br>10.0.0.248)
    end
    
    Midgard --> Docker[Docker Engine]
    
    subgraph DockerStacks ["/opt/stacks"]
        NPM[Nginx Proxy Manager]
        Authelia[Authelia SSO]
        Media[ARRR Stack & Plex]
        Guacamole[Apache Guacamole]
        Homepage[Homepage Dashboard]
    end
```

### The Nodes:
* **Valhalla (`10.0.0.250`)**: The bare-metal hypervisor running Proxmox VE. Handles all hardware resources.
* **Midgard (`10.0.0.251`)**: The heart of the homelab. An Ubuntu VM running Docker. All main applications (stacks) are containerized here inside `/opt/stacks`.
* **Heimdall (`10.0.0.252`)**: A lightweight LXC container running AdGuard Home for network-wide DNS filtering and ad-blocking.
* **Hugin (`10.0.0.248`)**: A heavily debloated Windows 11 (Tiny11) VM serving as a dedicated RDP workstation.

---

## 🌐 2. Network & Traffic Flow

Security is paramount. No services (except Plex direct play) are directly exposed to the internet without passing through SSO.

```mermaid
flowchart LR
    Internet((Internet)) --> Router[Router<br>Port 80/443]
    Router --> NPM[Nginx Proxy Manager<br>10.0.0.251]
    
    NPM -->|Auth Request| Authelia{Authelia SSO<br>2FA}
    Authelia -->|Verified| Services
    
    subgraph Services [Internal Services]
        Homepage[Homepage Dashboard]
        Dashboards[BirdNET, Dockge, Kuma]
        Guac[Guacamole RDP]
    end
    
    NPM -.->|Direct Stream| Plex[Plex Media Server]
```

**How it works:**
1. Incoming traffic hits `valhalla-lab.duckdns.org` on ports 80/443.
2. Nginx Proxy Manager (NPM) terminates SSL and checks the requested subdomain.
3. For protected routes, NPM triggers a subrequest to **Authelia**.
4. If unauthenticated, the user is redirected to `auth.valhalla-lab.duckdns.org` for 2FA login.
5. Once authenticated, NPM proxies traffic to the correct Docker container.

---

## 🗂️ 3. Service & Endpoint Directory

> All external endpoints are protected by Authelia 2FA, except Plex which uses native auth.

### 🏠 Dashboards & Identity
| Service | External URL (HTTPS) | Internal (LAN) | Function |
| :--- | :--- | :--- | :--- |
| **Homepage** | [home.valhalla-lab.duckdns.org](https://home.valhalla-lab.duckdns.org) | `http://10.0.0.251:3008` | Central Dashboard (Auto-discovered via Docker Labels) |
| **Authelia** | [auth.valhalla-lab.duckdns.org](https://auth.valhalla-lab.duckdns.org) | `http://10.0.0.251:9091` | SSO Engine & Identity Provider |
| **NPM** | *(Internal Only)* | `http://10.0.0.251:81` | Reverse Proxy & SSL Certificates |

### 📺 Media & Entertainment
| Service | External URL (HTTPS) | Internal (LAN) | Function |
| :--- | :--- | :--- | :--- |
| **Plex** | [plex.valhalla-lab.duckdns.org](https://plex.valhalla-lab.duckdns.org) | `10.0.0.251:32400` | Media Server |
| **Overseerr** | *(Behind NPM)* | `http://10.0.0.251:5055` | Media Request Management |
| **Radarr** | *(Internal Only)* | `http://10.0.0.251:7878` | Movie Downloader/Manager |
| **Sonarr** | *(Internal Only)* | `http://10.0.0.251:8989` | TV Show Downloader/Manager |
| **SABnzbd** | *(Internal Only)* | `http://10.0.0.251:8085` | Usenet Download Client |
| **Prowlarr** | *(Internal Only)* | `http://10.0.0.251:9696` | Indexer Manager |
| **Tautulli** | [tautulli.valhalla-lab.duckdns.org](https://tautulli.valhalla-lab.duckdns.org) | `http://10.0.0.251:8181` | Plex Analytics |

### 🛠️ Infrastructure & Remote Access
| Service | External URL (HTTPS) | Internal (LAN) | Function |
| :--- | :--- | :--- | :--- |
| **Proxmox** | *(Internal Only)* | `https://10.0.0.250:8006` | Hypervisor Management |
| **Guacamole**| [rdp.valhalla-lab.duckdns.org](https://rdp.valhalla-lab.duckdns.org) | `http://10.0.0.251:8088` | HTML5 RDP Bridge to Tiny11 |
| **Dockge** | [dockge.valhalla-lab.duckdns.org](https://dockge.valhalla-lab.duckdns.org) | `http://10.0.0.251:5001` | Docker Compose Stack Manager |
| **Tailscale**| *(Cloud Admin)* | `bifroest` | VPN Subnet Router |
| **AdGuard** | *(Internal Only)* | `http://10.0.0.252` | Network-wide DNS Sinkhole |

### 📊 Monitoring & Utilities
| Service | External URL (HTTPS) | Internal (LAN) | Function |
| :--- | :--- | :--- | :--- |
| **BirdNET** | [birdnet.valhalla-lab.duckdns.org](https://birdnet.valhalla-lab.duckdns.org) | `http://10.0.0.251:8082` | AI Bird Song Classification |
| **Kuma** | [kuma.valhalla-lab.duckdns.org](https://kuma.valhalla-lab.duckdns.org) | `http://10.0.0.251:3001` | Uptime & System Monitoring |
| **Watchtower**| *(Headless)* | `http://10.0.0.251:8086` | Auto-Updater API |

---

## 🧠 4. Deep Dive: How the Systems Work

To ensure you can understand the system even after months of not touching it, here are the core mechanisms keeping the homelab running seamlessly.

### Docker Label Auto-Discovery (Homepage)
The central dashboard (`Homepage`) does not require manual configuration for every service. Instead, every `docker-compose.yml` file contains specific labels:
```yaml
labels:
  - "homepage.group=Media"
  - "homepage.name=Radarr"
  - "homepage.href=http://10.0.0.251:7878/"
```
When a container starts, Homepage automatically detects these labels and pins the service to the dashboard.

### Atomic Hardlinks (The ARRR Stack)
All media applications (Radarr, Sonarr, SABnzbd, Plex) share the exact same volume mount: `- /mnt/media:/mnt/media`.
* `/mnt/media/Downloads/usenet`
* `/mnt/media/MOVIES`
* `/mnt/media/TV`

Because the downloader (SABnzbd) and the managers (Radarr/Sonarr) see the *exact same filesystem structure*, they do not copy files when a download finishes. Instead, they create **hardlinks**. This means moving a 50GB movie from `Downloads` to `MOVIES` takes 0.1 seconds and uses 0 extra disk space.

### Guacamole RDP & Tiny11 Auto-Shutdown
`Guacamole` acts as a proxy translating standard RDP from the `Hugin` Tiny11 VM into HTML5/WebSockets, allowing you to control the VM directly in the browser via `rdp.valhalla-lab.duckdns.org`.
* **NPM WebSockets:** Guacamole requires WebSockets. In NPM, the `/websocket-tunnel` route explicitly disables `proxy_buffering` so the screen stream doesn't lag.
* **Auto-Shutdown:** To save RAM on Proxmox, the Tiny11 VM runs a Scheduled Task triggered by *RDP Disconnect* (which fires when you close the browser tab). It initiates a `shutdown /s /t 600` (10-minute timer). If you reconnect within 10 minutes, a second task `shutdown /a` aborts the shutdown.

### Disaster Recovery & Cloud Backups
To protect against catastrophic hardware failure, Proxmox is configured to automatically back up all VMs to a 5TB external USB drive, which is then securely mirrored to Google Drive.
* **NFS Storage Bridge:** The 5TB USB drive is passed through to Midgard (mounted at `/mnt/media`). Midgard exposes the `/mnt/media/ProxmoxBackups` folder back to Proxmox via an NFS share. Proxmox mounts this NFS share (`MidgardBackup`) to store all local `vzdump` archives, ensuring the limited 250GB internal SSD never fills up.
* **Encrypted Cloud Sync:** A global hook script (`/root/rclone-hook.sh` triggered via `/etc/vzdump.conf`) runs automatically after every backup job. It uses `rclone sync` to mirror the NFS backup folder to a `crypt` remote on Google Drive. Google only sees client-side encrypted gibberish.
* **Retention Management:** Retention policies (e.g., "Keep last 3") are managed natively in the Proxmox Backup UI. Because `rclone sync` creates a perfect 1:1 mirror, any old backups deleted locally by Proxmox are automatically pruned from Google Drive, preventing cloud storage bloat.

---

## 🔑 5. Credentials & SSH Reference

| Node / Service | Username | Default Password / Auth | SSH Command / URL |
| :--- | :--- | :--- | :--- |
| **Midgard (Docker VM)** | `odin` | `[SECRET]` / SSH Key | `ssh odin@10.0.0.251` |
| **Valhalla (Proxmox)** | `root` | System Password | `ssh root@10.0.0.250` |
| **Heimdall (AdGuard)** | `root` | LXC Root Password | `ssh root@10.0.0.252` |
| **Hugin (Tiny11)** | `hugin` | Windows Password | *(Via Guacamole)* |
| **Guacamole Web** | `odin` | `valhalla` | *(Web Login)* |
| **Tailscale Portal** | Google/Microsoft | OAuth Login | [login.tailscale.com](https://login.tailscale.com) |
| **NPM Admin** | `admin@example.com` | `changeme` | `10.0.0.251:81` |

> **Passwordless SSH:** The Windows VM has an `ed25519` key loaded into Midgard's `~/.ssh/authorized_keys`, allowing the Antigravity IDE and VSCode to connect seamlessly without passwords.

---

## 🚀 6. Local Management Script (`homelab.ps1`)

If you are on a Windows machine in the LAN, you can use the interactive control center script to manage the entire stack, check port health, and launch SSH sessions with a single click.

```powershell
# Open a PowerShell window:
cd C:\Antigravity\HomeLab
.\homelab.ps1
```

*(You can also find this script at `/opt/stacks/homelab.ps1` on the server).*

---

## 🔧 7. Troubleshooting & Known Issues

### Intel e1000e NIC "Detected Hardware Unit Hang"
The bare-metal Proxmox host (Valhalla) uses an Intel NIC that relies on the `e1000e` Linux driver. Under certain network loads, this hardware can freeze (link stays up, but no traffic routes) and logs `Detected Hardware Unit Hang` in `dmesg`.

**Fix Applied**: Hardware offloading features (TSO/GSO) have been explicitly disabled. This is a persistent fix implemented in `/etc/network/interfaces` on Valhalla:
```bash
iface nic0 inet manual
        post-up ethtool -K nic0 tso off gso off
```
*If this occurs again (which is highly unlikely), disconnecting and reconnecting the physical ethernet cable resets the hardware.*
