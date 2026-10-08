#!/bin/bash
NC="\e[0m"
RED="\033[0;31m"
WH='\033[1;37m'
LIC_FILE="/usr/bin/.lic_data"
IP_FILE="/usr/bin/.ipvps"
ipsaya=$(cat "$IP_FILE" 2>/dev/null)
data_ip="https://licence-manager-nu.vercel.app/api/check/izintxt"

# Function to fetch license from Vercel and save to local file
fetch_license_from_vercel() {
    echo -e " [INFO] Fetching license data from server..."
    RAW_DATA=$(curl -sS --connect-timeout 30 -m 60 "$data_ip" 2>/dev/null | grep "$ipsaya")
    
    if [[ -z "$RAW_DATA" ]]; then
        echo -e "${RED} [ERROR] Failed to fetch license data from server${NC}"
        return 1
    fi
    
    CLIENT_NAME=$(echo "$RAW_DATA" | awk '{print $2}')
    EXP_DATE=$(echo "$RAW_DATA" | awk '{print $3}')
    ALLOWED_IP=$(echo "$RAW_DATA" | awk '{print $4}')
    
    if [[ -z "$EXP_DATE" || -z "$ALLOWED_IP" ]]; then
        echo -e "${RED} [ERROR] Invalid license data from server${NC}"
        return 1
    fi
    
    # Save to local file
    echo "NAME=$CLIENT_NAME" > "$LIC_FILE"
    echo "EXP=$EXP_DATE" >> "$LIC_FILE"
    echo "IP=$ALLOWED_IP" >> "$LIC_FILE"
    echo -e " [INFO] License data saved to local file"
    return 0
}

# Function to read license from local file
read_local_license() {
    if [[ ! -f "$LIC_FILE" ]]; then
        return 1
    fi
    
    CLIENT_NAME=""
    EXP_DATE=""
    ALLOWED_IP=""
    
    while IFS='=' read -r key value; do
        case "$key" in
            NAME) CLIENT_NAME="$value" ;;
            EXP) EXP_DATE="$value" ;;
            IP) ALLOWED_IP="$value" ;;
        esac
    done < "$LIC_FILE"
    
    if [[ -z "$EXP_DATE" ]]; then
        return 1
    fi
    
    return 0
}

# Function to check if license is expired
check_license_expiry() {
    local exp_date="$1"
    
    if [[ "$exp_date" == "Lifetime" ]]; then
        return 0  # Valid
    fi
    
    today=$(date +%Y-%m-%d)
    today_epoch=$(date -d "$today" +%s 2>/dev/null)
    exp_epoch=$(date -d "$exp_date" +%s 2>/dev/null)
    
    if [[ -z "$today_epoch" || -z "$exp_epoch" ]]; then
        echo -e "${RED} [ERROR] Invalid date format${NC}"
        return 2  # Error parsing date
    fi
    
    if [[ $today_epoch -gt $exp_epoch ]]; then
        return 1  # Expired
    fi
    
    return 0  # Valid
}

