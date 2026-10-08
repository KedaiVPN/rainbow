#!/bin/bash
# Script update lisensi harian dari Vercel ke lokal (/usr/bin/.lic_data)
# Dijalankan via cronjob setiap malam jam 00:00

LIC_FILE="/usr/bin/.lic_data"
IP_FILE="/usr/bin/.ipvps"

if [[ ! -f "$IP_FILE" ]]; then
    MYIP=$(curl -sS --connect-timeout 30 -m 60 ipv4.icanhazip.com 2>/dev/null)
    if [[ -n "$MYIP" ]]; then
        echo "$MYIP" > "$IP_FILE"
    fi
fi

ipsaya=$(cat "$IP_FILE" 2>/dev/null)

if [[ -z "$ipsaya" ]]; then
    exit 1
fi

data_ip="https://licence-manager-nu.vercel.app/api/check/izintxt"
RAW_DATA=$(curl -sS --connect-timeout 30 -m 60 "$data_ip" 2>/dev/null | grep "$ipsaya")

if [[ -n "$RAW_DATA" ]]; then
    CLIENT_NAME=$(echo "$RAW_DATA" | awk '{print $2}')
    EXP_DATE=$(echo "$RAW_DATA" | awk '{print $3}')
    ALLOWED_IP=$(echo "$RAW_DATA" | awk '{print $4}')

    if [[ -n "$EXP_DATE" && -n "$ALLOWED_IP" ]]; then
        echo "NAME=$CLIENT_NAME" > "$LIC_FILE"
        echo "EXP=$EXP_DATE" >> "$LIC_FILE"
        echo "IP=$ALLOWED_IP" >> "$LIC_FILE"
        chmod 644 "$LIC_FILE"
    fi
fi
