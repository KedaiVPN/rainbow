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

# License check using JSON API (same as Dynamic)
sync_response=$(curl -sS --connect-timeout 30 -m 60 "https://licence-manager-nu.vercel.app/api/check/tunneling?ip=${ipsaya}" 2>/dev/null || echo "")

is_valid=$(echo "$sync_response" | grep -E -o '"valid"\s*:\s*true')
CLIENT_NAME=$(echo "$sync_response" | grep -E -o '"client_name"\s*:\s*"[^"]+' | awk -F'"' '{print $4}')
EXP_DATE=$(echo "$sync_response" | grep -E -o '"expired_date"\s*:\s*"[^"]+' | awk -F'"' '{print $4}')

if [[ -n "$is_valid" && -n "$EXP_DATE" ]]; then
        echo "NAME=$CLIENT_NAME" > "$LIC_FILE"
        echo "EXP=$EXP_DATE" >> "$LIC_FILE"
        echo "IP=$ipsaya" >> "$LIC_FILE"
        chmod 644 "$LIC_FILE"
    fi
fi
