#!/bin/bash
function disable_services() {
    local reason=$1
    local SERVER_IP=$(curl -s https://ipinfo.io/ip/ || cat /usr/bin/.ipvps 2>/dev/null)
    echo -e "────────────────────────────────────────────"
    echo -e " ⚠️       AKSES DI TOLAK         ⚠️"
    echo -e "────────────────────────────────────────────"
    echo -e "❌  SCRIPT LOCKED "
    echo -e "🔒 Your VPS  Has been Banned"
    echo -e "⚠️ Lisensi kedaluwarsa / invalid: $reason"
    echo -e "🌐 IP server anda: $SERVER_IP"
    echo -e "💡 Beli izin resmi hanya dari Admin!"
    echo -e "📞 Contact Admin:"
    echo -e "🌍 Telegram: https://t.me/Kedai_vpn"
    echo -e "📱 WhatsApp: https://wa.me/6287777694482"
    echo -e "────────────────────────────────────────────"
    
    if [ "$1" == "--check-only" ] || [ "$2" == "--check-only" ]; then
        exit 1
    fi

    # Send message to all terminals
    wall "⚠️ VPS BANNED / $reason. SCRIPT LOCKED ⚠️"

    # Stop all related services
    systemctl stop nginx 2>/dev/null
    systemctl stop xray 2>/dev/null
    systemctl stop stunnel4 2>/dev/null
    systemctl stop dropbear 2>/dev/null
    systemctl stop haproxy 2>/dev/null

    # Disable them so they don't restart on boot
    systemctl disable nginx 2>/dev/null
    systemctl disable xray 2>/dev/null
    systemctl disable stunnel4 2>/dev/null
    systemctl disable dropbear 2>/dev/null
    systemctl disable haproxy 2>/dev/null

    # Update crontab to check every 3 minutes when expired/invalid
    sed -i "/cek-lisensi/d" /etc/crontab
    echo "*/3 * * * * root /usr/local/bin/cek-lisensi" >> /etc/crontab
    systemctl restart cron 2>/dev/null
    exit 1
}

function enable_services() {
    if [ "$1" == "--check-only" ] || [ "$2" == "--check-only" ]; then
        return 0
    fi

    # Check if services are already running to avoid unnecessary restarts
    if ! systemctl is-active --quiet xray 2>/dev/null; then
        echo -e "✅ Lisensi Aktif. Menghidupkan ulang layanan VPS..."
        wall "✅ VPS UNBANNED / Lisensi Aktif. SCRIPT UNLOCKED ✅"

        systemctl enable nginx 2>/dev/null
        systemctl enable xray 2>/dev/null
        systemctl enable stunnel4 2>/dev/null
        systemctl enable dropbear 2>/dev/null
        systemctl enable haproxy 2>/dev/null

        systemctl start nginx 2>/dev/null
        systemctl start xray 2>/dev/null
        systemctl start stunnel4 2>/dev/null
        systemctl start dropbear 2>/dev/null
        systemctl start haproxy 2>/dev/null
    fi
}

# Pengecekan hanya menggunakan file lokal (Hybrid Webhook Mode)
if [ ! -f /etc/xray/license_exp ]; then
    disable_services "Lisensi Tidak Ditemukan" "$1"
fi

local_exp=$(cat /etc/xray/license_exp 2>/dev/null)
if [[ "$local_exp" == "Lifetime" ]]; then
    enable_services "$1"
    if [ "$1" == "--check-only" ] || [ "$2" == "--check-only" ]; then
        exit 0
    fi
    sed -i '/cek-lisensi/d' /etc/crontab
    echo "10 0 * * * root /usr/local/bin/cek-lisensi" >> /etc/crontab
    systemctl restart cron 2>/dev/null
    exit 0
fi

# Validasi format tanggal untuk mencegah error date
if ! date -d "$local_exp" >/dev/null 2>&1; then
    disable_services "Format Lisensi Invalid" "$1"
fi

expiry_timestamp=$(date -d "$local_exp" +%s 2>/dev/null || echo 0)
current_timestamp=$(date +%s)

if [ "$expiry_timestamp" -le "$current_timestamp" ]; then
    disable_services "Masa Aktif Sudah Habis" "$1"
fi

# Jika masih aktif, pastikan service berjalan
enable_services "$1"

if [ "$1" == "--check-only" ] || [ "$2" == "--check-only" ]; then
    exit 0
fi

sed -i '/cek-lisensi/d' /etc/crontab
echo "10 0 * * * root /usr/local/bin/cek-lisensi" >> /etc/crontab
systemctl restart cron 2>/dev/null

exit 0
