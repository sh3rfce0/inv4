NS=$(cat /etc/xray/dns) >/dev/null 2>&1
domain=$(cat /etc/xray/domain) >/dev/null 2>&1
grenbo="\e[92;1m"
NC='\e[0m'
cd /etc/systemd/system/ >/dev/null 2>&1
rm -rf kyt.service >/dev/null 2>&1
systemctl stop kyt  >/dev/null 2>&1
mkdir -p /usr/bin/kyt
rm -rf /usr/bin/kyt/var.txt
rm -rf /usr/bin/kyt/database.db
find /usr/bin/ -name "*.session*" -delete
clear
echo ""
figlet "ARI BOT" | lolcat
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\e[1;97;101m              ADD BOT PANEL               \e[0m"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "${grenbo}Tutorial Buat Bot Dan Mendapatkan ID Telegram"
echo -e "${grenbo}[*] Buat Bot Atau Dapatkan Token Bot: @BotFather"
echo -e "${grenbo}[*] Cara Cek ID Telegram: @MissRose_bot , perintah /info"
echo -e "${grenbo}[*] Cara Menggunakan Bot Multi ID Telegram ☞ 987654321,123456789"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\033[1;36mExample Input:\033[0m"
echo -e "${grenbo}[*] Bot Token: 123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11\033[0m"
echo -e "${grenbo}[*] Admin Telegram IDs: 987654321,123456789\033[0m"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -e -p "[*] Input your Bot Token : " bottoken
read -e -p "[*] Input Your Telegram ID : " admin
cat <<EOF > /usr/bin/kyt/var.txt
BOT_TOKEN='$bottoken'
ADMIN='$admin'
DOMAIN='$domain'
PUB='$PUB'
HOST='$NS'
EOF
echo -e "#bot# $bottoken $admin" > /etc/bot/.bot.db
clear
cat > /etc/systemd/system/kyt.service << END
[Unit]
Description=Simple kyt - @kyt
After=network.target
[Service]
WorkingDirectory=/usr/bin/
ExecStart=/usr/bin/python3 -m kyt
Restart=always
RestartSec=5    # Menunggu 5 detik sebelum restart
[Install]
WantedBy=multi-user.target
END
systemctl daemon-reload
systemctl start kyt
systemctl enable kyt
systemctl restart kyt
cd /root
clear
echo "Done"
echo "Your Data Bot"
echo -e "==============================="
echo "Token Bot     : $bottoken"
echo "Admin         : $admin"
echo "Domain        : $domain"
echo -e "==============================="
echo "Installations complete, type /menu on your bot"
read -n 1 -s -r -p " Press Enter for Back to Manage"
bash /usr/bin/m-bot