#!/bin/bash
MYIP=$(cat /usr/bin/.ipvps)
    ALLOWED_IP=$(curl -sS "https://licence-manager-nu.vercel.app/api/check/izintxt" | grep "$MYIP" | awk '{print $4}')
    if [[ "$MYIP" == "$ALLOWED_IP" ]]; then
	ID_FILE="1RWzdtBtqJH6D0KjGNkwOwJUVxUyc2Zkr"
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
Add_To_New_Line(){
	if [ "$(tail -n1 $1 | wc -l)" == "0"  ];then
		echo "" >> "$1"
	fi
	echo "$2" >> "$1"
}

Check_And_Add_Line(){
	if [ -z "$(cat "$1" | grep "$2")" ];then
		Add_To_New_Line "$1" "$2"
	fi
}

Install_BBR(){
echo "#############################################"
echo "Install TCP_BBR BY NEWBIE STORE..."
if [ -n "$(lsmod | grep bbr)" ];then
echo "TCP_BBR sudah diinstall."
echo "#############################################"
return 1
fi
echo "Mulai menginstall TCP_BBR..."
modprobe tcp_bbr
Add_To_New_Line "/etc/modules-load.d/modules.conf" "tcp_bbr"
Add_To_New_Line "/etc/sysctl.conf" "net.core.default_qdisc = fq"
Add_To_New_Line "/etc/sysctl.conf" "net.ipv4.tcp_congestion_control = bbr"
sysctl -p
if [ -n "$(sysctl net.ipv4.tcp_available_congestion_control | grep bbr)" ] && [ -n "$(sysctl net.ipv4.tcp_congestion_control | grep bbr)" ] && [ -n "$(lsmod | grep "tcp_bbr")" ];then
	echo "TCP_BBR Install Success."
else
	echo "Gagal menginstall TCP_BBR."
fi
echo "#############################################"
}

Optimize_Parameters(){
echo "#############################################"
echo "Optimasi Parameters..."
Check_And_Add_Line "/etc/security/limits.conf" "* soft nofile 51200"
Check_And_Add_Line "/etc/security/limits.conf" "* hard nofile 51200"
Check_And_Add_Line "/etc/security/limits.conf" "root soft nofile 51200"
Check_And_Add_Line "/etc/security/limits.conf" "root hard nofile 51200"
Check_And_Add_Line "/etc/sysctl.conf" "fs.file-max = 51200"
Check_And_Add_Line "/etc/sysctl.conf" "net.core.rmem_max = 67108864"
Check_And_Add_Line "/etc/sysctl.conf" "net.core.wmem_max = 67108864"
Check_And_Add_Line "/etc/sysctl.conf" "net.core.netdev_max_backlog = 250000"
Check_And_Add_Line "/etc/sysctl.conf" "net.core.somaxconn = 4096"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_syncookies = 1"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_tw_reuse = 1"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_fin_timeout = 30"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_keepalive_time = 1200"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.ip_local_port_range = 10000 65000"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_max_syn_backlog = 8192"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_max_tw_buckets = 5000"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_fastopen = 3"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_mem = 25600 51200 102400"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_rmem = 4096 87380 67108864"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_wmem = 4096 65536 67108864"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_mtu_probing = 1"
echo "Optimasi Parameters Selesai."
echo "#############################################"
}
Install_BBR
Optimize_Parameters
rm -f /root/bbr.sh