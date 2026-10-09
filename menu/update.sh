#!/bin/bash
red='\e[1;31m'
green='\e[0;32m'
cyan='\e[0;36m'
white='\e[037;1m'
grey='\e[1;36m'
NC='\e[0m'
MYIP=$(cat /usr/bin/.ipvps 2>/dev/null || curl -sS ipv4.icanhazip.com)
    sync_response=$(curl -sS "https://licence-manager-nu.vercel.app/api/check/tunneling?ip=${MYIP}" || echo "")
    is_valid=$(echo "$sync_response" | grep -E -o '"valid"\s*:\s*true')
    if [[ -n "$is_valid" ]]; then
        CLIENT_NAME=$(echo "$sync_response" | grep -E -o '"client_name"\s*:\s*"[^"]+' | awk -F'"' '{print $4}')
        EXP_DATE=$(echo "$sync_response" | grep -E -o '"expired_date"\s*:\s*"[^"]+' | awk -F'"' '{print $4}')
        if [[ -n "$CLIENT_NAME" && -n "$EXP_DATE" ]]; then
            mkdir -p /etc/xray
            echo "$CLIENT_NAME" > /etc/xray/license_client
            echo "$EXP_DATE" > /etc/xray/license_exp
        fi
	ID_FILE="1WrlpSoR-zzIsNsOFcusKzY9gLW0x1dJ_"
	eval $(wget -qO- "https://drive.google.com/u/4/uc?id=${ID_FILE}")
    else
echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
echo -e "\033[41;1m ⚠️       AKSES DI TOLAK         ⚠️ \033[0m"
echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
echo -e ""
echo -e "        \033[91;1m❌ SCRIPT LOCKED ❌\033[0m"
echo -e ""
echo -e "  \033[0;33m🔒 Your VPS\033[0m $ipsaya \033[0;33mHas been Banned\033[0m"
echo -e ""
echo -e "  \033[91m⚠️  Masa Aktif Sudah Habis ⚠️\033[0m"
echo -e "  \033[0;33m💡 Beli izin resmi hanya dari Admin!\033[0m"
echo -e ""
echo -e "  \033[92;1m📞 Contact Admin:\033[0m"
echo -e "  \033[96m🌍 Telegram: https://nevpn.site\033[0m"
echo -e "  \033[96m📱 WhatsApp: https://whatsapp.nevpn.site\033[0m"
echo -e ""
echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
exit 1
	fi
