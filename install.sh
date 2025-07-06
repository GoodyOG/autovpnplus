#!/bin/bash

# AutoVPN+ Installer
# This script is idempotent and can be re-run safely.

# --- Configuration ---
INSTALL_DIR="/opt/autovpnplus"
REPO_URL="https://raw.githubusercontent.com/GoodyOG/autovpnplus/main"

# --- Helper Functions ---
print_info() {
    echo -e "\n\e[1;34m[INFO]\e[0m $1"
}

print_success() {
    echo -e "\e[1;32m[SUCCESS]\e[0m $1"
}

print_error() {
    echo -e "\e[1;31m[ERROR]\e[0m $1" >&2
    exit 1
}

# --- Pre-flight Checks ---
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root."
fi

# --- Main Installation ---
clear
cat << "EOF"
 _____           _
|_   _|__   ___ | | ___  _ __ ___ _ __  ___
  | |/ _ \ / _ \| |/ _ \| '__/ _ \ '_ \/ __|
  | | (_) | (_) | | (_) | | |  __/ | | \__ \
  |_|\___/ \___/|_|\___/|_|  \___|_| |_|___/
      autovpnplus by GoodyOG
EOF
print_info "Starting AutoVPN+ installation..."

print_info "Updating package lists and installing dependencies..."
apt-get update -y
apt-get install -y curl wget screen nano jq git nodejs npm || print_error "Failed to install dependencies."

print_info "Creating installation directory structure at $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"/{scripts,utils,config,data,public,logs,backups} || print_error "Failed to create directories."

# --- File Download ---
print_info "Downloading repository files..."
files_to_download=(
    "menu.sh"
    "README.md"
    "ascii/banner.txt"
    "config/telegram_config.sh"
    "data/user_db.txt"
    "public/index.html"
    "scripts/l2tp_setup.sh"
    "scripts/ovpn_setup.sh"
    "scripts/ssh_setup.sh"
    "scripts/trojan_setup.sh"
    "scripts/xray_setup.sh"
    "utils/backup.js"
    "utils/backup.sh"
    "utils/http_banner_editor.sh"
    "utils/limit_checker.sh"
    "utils/restore.sh"
    "utils/ssh_limit_monitor.sh"
    "utils/xray_limit_monitor.sh"
)

for file_path in "${files_to_download[@]}"; do
    mkdir -p "$INSTALL_DIR/$(dirname "$file_path")"
    curl -sSL "$REPO_URL/$file_path" -o "$INSTALL_DIR/$file_path" || print_error "Failed to download $file_path"
done

# --- Setup Execution ---
print_info "Running setup scripts..."
bash "$INSTALL_DIR/scripts/ssh_setup.sh"
bash "$INSTALL_DIR/scripts/xray_setup.sh"
bash "$INSTALL_DIR/scripts/trojan_setup.sh"
bash "$INSTALL_DIR/scripts/l2tp_setup.sh"
bash "$INSTALL_DIR/scripts/ovpn_setup.sh"

print_info "Setting executable permissions..."
chmod +x "$INSTALL_DIR"/*.sh
chmod +x "$INSTALL_DIR"/utils/*.sh
chmod +x "$INSTALL_DIR"/scripts/*.sh

print_info "Setting up cronjobs for monitoring and backups..."
(crontab -l 2>/dev/null | grep -v 'autovpnplus') | crontab - # Clear old jobs
(crontab -l 2>/dev/null; echo "*/5 * * * * bash $INSTALL_DIR/utils/ssh_limit_monitor.sh >> $INSTALL_DIR/logs/cron.log 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "*/5 * * * * bash $INSTALL_DIR/utils/xray_limit_monitor.sh >> $INSTALL_DIR/logs/cron.log 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "0 3 * * * bash $INSTALL_DIR/utils/backup.sh auto >> $INSTALL_DIR/logs/cron.log 2>&1") | crontab -

print_info "Starting background services (limit checker & web UI)..."
screen -S avp_limit_checker -X quit &>/dev/null
screen -S avp_web_ui -X quit &>/dev/null
sleep 2

screen -dmS avp_limit_checker bash "$INSTALL_DIR/utils/limit_checker.sh"
cd "$INSTALL_DIR/utils" && npm install express multer &>/dev/null && screen -dmS avp_web_ui node "$INSTALL_DIR/utils/backup.js"

# --- Final Instructions ---
cat "$INSTALL_DIR/ascii/banner.txt"
echo ""
print_success "Installation complete!"
echo "-----------------------------------------------------"
echo "‼️ IMPORTANT NEXT STEPS ‼️"
echo ""
echo "1. Configure your Telegram Bot for alerts and backups:"
echo "   nano $INSTALL_DIR/config/telegram_config.sh"
echo ""
echo "2. The Web Backup/Restore Interface is running on:"
echo "   http://<your-server-ip>:3000"
echo ""
echo "3. To manage your VPS, run the menu command:"
echo "   bash $INSTALL_DIR/menu.sh"
echo ""
echo "   For easy access, create an alias:"
echo "   echo \"alias menu='bash $INSTALL_DIR/menu.sh'\" >> ~/.bashrc && source ~/.bashrc"
echo ""
echo "Thank you for using AutoVPN+."
echo "-----------------------------------------------------"