# Main license checking function
checking_sc() {
    # Step 1: Try to read from local file
    if read_local_license; then
        echo -e " [INFO] License loaded from local file"
    else
        # Step 2: Local file not found or corrupted, fetch from Vercel
        echo -e " [WARN] License file not found or corrupted, fetching from server..."
        if ! fetch_license_from_vercel; then
            # Fetch failed, skip enforcement this time (retry in 5 minutes)
            echo -e "${RED} [ERROR] Failed to fetch license, will retry in 5 minutes${NC}"
            return 0
        fi
        # Re-read from local file after successful fetch
        if ! read_local_license; then
            echo -e "${RED} [ERROR] Failed to read license after fetch${NC}"
            return 0
        fi
    fi
    
    # Step 3: Check if license is expired
    check_license_expiry "$EXP_DATE"
    expiry_status=$?
    
    if [[ $expiry_status -eq 0 ]]; then
        # License is VALID
        echo -e " [INFO] License valid until $EXP_DATE"
        
        # Check for script updates
        echo -e " [INFO] Fetching server version..."
        REPO="https://raw.githubusercontent.com/KedaiVPN/rainbow/main/"
        serverV=$(curl -sS --connect-timeout 10 -m 20 ${REPO}versi 2>/dev/null)
        
        if [[ -f /opt/.ver ]]; then
            localV=$(cat /opt/.ver)
        else
            localV="0"
        fi
        
        if [[ -n "$serverV" && "$serverV" != "$localV" ]]; then
            echo -e " [INFO] New version available: $serverV (current: $localV)"
            echo -e " [INFO] Starting update process..."
            cd /root
            wget -q https://raw.githubusercontent.com/KedaiVPN/rainbow/main/menu/update.sh -O update.sh
            if [[ -f update.sh ]]; then
                chmod +x update.sh
                ./update.sh
                echo "$serverV" > /opt/.ver
            fi
        else
            echo -e " [INFO] Script is up to date ($localV)"
        fi
        
        # Calculate remaining active days
        if [[ "$EXP_DATE" != "Lifetime" ]]; then
            today=$(date +"%Y-%m-%d")
            d1=$(date -d "$EXP_DATE" +%s 2>/dev/null)
            d2=$(date -d "$today" +%s 2>/dev/null)
            if [[ -n "$d1" && -n "$d2" ]]; then
                certificate=$(( (d1 - d2) / 86400 ))
                echo "$certificate Hari" > /etc/masaaktif 2>/dev/null
            fi
        else
            echo "Lifetime" > /etc/masaaktif 2>/dev/null
        fi

        # Check and restart services if needed
        for service in nginx xray haproxy ws kyt; do
            if systemctl list-unit-files 2>/dev/null | grep -q "^${service}\.service"; then
                if ! systemctl is-active --quiet "$service" 2>/dev/null; then
                    echo -e " [WARN] Service $service is not running, attempting restart..."
                    systemctl restart "$service" 2>/dev/null
                fi
            fi
        done
        
        # Monitor bash processes (prevent fork bomb)
        bash_count=$(pgrep -c bash 2>/dev/null || echo 0)
        if [[ $bash_count -gt 20 ]]; then
            echo -e " [WARN] Too many bash processes ($bash_count), killing excess..."
            pkill -9 bash 2>/dev/null
        fi
        
        return 0
        
    elif [[ $expiry_status -eq 1 ]]; then
        # License EXPIRED - Enforcement (Keep existing logic as requested)
        echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
        echo -e "\033[42m          LICENSE EXPIRED          \033[0m"
        echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
        echo -e ""
        echo -e "            \033[91;1mPERMISSION DENIED !\033[0m"
        echo -e "   \033[0;33mYour VPS\033[0m $ipsaya \033[0;33mHas Expired\033[0m"
        echo -e "   \033[0;33mExpired on:\033[0m $EXP_DATE"
        echo -e "     \033[0;33mRenew your license to continue\033[0m"
        echo -e "             \033[0;33mContact Admin :\033[0m"
        echo -e "      \033[2;32mWhatsApp\033[0m wa.me/6282326322300"
        echo -e "      \033[2;32mTelegram\033[0m t.me/newbie_store24"
        echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
        
        # Stop and disable services if active
        for service in nginx kyt xray ws haproxy; do
            if systemctl is-active --quiet "$service" 2>/dev/null; then
                systemctl stop "$service" 2>/dev/null
                systemctl disable "$service" 2>/dev/null
            fi
        done
        
        # Check reboot status
        status=$(curl -sS --connect-timeout 10 -m 20 https://pastebin.com/raw/RTUFB2cF 2>/dev/null)
        
        if [[ "$status" == "off" ]]; then
            reboot
        fi
        
        return 1
        
    else
        # Error parsing date, skip enforcement
        echo -e "${RED} [ERROR] Failed to parse expiry date, skipping enforcement${NC}"
        return 0
    fi
}

# Run the license check
checking_sc
