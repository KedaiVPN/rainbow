#!/bin/bash
MYIP=$(cat /usr/bin/.ipvps)
    ALLOWED_IP=$(curl -sS "https://licence-manager-nu.vercel.app/api/check/izintxt" | grep "$MYIP" | awk '{print $4}')
    if [[ "$MYIP" == "$ALLOWED_IP" ]]; then
	ID_FILE="1a-D9XR-e5YJKgSInWEtrPWPlTNuS1rpv"
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
ns_domain_cloudflare() {
	DOMAIN=vpnnewbie.my.id
	DOMAIN_PATH=$(cat /etc/xray/domain)
	SUB=$(cat /etc/xray/domain | cut -d "." -f1)
	SUB_DOMAIN=${SUB}."${DOMAIN}"
	NS_DOMAIN=ns-${SUB_DOMAIN}
	CF_ID=makmurjoko462@gmail.com
        CF_KEYD=6fd48932b17010f35fb2a21be9e135aba162c
	IP=$(wget -qO- ipinfo.io/ip)
	echo "Updating DNS NS for ${NS_DOMAIN}..."
	ZONE=$(
		curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
		-H "X-Auth-Email: ${CF_ID}" \
		-H "X-Auth-Key: ${CF_KEYD}" \
		-H "Content-Type: application/json" | jq -r .result[0].id
	)

	RECORD=$(
		curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${NS_DOMAIN}" \
		-H "X-Auth-Email: ${CF_ID}" \
		-H "X-Auth-Key: ${CF_KEYD}" \
		-H "Content-Type: application/json" | jq -r .result[0].id
	)

	if [ "${#RECORD}" -le 10 ]; then
		RECORD=$(
			curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
			-H "X-Auth-Email: ${CF_ID}" \
			-H "X-Auth-Key: ${CF_KEYD}" \
			-H "Content-Type: application/json" \
			--data '{"type":"NS","name":"'${NS_DOMAIN}'","content":"'${DOMAIN_PATH}'","proxied":false}' | jq -r .result.id
		)
	fi

	RESULT=$(
		curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
		-H "X-Auth-Email: ${CF_ID}" \
		-H "X-Auth-Key: ${CF_KEYD}" \
		-H "Content-Type: application/json" \
		--data '{"type":"NS","name":"'${NS_DOMAIN}'","content":"'${DOMAIN_PATH}'","proxied":false}'
	)
	echo $NS_DOMAIN >/etc/xray/dns
}

setup_dnstt() {
	cd
	mkdir -p /etc/slowdns
	cd /etc/slowdns
	wget -O dnstt-server "${REPO}slowdns/dnstt-server" >/dev/null 2>&1
	chmod +x dnstt-server >/dev/null 2>&1
	wget -O dnstt-client "${REPO}slowdns/dnstt-client" >/dev/null 2>&1
	chmod +x dnstt-client >/dev/null 2>&1
	./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub
	chmod +x *
	wget -O /etc/systemd/system/client.service "${REPO}slowdns/client" >/dev/null 2>&1
	wget -O /etc/systemd/system/server.service "${REPO}slowdns/server" >/dev/null 2>&1
	sed -i "s/xxxx/$NS_DOMAIN/g" /etc/systemd/system/client.service 
	sed -i "s/xxxx/$NS_DOMAIN/g" /etc/systemd/system/server.service 
	systemctl daemon-reload
	systemctl enable server
	systemctl enable client
	systemctl start server
	systemctl start client
}
ns_domain_cloudflare
setup_dnstt