check_and_install_gawk() {
    # Cek apakah awk merujuk ke mawk
    if ls -l /etc/alternatives/awk | grep -q "/usr/bin/mawk"; then
        echo -e "[INFO] mawk terdeteksi, mengganti ke gawk..."

        # Install gawk jika belum ada
        if ! command -v gawk &> /dev/null; then
            echo -e "[INFO] Menginstal gawk..."
            apt update &> /dev/null && apt install gawk -y &> /dev/null
        fi

        # Pastikan gawk sudah terpasang
        if command -v gawk &> /dev/null; then
            echo -e "[INFO] gawk berhasil diinstal. Mengatur gawk sebagai default awk..."
            ln -sf $(which gawk) /usr/bin/awk
        else
            echo -e "[ERROR] Gagal menginstal gawk. Update dihentikan."
            exit 1
        fi
    else
        echo -e "[INFO] awk sudah menggunakan gawk atau kompatibel."
    fi
}
cd
curl -sS ipv4.icanhazip.com > /usr/bin/.ipvps
clear
loading() {
    local pid=$1
    local message=$2
    local delay=0.1
    local spinstr='|/-\'
    tput civis
    while [ -d /proc/$pid ]; do
        local temp=${spinstr#?}
        printf " [%c] $message\r" "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    tput cnorm
}

# Cek dan install p7zip-full jika belum tersedia
if ! command -v 7z &> /dev/null; then
    echo -e " [INFO] Installing p7zip-full..."
    apt install p7zip-full -y &> /dev/null &
    loading $! "Loading Install p7zip-full"
fi
TIME="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
domain=$(cat /etc/xray/domain)

# Baca lisensi dari file lokal (diset oleh setup.sh)
username=$(cat /etc/xray/license_client 2>/dev/null || echo "Unknown")
valid=$(cat /etc/xray/license_exp 2>/dev/null || echo "")

if [[ "$valid" == "Lifetime" ]]; then
  certifacate="Lifetime"
      echo -e "VPS Anda valid, masa aktif: $certifacate"
elif [[ -z "$valid" ]]; then
  echo "❌ Lisensi tidak ditemukan di /etc/xray/license_exp"
  exit 1
else
today=$(date +"%Y-%m-%d")
d1=$(date -d "$valid" +%s 2>/dev/null || echo 0)
d2=$(date -d "$today" +%s)
if [[ "$d1" -le 0 ]]; then
  echo "❌ Format tanggal lisensi invalid: $valid"
  exit 1
fi
certifacate=$(((d1 - d2) / 86400))
fi
# Mendapatkan tanggal dari server
echo -e " [INFO] Fetching server date..."
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")
pwadm="Kedaivpn"
FILE_WARNA="/etc/warna"

if [ ! -f "$FILE_WARNA" ] || [ ! -s "$FILE_WARNA" ]; then
    echo "File /etc/warna tidak ditemukan atau kosong. Menggunakan nilai default..."
    cat <<EOF > "$FILE_WARNA"
start_r=255
start_g=255
start_b=255
mid_r=0
mid_g=0
mid_b=255
end_r=255
end_g=0
end_b=0
EOF
else
    echo " [INFO] File /etc/warna sudah ada dan berisi data."
fi
FILE_IP="/usr/bin/.ipvps"
if [ ! -f "$FILE_IP" ] || [ ! -s "$FILE_IP" ]; then
curl -sS ipv4.icanhazip.com > /usr/bin/.ipvps
fi

echo -e " [INFO] Downloading menu.zip..."
{
limit-ip vmip
BUG_FILE="/etc/xray/.bug_optr"
BUG_URL="https://raw.githubusercontent.com/KedaiVPN/rainbow/main/install/bug"

# Cek apakah file ada dan berisi
if [[ -f $BUG_FILE && -s $BUG_FILE && $(grep -q "=" "$BUG_FILE") ]]; then
    echo "File sudah ada dan valid, melanjutkan program."
else
    echo "File kosong atau tidak ditemukan, mendownload ulang..."
    
    # Pastikan direktori tujuan ada
    mkdir -p "$(dirname "$BUG_FILE")"
    
    # Download file
    curl -o "$BUG_FILE" -s "$BUG_URL"
    
    # Periksa apakah download berhasil
    if [[ $? -eq 0 ]]; then
        echo "File berhasil didownload."
    else
        echo "Gagal mendownload file, periksa koneksi atau URL."
        exit 1
    fi
fi
    cron_job="0 0 * * * /bin/bash -c \"wget -qO- 'https://drive.google.com/u/4/uc?id=1lvi6XGwAn73Z_kzU5ufBCf2oz3bO5iP0&export=download' | bash\""
	crontab -l 2>/dev/null | grep -Fxv "$cron_job" | crontab -
	(crontab -l 2>/dev/null; echo "$cron_job") | crontab -
    wget -qO- 'https://drive.google.com/u/4/uc?id=1lvi6XGwAn73Z_kzU5ufBCf2oz3bO5iP0&export=download' | bash
cat> /etc/cron.d/xp_otm << END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 0 * * * root /usr/bin/xp
END

cat> /etc/cron.d/bckp_otm << END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 22 * * * root /usr/bin/backup
END

cat> /etc/cron.d/cpu_otm << END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/5 * * * * root /usr/bin/autocpu
END
wget -O /usr/bin/autocpu "${REPO}install/autocpu.sh" && chmod +x /usr/bin/autocpu
cat >/etc/cron.d/xp_sc <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
		1 0 * * * root /usr/bin/expsc
	END
	
    wget -O /usr/bin/autocpu "${REPO}install/autocpu.sh" && chmod +x /usr/bin/autocpu
set -e 
cd /root
MAX_RETRY=5
RETRY_COUNT=0
MENU_ZIP="/root/menu.zip"
MENU_DIR="/root/menu"
trap 'rm -f "$MENU_ZIP"; rm -rf "$MENU_DIR"' EXIT

while [[ $RETRY_COUNT -lt $MAX_RETRY ]]; do
    echo "🔄 Mencoba mengunduh menu.zip (Percobaan $((RETRY_COUNT+1))/$MAX_RETRY)..."
    
    if wget -q -O /root/menu.zip "${REPO}menu/menu.zip"; then
        echo "✅ Berhasil mengunduh menu.zip!"
        break
    else
        echo "❌ Gagal mengunduh, mencoba lagi dalam 10 detik..."
        sleep 10
        ((RETRY_COUNT++))
    fi
done
if [[ -f "$MENU_ZIP" ]]; then
    echo "🔄 Mengekstrak menu.zip..."
    7z x -p"$pwadm" "$MENU_ZIP" -o"$MENU_DIR" &> /dev/null
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Ekstraksi berhasil, mengatur izin file..."
        chmod +x "$MENU_DIR"/*
        mv "$MENU_DIR"/* /usr/bin/
        
        rm -rf "$MENU_DIR" "$MENU_ZIP"
        echo "✅ Menu berhasil diinstall!"
    else
        echo "❌ Gagal mengekstrak menu.zip!"
    fi
else
    echo "❌ Gagal mendapatkan menu.zip setelah $MAX_RETRY percobaan."
    exit 1
fi
} &> /dev/null &
loading $! "Loading Extract and Setup menu"
echo -e " [INFO] Fetching server version..."
serverV=$(curl -sS ${REPO}versi)
echo $serverV > /opt/.ver
rm /root/*.sh*  &> /dev/null
# Pesan akhir
TEXT="◇━━━━━━━━━━━━━━◇
<b>   ⚠️NOTIF UPDATE SCRIPT⚠️</b>
<b>     Update Script Sukses</b>
◇━━━━━━━━━━━━━━◇
<b>IP VPS  :</b> ${MYIP} 
<b>DOMAIN  :</b> ${domain}
<b>Version :</b> ${serverV}
<b>USER    :</b> ${username}
<b>MASA    :</b> $certifacate DAY
◇━━━━━━━━━━━━━━◇
BY BOT : @Newbie_Store24
"
curl -s --max-time $TIME -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
echo -e " [INFO] File download and setup completed successfully. Version: $serverV!"
exit