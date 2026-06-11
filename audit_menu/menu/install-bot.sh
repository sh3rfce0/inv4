grenbo="\e[92;1m"
NC='\e[0m'
fun_bar() {
CMD[0]="$1"
CMD[1]="$2"
(
[[ -e $HOME/fim ]] && rm $HOME/fim
${CMD[0]} >/dev/null 2>&1
${CMD[1]} >/dev/null 2>&1
touch $HOME/fim
) >/dev/null 2>&1 &
tput civis
echo -ne "  \033[0;33mPlease Wait Loading \033[1;37m- \033[0;33m["
while true; do
for ((i = 0; i < 18; i++)); do
echo -ne "\033[0;32m#"
sleep 0.1s
done
[[ -e $HOME/fim ]] && rm $HOME/fim && break
echo -e "\033[0;33m]"
sleep 1s
tput cuu1
tput dl1
echo -ne "  Please Wait Loading \033[1;37m- \033[0;33m["
done
echo -e "\033[0;33m]\033[1;37m -\033[1;32m OK !\033[1;37m"
tput cnorm
}
update_install() {
cd >/dev/null 2>&1
apt update >/dev/null 2>&1
apt upgrade -y >/dev/null 2>&1
apt install neofetch python3 python3-pip git -y >/dev/null 2>&1
}
setup_bot() {
wget "$(cat /etc/xray/license_server 2>/dev/null || echo "http://64.235.61.22:7888")/scripts/Bot/bot.zip" -O bot.zip >/dev/null 2>&1
wget "$(cat /etc/xray/license_server 2>/dev/null || echo "http://64.235.61.22:7888")/scripts/Bot/kyt.zip" -O /usr/bin/kyt.zip >/dev/null 2>&1
if [ -f "bot.zip" ] && [ -f "/usr/bin/kyt.zip" ]; then
rm -rf /usr/bin/Bot/ >/dev/null 2>&1
7z x -pHeyHeyMauDecryptYaAwokawokARISTORE bot.zip >/dev/null 2>&1
mkdir -p /usr/bin/Bot/ >/dev/null 2>&1
mv bot/* /usr/bin/Bot/ >/dev/null 2>&1
chmod +x /usr/bin/Bot/* >/dev/null 2>&1
rm -rf bot.zip bot
rm -rf /usr/bin/kyt/
cd /usr/bin/
7z x -pHeyHeyMauDecryptYaAwokawokARISTORE kyt.zip >/dev/null 2>&1
pip3 install -r /usr/bin/kyt/requirements.txt >/dev/null 2>&1
systemctl daemon-reload
systemctl start kyt
systemctl enable kyt
systemctl restart kyt
rm -rf kyt.zip kyt.sh
else
echo "Gagal mengunduh file Bot."
fi
}
clear
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\e[1;97;101m        UPDATE & INSTALL PACKAGES         \e[0m"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
fun_bar 'update_install'
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\e[1;97;101m          BOT SETUP IN PROGRESS           \e[0m"
echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
fun_bar 'setup_bot'
cd /root
rm -rf kyt.sh
echo -e "\033[1;32mInstallation complete!\033[0m"
read -n 1 -s -r -p " Press Enter for Back to Manage"
bash /usr/bin/m-bot