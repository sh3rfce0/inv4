#!/bin/bash
# Interactive Domain Setup by Antigravity

# Get public IP
IP=$(curl -s ipv4.icanhazip.com)
echo -e "\e[1;36m================================================\e[0m"
echo -e "\e[1;37m             SETUP DOMAIN VPS                   \e[0m"
echo -e "\e[1;36m================================================\e[0m"
echo -e "IP VPS Anda saat ini: \e[1;32m${IP}\e[0m"
echo -e ""
echo -e "Silakan pilih metode setup domain:"
echo -e "1) Gunakan Domain/Subdomain Sendiri (Sudah di-pointing ke IP VPS)"
echo -e "2) Auto-Generate menggunakan Cloudflare API (Masukkan Email & Key Anda)"
echo -e "3) Lewati (Gunakan IP default)"
echo -e ""
read -p "Pilihan [1-3]: " opt

DOMAIN_NAME=""

case $opt in
    1)
        echo -e ""
        read -p "Masukkan Domain/Subdomain Anda (contoh: ssh1.v-pn.dev): " USER_DOMAIN
        if [ -z "$USER_DOMAIN" ]; then
            echo "❌ Domain tidak boleh kosong!"
            exit 1
        fi
        DOMAIN_NAME="$USER_DOMAIN"
        ;;
    2)
        echo -e ""
        read -p "Masukkan Cloudflare Email: " CF_ID
        read -p "Masukkan Cloudflare API Key (Global API Key): " CF_KEY
        read -p "Masukkan Domain Utama (contoh: v-pn.dev): " CF_DOMAIN
        read -p "Masukkan Subdomain yang diinginkan (contoh: ssh1): " CF_SUB
        
        if [ -z "$CF_ID" ] || [ -z "$CF_KEY" ] || [ -z "$CF_DOMAIN" ] || [ -z "$CF_SUB" ]; then
            echo "❌ Semua bidang Cloudflare harus diisi!"
            exit 1
        fi
        
        echo "🔎 Menghubungkan ke Cloudflare..."
        ZONE="$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${CF_DOMAIN}&status=active" \
        -H "X-Auth-Email: ${CF_ID}" \
        -H "X-Auth-Key: ${CF_KEY}" \
        -H "Content-Type: application/json" | jq -r '.result[0].id')"
        
        if [[ -z "${ZONE}" || "${ZONE}" == "null" ]]; then
            echo "❌ Zone ID tidak ditemukan! Pastikan Email dan API Key benar."
            exit 1
        fi
        
        RECORD="$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?type=A&name=${CF_SUB}.${CF_DOMAIN}" \
        -H "X-Auth-Email: ${CF_ID}" \
        -H "X-Auth-Key: ${CF_KEY}" \
        -H "Content-Type: application/json" | jq -r '.result[0].id')"
        
        if [[ -n "${RECORD}" && "${RECORD}" != "null" ]]; then
            echo "♻️ Menghapus DNS lama..."
            curl -sLX DELETE "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
            -H "X-Auth-Email: ${CF_ID}" \
            -H "X-Auth-Key: ${CF_KEY}" \
            -H "Content-Type: application/json" >/dev/null
        fi
        
        echo "➕ Membuat DNS record baru..."
        NEW="$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
        -H "X-Auth-Email: ${CF_ID}" \
        -H "X-Auth-Key: ${CF_KEY}" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"${CF_SUB}.${CF_DOMAIN}\",\"content\":\"${IP}\",\"ttl\":120,\"proxied\":false}")"
        
        if [[ "$(echo "${NEW}" | jq -r '.success')" == "true" ]]; then
            DOMAIN_NAME="${CF_SUB}.${CF_DOMAIN}"
            echo "✔️ Berhasil terhubung: ${DOMAIN_NAME} → ${IP}"
        else
            echo "❌ Gagal membuat DNS di Cloudflare!"
            exit 1
        fi
        ;;
    *)
        echo "⚠️ Melewati setup domain. Menggunakan IP default."
        DOMAIN_NAME=""
        ;;
esac

if [ -n "$DOMAIN_NAME" ]; then
    mkdir -p /etc/xray
    mkdir -p /var/lib/kyt
    echo "${DOMAIN_NAME}" > /etc/xray/domain
    echo "${DOMAIN_NAME}" > /root/domain
    echo "IP=${DOMAIN_NAME}" > /var/lib/kyt/ipvps.conf
    echo -e "\e[1;32m🎉 Sukses! Domain disimpan: ${DOMAIN_NAME}\e[0m"
else
    # default to IP
    mkdir -p /etc/xray
    mkdir -p /var/lib/kyt
    echo "${IP}" > /etc/xray/domain
    echo "${IP}" > /root/domain
    echo "IP=${IP}" > /var/lib/kyt/ipvps.conf
fi
sleep 2
