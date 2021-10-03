#!/bin/bash
# IP Validation
MYIP=$(wget -qO- icanhazip.com);

# VPS Information
Checkstart1=$(ip route | grep default | cut -d ' ' -f 3 | head -n 1);
if [[ $Checkstart1 == "venet0" ]]; then 
	  lan_net="venet0"
    typevps="OpenVZ"
else
		lan_net="eth0"
    typevps="KVM"
fi
clear

# Getting OS Information
source /etc/os-release
Versi_OS=$VERSION
ver=$VERSION_ID
Tipe=$NAME
URL_SUPPORT=$HOME_URL
basedong=$ID

# VPS ISP INFORMATION
ITAM='\033[0;30m'
echo -e "$ITAM"
NAMAISP=$( curl -s ipinfo.io/org | cut -d " " -f 2-10  )
REGION=$( curl -s ipinfo.io/region )
#clear
COUNTRY=$( curl -s ipinfo.io/country )
#clear
WAKTU=$( curl -s ipinfo.ip/timezone )
#clear
CITY=$( curl -s ipinfo.io/city )
#clear
REGION=$( curl -s ipinfo.io/region )
#clear
WAKTUE=$( curl -s ipinfo.io/timezone )
#clear
koordinat=$( curl -s ipinfo.io/loc )
#clear
NC='\033[0m'
echo -e "$NC"

# Chek Status 
l2tp_status=$(systemctl status xl2tpd | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
openvpn_service="$(systemctl show openvpn.service --no-page)"
oovpn=$(echo "${openvpn_service}" | grep 'ActiveState=' | cut -f2 -d=)
status="$(systemctl show shadowsocks-libev.service --no-page)"
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
tls_v2ray_status=$(systemctl status v2ray | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
nontls_v2ray_status=$(systemctl status v2ray@none | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
vless_tls_v2ray_status=$(systemctl status v2ray@vless | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
vless_nontls_v2ray_status=$(systemctl status v2ray@vnone | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
ssr_status=$(systemctl status ssrmu | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
trojan_server=$(systemctl status trojan | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
dropbear_status=$(/etc/init.d/dropbear status | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
stunnel_service=$(/etc/init.d/stunnel4 status | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
sstp_service=$(systemctl status accel-ppp | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
squid_service=$(/etc/init.d/squid status | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
ssh_service=$(/etc/init.d/ssh status | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
vnstat_service=$(/etc/init.d/vnstat status | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
cron_service=$(/etc/init.d/cron status | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
fail2ban_service=$(/etc/init.d/fail2ban status | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
wg="$(systemctl show wg-quick@wg0.service --no-page)"
swg=$(echo "${wg}" | grep 'ActiveState=' | cut -f2 -d=)
sswg=$(systemctl status wg-quick@wg0 | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
wsdrop=$(systemctl status ws-dropbear | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
wstls=$(systemctl status ws-stunnel | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
wsovpn=$(systemctl status edu-ovpn | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)

# Color Validation
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'

# Status Service OpenVPN
if [[ $oovpn == "active" ]]; then
  status_openvpn="${GREEN}Service Is Running ${NC}[Aktif]"
else
  status_openvpn="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service  SSH 
if [[ $ssh_service == "running" ]]; then 
   status_ssh="${GREEN}Service Is Running ${NC}[Aktif]"
else
   status_ssh="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service  Squid 
if [[ $squid_service == "running" ]]; then 
   status_squid="${GREEN}Service Is Running ${NC}[Aktif]"
else
   status_squid="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service  VNSTAT 
if [[ $vnstat_service == "running" ]]; then 
   status_vnstat="${GREEN}Service Is Running ${NC}[Aktif]"
else
   status_vnstat="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service  Crons 
if [[ $cron_service == "running" ]]; then 
   status_cron="${GREEN}Service Is Running ${NC}[Aktif]"
else
   status_cron="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service  Fail2ban 
if [[ $fail2ban_service == "running" ]]; then 
   status_fail2ban="${GREEN}Service Is Running ${NC}[Aktif]"
else
   status_fail2ban="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service  TLS 
if [[ $tls_v2ray_status == "running" ]]; then 
   status_tls_v2ray="${GREEN}Service Is Running ${NC}[Aktif]"
else
   status_tls_v2ray="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service Non TLS V2Ray
if [[ $nontls_v2ray_status == "running" ]]; then 
   status_nontls_v2ray="${GREEN}Service Is Running ${NC}[Aktif]"
else
   status_nontls_v2ray="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service Vless HTTPS
if [[ $vless_tls_v2ray_status == "running" ]]; then
  status_tls_vless="${GREEN}Service Is Running ${NC}[Aktif]"
else
  status_tls_vless="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service Vless HTTP
if [[ $vless_nontls_v2ray_status == "running" ]]; then
  status_nontls_vless="${GREEN}Service Is Running ${NC}[Aktif]"
else
  status_nontls_vless="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# ShadowsocksR Status
if [[ $ssr_status == "running" ]] ; then
  status_ssr="${GREEN}Service Is Running ${NC}[Aktif]"
else
  status_ssr="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Sodosok
if [[ $status_text == "active" ]] ; then
  status_sodosok="${GREEN}Service Is Running ${NC}[Aktif]"
else
  status_sodosok="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service Trojan
if [[ $trojan_server == "running" ]]; then 
   status_virus_trojan="${GREEN}Service Is Running ${NC}[Aktif]"
else
   status_virus_trojan="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service Wireguard
if [[ $swg == "active" ]]; then
  status_wg="${GREEN}Service Is Running ${NC}[Aktif]"
else
  status_wg="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service L2TP
if [[ $l2tp_status == "running" ]]; then 
   status_l2tp="${GREEN}Service Is Running ${NC}[Aktif]"
else
   status_l2tp="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service Dropbear
if [[ $dropbear_status == "running" ]]; then 
   status_beruangjatuh="${GREEN}Service Is Running ${NC}[Aktif]"
else
   status_beruangjatuh="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service Stunnel
if [[ $stunnel_service == "running" ]]; then 
   status_stunnel="${GREEN}Service Is Running ${NC}[Aktif]"
else
   status_stunnel="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service SSTP
if [[ $sstp_service == "running" ]]; then 
   status_sstp="${GREEN}Service Is Running ${NC}[Aktif]"
else
   status_sstp="${RED}Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service Ws-Dropbear
if [[ $wsdrop == "running" ]]; then 
   wsdrop="${GREEN} Service Is Running ${NC}[Aktif]"
else
   wsdrop="${RED} Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service Ws-Stunnel
if [[ $wstls == "running" ]]; then 
   wstls="${GREEN} Service Is Running ${NC}[Aktif]"
else
   wstls="${RED} Service Is Not Running ${NC}[Not Aktif]"
fi

# Status Service ws-Ovpn 
if [[ $wsovpn == "running" ]]; then 
   wsovpn="${GREEN} Service Is Running ${NC}[Aktif]"
else
   wsovpn="${RED} Service Is Not Running ${NC}[Not Aktif]"
fi

# Ram Usage
total_r2am=` grep "MemAvailable: " /proc/meminfo | awk '{ print $2}'`
MEMORY=$(($total_r2am/1024))

# Download
download=`grep -e "lo:" -e "wlan0:" -e "eth0" /proc/net/dev  | awk '{print $2}' | paste -sd+ - | bc`
downloadsize=$(($download/1073741824))

# Upload
upload=`grep -e "lo:" -e "wlan0:" -e "eth0" /proc/net/dev | awk '{print $10}' | paste -sd+ - | bc`
uploadsize=$(($upload/1073741824))

# Total Ram
total_ram=` grep "MemTotal: " /proc/meminfo | awk '{ print $2}'`
totalram=$(($total_ram/1024))

# Tipe Processor
totalcore="$(grep -c "^processor" /proc/cpuinfo)" 
totalcore+=" Core"
corediilik="$(grep -c "^processor" /proc/cpuinfo)" 
tipeprosesor="$(awk -F ': | @' '/model name|Processor|^cpu model|chip type|^cpu type/ {
                        printf $2;
                        exit
                        }' /proc/cpuinfo)"

# Shell Version
shellversion=""
shellversion=Bash
shellversion+=" Version" 
shellversion+=" ${BASH_VERSION/-*}" 
versibash=$shellversion

# Getting CPU Information
cpu_usage1="$(ps aux | awk 'BEGIN {sum=0} {sum+=$3}; END {print sum}')"
cpu_usage="$((${cpu_usage1/\.*} / ${corediilik:-1}))"
cpu_usage+=" %"

# OS Uptime
uptime="$(uptime -p | cut -d " " -f 2-10)"

# Kernel Terbaru
kernelku=$(uname -r)

# Waktu Sekarang 
harini=`date -d "0 days" +"%d-%m-%Y"`
jam=`date -d "0 days" +"%X"`

# DNS Patch
tipeos2=$(uname -m)

# Getting Domain Name
Domen="$(cat /etc/v2ray/domain)"

# Echoing Result
echo -e ""
figlet    Status Service | lolcat
echo -e "In Here Is Your VPS Information : " | lolcat 
echo "-------------------------------------------------------------------------------" | lolcat 
echo "Operating System Information :" | lolcat 
echo -e "VPS Type    : $typevps"
echo -e "OS Arch     : $tipeos2"
echo -e "Hostname    : $HOSTNAME"
echo -e "OS Name     : $Tipe"
echo -e "OS Version  : $Versi_OS"
echo -e "OS BASE     : $basedong"
echo -e "OS TYPE     : Linux / Unix"
echo -e "Bash Ver    : $versibash"
echo -e "Kernel Ver  : $kernelku"
echo -e "Total RAM   : ${totalram}MB"
echo "-------------------------------------------------------------------------------" | lolcat 
echo "Internet Service Provider Information :" | lolcat 
echo -e "Public IP   : $MYIP"
echo -e "Domain      : $Domen"
echo -e "ISP Name    : $NAMAISP"
echo -e "Region      : $REGION "
echo -e "Country     : $COUNTRY"
echo -e "Time Zone   : $WAKTUE"
echo -e "Date        : $harini"
echo -e "Time        : $jam ( WIB )"
echo "-------------------------------------------------------------------------------" | lolcat 
echo "========================[System Status Information]============================" | lolcat 
echo -e "SSH / Tun           : $status_ssh"
echo -e "WebSocket Dropbear  :$wsdrop"
echo -e "WebSocket OpenVPN   :$wsovpn"
echo -e "WebSocket TLS       :$wstls"
echo -e "OpenVPN             : $status_openvpn"
echo -e "Dropbear            : $status_beruangjatuh"
echo -e "Stunnel             : $status_stunnel"
echo -e "Squid               : $status_squid"
echo -e "Fail2Ban            : $status_fail2ban"
echo -e "Crons               : $status_cron"
echo -e "Vnstat              : $status_vnstat"
echo -e "L2TP                : $status_l2tp"
echo -e "SSTP                : $status_sstp"
echo -e "V2Ray TLS           : $status_tls_v2ray"
echo -e "V2Ray HTTP          : $status_nontls_v2ray"
echo -e "Vless TLS           : $status_tls_vless"
echo -e "Vless HTTP          : $status_nontls_vless"
echo -e "SSR                 : $status_ssr"
echo -e "Shadowsocks         : $status_sodosok"
echo -e "Trojan              : $status_virus_trojan"
echo -e "Wireguard           : $status_wg"
echo "------------------------------------------------------------------------" | lolcat 
echo ""
