if [ -f /etc/xray/license_server ]; then
    LICENSE_SERVER=$(cat /etc/xray/license_server)
else
    LICENSE_SERVER="http://64.235.61.22:7888"
fi
IZIN_URL="${LICENSE_SERVER}/ip"
CACHE_DIR="/tmp/izin_cache"
CACHE_FILE="$CACHE_DIR/iplist.txt"
IPSAVE_FILE="/usr/bin/ipsave"
USER_FILE="/usr/bin/user"
EXP_FILE="/usr/bin/e"
mkdir -p "$CACHE_DIR" /etc/xray
MYIP=$(
curl -s --max-time 5 ipv4.icanhazip.com ||
curl -s --max-time 5 ifconfig.me ||
wget -qO- ipinfo.io/ip
)
[ -z "$MYIP" ] && { echo "❌ Gagal mengambil IP"; exit 1; }
echo "$MYIP" > "$IPSAVE_FILE"
if [ ! -f "$CACHE_FILE" ] || find "$CACHE_FILE" -mmin +10 | grep -q .; then
curl -s --max-time 8 "$IZIN_URL" -o "$CACHE_FILE"
fi
DATA=$(grep -w "$MYIP" "$CACHE_FILE")
if [ -z "$DATA" ]; then
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "        404 NOT FOUND AUTOSCRIPT            "
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "          PERMISSION DENIED !               "
echo "   Your VPS $MYIP is not whitelisted.        "
echo "   Please contact Admin for authorization.  "
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
rm -f "$USER_FILE" "$EXP_FILE"
exit 1
fi
USERNAME=$(awk '{print $2}' <<< "$DATA")
EXPIRED=$(awk '{print $3}' <<< "$DATA")
echo "$USERNAME" > "$USER_FILE"
echo "$EXPIRED" > "$EXP_FILE"
export IP="$MYIP"
export MYIP="$MYIP"
city="$(curl -fsS --max-time 5 ipinfo.io/city 2>/dev/null | tr -d '\r')"
[ -n "$city" ] && echo "$city" > /etc/xray/city
isp="$(curl -fsS --max-time 5 ipinfo.io/org 2>/dev/null | tr -d '\r' | cut -d' ' -f2-)"
[ -n "$isp" ] && echo "$isp" > /etc/xray/isp
clear
printf '%s\n' \
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" \
"       SHERIF VPN SICEPAT AKTIF ✅" \
" USER   : $USERNAME" \
" EXP    : $EXPIRED" \
" IP     : $MYIP" \
" CITY   : $city" \
" ISP    : $isp" \
"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sleep 2
clear
