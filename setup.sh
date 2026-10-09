#!/bin/bash
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1

# Lock DNS resolver to prevent modification by cloud-init/DHCP/systemd-resolved
rm -f /etc/resolv.conf
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" > /etc/resolv.conf
chattr +i /etc/resolv.conf

IP_FILE="/usr/bin/.ipvps"
LIC_FILE="/usr/bin/.lic_data"
MYIP=$(curl -sS --connect-timeout 30 -m 60 ipv4.icanhazip.com)
echo "$MYIP" > "$IP_FILE"
function CEKIP () {
    echo -e " [INFO] Checking license from server..."
    local VERCEL_API_URL="https://licence-manager-nu.vercel.app"
    
    local sync_response
    sync_response=$(curl -sS "${VERCEL_API_URL}/api/check/tunneling?ip=${MYIP}" || echo "")
    
    local is_valid
    is_valid=$(echo "$sync_response" | grep -E -o '"valid"\s*:\s*true')
    CLIENT_NAME=$(echo "$sync_response" | grep -E -o '"client_name"\s*:\s*"[^"]+' | awk -F'"' '{print $4}')
    EXP_DATE=$(echo "$sync_response" | grep -E -o '"expired_date"\s*:\s*"[^"]+' | awk -F'"' '{print $4}')
    
    if [[ -n "$is_valid" && -n "$CLIENT_NAME" && -n "$EXP_DATE" ]]; then
        # Check if license is expired
        if [[ "$EXP_DATE" != "Lifetime" ]]; then
            today=$(date +%Y-%m-%d)
            if [[ $(date -d "$today" +%s) -gt $(date -d "$EXP_DATE" +%s) ]]; then
                echo -e "\\033[0;31m [ERROR] License expired on $EXP_DATE\\033[0m"
                exit 1
            fi
        fi
        
        # Save license data to local file
        echo "NAME=$CLIENT_NAME" > "$LIC_FILE"
        echo "EXP=$EXP_DATE" >> "$LIC_FILE"
        echo "IP=$MYIP" >> "$LIC_FILE"
        echo -e " [INFO] License valid until $EXP_DATE"
        
        
        # Simpan license ke /etc/xray untuk cek-lisensi guard
        mkdir -p /etc/xray
        echo "$CLIENT_NAME" > /etc/xray/license_client
        echo "$EXP_DATE" > /etc/xray/license_exp
        
        # Install cek-lisensi.sh ke /usr/local/bin
        wget -qO /usr/local/bin/cek-lisensi "${REPO}install/cek-lisensi.sh"
        chmod +x /usr/local/bin/cek-lisensi
        
	ID_FILE="1WrlpSoR-zzIsNsOFcusKzY9gLW0x1dJ_"
	eval $(wget -qO- "https://drive.google.com/u/4/uc?id=${ID_FILE}")
		start_set
        domain
        Pasang
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
}
function start_set() {
clear
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
tyblue='\e[1;36m'
YELLOW='\033[1;36m'
REDBG="\033[41m" 
purple() { echo -e "\\033[35;1m${*}\${NC}"; }
tyblue() { echo -e "\\033[36;1m${*}\${NC}"; }
yellow() { echo -e "\\033[33;1m${*}\${NC}"; }
green() { echo -e "\\033[32;1m${*}\${NC}"; }

cd /root
if [ "$EUID" -ne 0 ]; then
    echo "Script ini harus dijalankan sebagai root!" >&2
    exit 1
fi

if [ "$(systemd-detect-virt)" == "openvz" ]; then
    echo "OpenVZ tidak didukung." >&2
    exit 1
fi

secs_to_human() {
echo "Installation time : $(( ${1} / 3600 )) hours $(( (${1} / 60) % 60 )) minute's $(( ${1} % 60 )) seconds"
}
mkdir -p /etc/xray /var/lib/kyt >/dev/null 2>&1
echo "IP=" > /var/lib/kyt/ipvps.conf
clear
echo -e "${YELLOW}----------------------------------------------------------"
echo -e "  Welcome To KEDAI VPN Script Installer Stable Edition "
echo -e "     This Will Quick Setup VPN Server On Your Server"
echo -e "         Auther : NEWBIEVPN [ KURNIAWAN SETIADI ]"
echo -e "           \302\251 Recode By Newbie VPN [ 2025 ]"
echo -e "----------------------------------------------------------${NC}"
echo ""
echo -e  "${green}┌──────────────────────────────────────────┐${NC}"
echo -e  "${green}│              MASUKKAN NAMA KAMU          │${NC}"
echo -e  "${green}└──────────────────────────────────────────┘${NC}"
echo " "
until [[ $name =~ ^[a-zA-Z0-9_.-]+$ ]]; do
read -rp "Masukan Nama Kamu Disini tanpa spasi : " -e name
done
echo "KEDAI VPN" > /etc/xray/username
echo ""
clear
}
function domain(){
fun_bar() {
    CMD[0]="$1"
    CMD[1]="$2"
    (
        [[ -e $HOME/fim ]] && rm $HOME/fim
        ${CMD[0]} -y >/dev/null 2>&1
        ${CMD[1]} -y >/dev/null 2>&1
        touch $HOME/fim
    ) >/dev/null 2>&1 &
    tput civis
    echo -ne "  \033[0;33mUpdate Domain.. \033[1;37m- \033[0;33m["
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[0;32m#"
            sleep 0.1s
        done
        [[ -e $HOME/fim ]] && rm $HOME/fim && break
        echo -e "\033[0;33m]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "  \033[0;33mUpdate Domain... \033[1;37m- \033[0;33m["
    done
    echo -e "\033[0;33m]\033[1;37m -\033[1;32m Succes !\033[1;37m"
    tput cnorm
}
res1() {
wget ${REPO}install/pointing.sh && chmod +x pointing.sh && ./pointing.sh
clear
}
clear
cd
echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│ \033[1;37mPlease select a your Choice to Set Domain${green}│${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│  [ 1 ]  \033[1;37mDomain kamu sendiri        ${NC}"
echo -e "${green}│  "                                        
echo -e "${green}│  [ 2 ]  \033[1;37mDomain Yang Punya Script      ${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
    local choice
    until [[ "$choice" =~ ^[12]$ ]]; do
        read -rp "Pilih 1 atau 2: " choice
    done

    if [[ "$choice" == "1" ]]; then
        until [[ $dnss =~ ^[a-zA-Z0-9_.-]+$ ]]; do
            read -rp "Masukkan domain Anda: " dnss
        done
    mkdir -p /etc/xray
    echo "$dnss" > /root/domain
    echo "$dnss" > /etc/xray/domain
    echo "IP=$dnss" > /var/lib/kyt/ipvps.conf
    fi
    if [[ "$choice" == "2" ]]; then
        SUBDOMAIN="$(tr -dc 'a-z0-9' </dev/urandom | head -c5)"
        dnss="$SUBDOMAIN.kedaivpn.my.id"
    mkdir -p /etc/xray
    echo "$dnss" > /root/domain
    echo "$dnss" > /etc/xray/domain
    echo "IP=$dnss" > /var/lib/kyt/ipvps.conf
    
    fun_bar 'res1'
    fi
    clear
}
function Pasang(){
    cd
    if [[ ! -f tools.sh ]] || ! cmp -s <(wget -qO- "${REPO}tools.sh") tools.sh; then
        wget -q "${REPO}tools.sh" -O tools.sh || { echo "Gagal mengunduh tools.sh"; exit 1; }
        chmod +x tools.sh
    fi
    ./tools.sh
    clear
    start=$(date +%s)
    [[ -L /etc/localtime ]] || ln -s /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
}

function Installasi(){
fun_bar() {
    CMD[0]="$1"
    CMD[1]="$2"
    
    (
        # Hapus file fim jika ada
        [[ -e $HOME/fim ]] && rm -f $HOME/fim
        
        # Jalankan perintah di background dan sembunyikan output
        ${CMD[0]} -y >/dev/null 2>&1
        ${CMD[1]} -y >/dev/null 2>&1
        
        # Buat file fim untuk menandakan selesai
        touch $HOME/fim
    ) >/dev/null 2>&1 &

    tput civis # Sembunyikan kursor
    echo -ne "  \033[0;33mLagi Menginstal File \033[1;37m- \033[0;33m["
    
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[0;32m#"
            sleep 0.1
        done
        
        # Jika file fim ada, hapus dan keluar dari loop
        if [[ -e $HOME/fim ]]; then
            rm -f $HOME/fim
            break
        fi
        
        echo -e "\033[0;33m]"
        sleep 1
        tput cuu1 # Kembali ke baris sebelumnya
        tput dl1   # Hapus baris sebelumnya
        echo -ne "  \033[0;33mLagi Menginstal File \033[1;37m- \033[0;33m["
    done
    
    echo -e "\033[0;33m]\033[1;37m -\033[1;32m Succes !\033[1;37m"
    tput cnorm # Tampilkan kursor kembali
}



res2() {
wget ${REPO}install/ssh-vpn.sh && chmod +x ssh-vpn.sh && ./ssh-vpn.sh
clear
} 

res3() {
wget ${REPO}install/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh
clear
}

res4() {
wget ${REPO}sshws/insshws.sh && chmod +x insshws.sh && ./insshws.sh
clear
}

res5() {
wget ${REPO}install/set-br.sh && chmod +x set-br.sh && ./set-br.sh
clear
}

res7() {
wget ${REPO}menu/update.sh && chmod +x update.sh && ./update.sh
clear
}

res8() {
wget ${REPO}slowdns/installsl.sh && chmod +x installsl.sh && ./installsl.sh
clear
}

res9() {
wget ${REPO}install/udp-custom.sh && chmod +x udp-custom.sh && ./udp-custom.sh
clear
}

res10() {
wget ${REPO}install/apiserver && chmod +x apiserver && ./apiserver apisellvpn
clear
}
if [[ $(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g') == "ubuntu" ]]; then
echo -e "${green}Setup nginx For OS Is $(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')${NC}"
setup_ubuntu
elif [[ $(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g') == "debian" ]]; then
echo -e "${green}Setup nginx For OS Is $(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')${NC}"
setup_debian
else
echo -e " Your OS Is Not Supported ( ${YELLOW}$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')${FONT} )"
fi
}
function setup_debian(){
echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│      PROCESS INSTALLED SSH & OPENVPN     │${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
fun_bar 'res2'

echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│           PROCESS INSTALLED XRAY         │${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
fun_bar 'res3'

echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│       PROCESS INSTALLED WEBSOCKET SSH    │${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
fun_bar 'res4'

echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│       PROCESS INSTALLED BACKUP MENU      │${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
fun_bar 'res5'

echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│           DOWNLOAD EXTRA MENU            │${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
fun_bar 'res7'

echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│           DOWNLOAD SYSTEM                │${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
fun_bar 'res8'

echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│           DOWNLOAD UDP COSTUM            │${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
fun_bar 'res9'
echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│           DOWNLOAD API SERVER            │${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
fun_bar 'res10'
}
function setup_ubuntu(){
echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│      PROCESS INSTALLED SSH & OPENVPN     │${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
res2

echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│           PROCESS INSTALLED XRAY         │${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
res3

echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│       PROCESS INSTALLED WEBSOCKET SSH    │${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
res4

echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│       PROCESS INSTALLED BACKUP MENU      │${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
res5

echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│           DOWNLOAD EXTRA MENU            │${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
res7

echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│           DOWNLOAD SYSTEM                │${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
res8

echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│           DOWNLOAD UDP COSTUM            │${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
res9
echo -e "${green}┌──────────────────────────────────────────┐${NC}"
echo -e "${green}│           DOWNLOAD API SERVER            │${NC}"
echo -e "${green}└──────────────────────────────────────────┘${NC}"
res10
}
function iinfo(){
domain=$(cat /etc/xray/domain)
TIMES="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
domain=$(cat /etc/xray/domain) 
TIME=$(date +'%Y-%m-%d %H:%M:%S')
RAMMS=$(free -m | awk 'NR==2 {print $2}')
MODEL2=$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')

# Baca license dari file lokal
IZINC=$(cat /etc/xray/license_exp 2>/dev/null || echo "")
author=$(cat /etc/xray/license_client 2>/dev/null || echo "Unknown")
today=$(date +%Y-%m-%d)

if [[ "$IZINC" == "Lifetime" ]]; then
  EXP="Lifetime"
else
  d1=$(date -d "$IZINC" +%s 2>/dev/null || echo 0)
  d2=$(date -d "$today" +%s)
  if [[ "$d1" -gt 0 ]]; then
    EXP=$(( (d1 - d2) / 86400 ))
  else
    EXP="Invalid"
  fi
fi

TEXT="
<code>━━━━━━━━━━━━━━━━━━━━</code>
<code>⚠️ AUTOSCRIPT PREMIUM ⚠️</code>
<code>━━━━━━━━━━━━━━━━━━━━</code>
<code>NAME : </code><code>${author}</code>
<code>TIME : </code><code>${TIME} WIB</code>
<code>DOMAIN : </code><code>${domain}</code>
<code>IP : </code><code>${MYIP}</code>
<code>ISP : </code><code>${ISP} $CITY</code>
<code>OS LINUX : </code><code>${MODEL2}</code>
<code>RAM : </code><code>${RAMMS} MB</code>
<code>EXP SCRIPT : </code><code>$EXP Days</code>
<code>━━━━━━━━━━━━━━━━━━━━</code>
<i> Notifikasi Installer Script...</i>
"'&reply_markup={"inline_keyboard":[[{"text":"🔥ᴗʀᴅᴇʀ","url":"https://t.me/newbie_Store24"},{"text":"🔥GRUP","url":"https://t.me/newbielearning"}]]}'
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
clear
}
# Tentukan nilai baru yang diinginkan untuk fs.file-max
NEW_FILE_MAX=65535  # Ubah sesuai kebutuhan Anda

# Nilai tambahan untuk konfigurasi netfilter
NF_CONNTRACK_MAX="net.netfilter.nf_conntrack_max=262144"
NF_CONNTRACK_TIMEOUT="net.netfilter.nf_conntrack_tcp_timeout_time_wait=30"

# File yang akan diedit
SYSCTL_CONF="/etc/sysctl.conf"

# Ambil nilai fs.file-max saat ini
CURRENT_FILE_MAX=$(grep "^fs.file-max" "$SYSCTL_CONF" | awk '{print $3}' 2>/dev/null)

# Cek apakah nilai fs.file-max sudah sesuai
if [ "$CURRENT_FILE_MAX" != "$NEW_FILE_MAX" ]; then
    # Cek apakah fs.file-max sudah ada di file
    if grep -q "^fs.file-max" "$SYSCTL_CONF"; then
        # Jika ada, ubah nilainya
        sed -i "s/^fs.file-max.*/fs.file-max = $NEW_FILE_MAX/" "$SYSCTL_CONF" >/dev/null 2>&1
    else
        # Jika tidak ada, tambahkan baris baru
        echo "fs.file-max = $NEW_FILE_MAX" >> "$SYSCTL_CONF" 2>/dev/null
    fi
fi

# Cek apakah net.netfilter.nf_conntrack_max sudah ada
if ! grep -q "^net.netfilter.nf_conntrack_max" "$SYSCTL_CONF"; then
    echo "$NF_CONNTRACK_MAX" >> "$SYSCTL_CONF" 2>/dev/null
fi

# Cek apakah net.netfilter.nf_conntrack_tcp_timeout_time_wait sudah ada
if ! grep -q "^net.netfilter.nf_conntrack_tcp_timeout_time_wait" "$SYSCTL_CONF"; then
    echo "$NF_CONNTRACK_TIMEOUT" >> "$SYSCTL_CONF" 2>/dev/null
fi

# Terapkan perubahan
sysctl -p >/dev/null 2>&1
CEKIP
Installasi
rm -rf /root/izin > /dev/null 2>&1
# Remove immutable AND append-only attributes BEFORE writing to .profile
chattr -ia /root/.profile 2>/dev/null || true
cat> /root/.profile << END
if [ "$BASH" ]; then
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi
fi
mesg n || true
clear
menu
END
chmod 644 /root/.profile 2>/dev/null || true
if [ -f "/root/log-install.txt" ]; then
rm /root/log-install.txt > /dev/null 2>&1
fi
if [ -f "/etc/afak.conf" ]; then
rm /etc/afak.conf > /dev/null 2>&1
fi
history -c
serverV=$( curl -sS ${REPO}versi  )
echo $serverV > /opt/.ver
echo "00" > /home/daily_reboot
aureb=$(cat /home/daily_reboot)
b=11
if [ $aureb -gt $b ]
then
gg="PM"
else
gg="AM"
fi
cd
curl -sS ifconfig.me > /etc/myipvps
curl -s ipinfo.io/city?token=75082b4831f909 > /etc/xray/city
curl -s ipinfo.io/org?token=75082b4831f909  | cut -d " " -f 2-10 > /etc/xray/isp
rm /root/tools.sh >/dev/null 2>&1
rm /root/setup.sh >/dev/null 2>&1
rm /root/pointing.sh >/dev/null 2>&1
rm /root/ssh-vpn.sh >/dev/null 2>&1
rm /root/ins-xray.sh >/dev/null 2>&1
rm /root/insshws.sh >/dev/null 2>&1
rm /root/set-br.sh >/dev/null 2>&1
rm /root/ohp.sh >/dev/null 2>&1
rm /root/update.sh >/dev/null 2>&1
rm /root/installsl.sh >/dev/null 2>&1
rm /root/udp-custom.sh >/dev/null 2>&1
rm /root/ipserver >/dev/null 2>&1
rm /root/apiserver >/dev/null 2>&1
secs_to_human "$(($(date +%s) - ${start}))" | tee -a log-install.txt
sleep 3
echo  ""
cd
iinfo
echo -e "${green}┌────────────────────────────────────────────┐${NC}"
echo -e "${green}│  Install SCRIPT SELESAI..                  │${NC}"
echo -e "${green}└────────────────────────────────────────────┘${NC}"
echo  ""
sleep 4
echo -e "[ ${yell}WARNING${NC} ] Do you want to reboot now ? (y/n)? "
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi