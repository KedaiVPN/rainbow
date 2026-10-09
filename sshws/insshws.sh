#!/bin/bash
MYIP=$(cat /usr/bin/.ipvps)
    ALLOWED_IP=$(curl -sS "https://licence-manager-nu.vercel.app/api/check/izintxt" | grep "$MYIP" | awk '{print $4}')
    if [[ "$MYIP" == "$ALLOWED_IP" ]]; then
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

file_path="/etc/handeling"

# Cek apakah file ada
if [ ! -f "$file_path" ]; then
    # Jika file tidak ada, buat file dan isi dengan dua baris
    echo -e "Kedai VPN\
Green" | sudo tee "$file_path" > /dev/null
    echo "File '$file_path' berhasil dibuat."
else
    # Jika file ada, cek apakah isinya kosong
    if [ ! -s "$file_path" ]; then
        # Jika file ada tetapi kosong, isi dengan dua baris
        echo -e "Kedai VPN\
Green" | sudo tee "$file_path" > /dev/null
        echo "File '$file_path' kosong dan telah diisi."
    else
        # Jika file ada dan berisi data, tidak lakukan apapun
        echo "File '$file_path' sudah ada dan berisi data."
    fi
fi
wget -O /usr/bin/ws "${REPO}sshws/ws"
wget -O /usr/bin/config.conf "${REPO}sshws/config.conf"
chmod +x /usr/bin/ws
cat > /etc/systemd/system/ws.service << END
[Unit]
Description=WebSocket E-Pro V1 By Newbie Store
Documentation=https://github.com/KedaiVPN
After=syslog.target network-online.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/bin/ws -f /usr/bin/config.conf
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=65535
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target

END

systemctl daemon-reload
systemctl enable ws.service
systemctl start ws.service
systemctl restart ws.service