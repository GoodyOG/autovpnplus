# AutoVPN+

<p align="center">
  <img src="https://img.shields.io/badge/OS-Ubuntu%20%26%20Debian-orange">
  <img src="https://img.shields.io/badge/Install-One--Liner-brightgreen">
  <img src="https://img.shields.io/badge/Scripts-Self--Contained-blue">
</p>
---

A comprehensive VPS AutoScript for setting up and managing various VPN protocols with user control features, designed for stability and ease of use.

## ✨ Features

- **Multi-Protocol Support**: SSH, XRAY (Vmess, Vless), Trojan, L2TP/IPSec, and OpenVPN.
- **Automated Monitoring**: Services are monitored, with alerts for limit breaches sent via Telegram.
- **Auto Backup System**: Daily backups are automatically created and sent to your Telegram (if configured).
- **Web UI & Manual Restore**: A simple web interface to download the latest backup or upload a file to restore it.
- **Management Menu**: A user-friendly command-line menu (`menu`) to manage the script's functions.

---

## ⚙️ Installation

Log in to your fresh **Ubuntu** or **Debian** VPS as **root** and run this single command:

```bash
bash <(curl -sSL [https://raw.githubusercontent.com/GoodyOG/autovpnplus/main/install.sh](https://raw.githubusercontent.com/GoodyOG/autovpnplus/main/install.sh))
