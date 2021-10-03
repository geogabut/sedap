#!/bin/bash

read -p "Input New Domain : " domainbaru

#Validate
if [[ $domainbaru == "" ]]; then
echo "Please Input New Domain"
exit 1
fi

#Input To Domain
cat > /etc/v2ray/domain << END
$domainbaru
END

clear 
echo "SUCCESS"========================================================${NC}"
echo ""
echo "Please Input Your Pointing Domain In Cloudflare "
read -rp "Domain/Host: " -e host
echo "IP=$host" >> /var/lib/premium-script/ipvps.conf
#rm -f /home/homain
echo "$host" > /etc/v2ray/domain
echo -e "[${GREEN}Done${NC}]"

#Update Sertificate SSL
echo "Automatical Update Your Sertificate SSL"
sleep 3
echo Starting Update SSL Sertificate
sleep 0.5
source /var/lib/premium-script/ipvps.conf
domain=$IP
systemctl stop v2ray
systemctl stop v2ray@none
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/v2ray/v2ray.crt --keypath /etc/v2ray/v2ray.key --ecc
systemctl start v2ray
systemctl start v2ray@none

#Done
echo -e "[${GREEN}Done${NC}]"
echo "Location Your Domain : /etc/v2ray/domain"
echo ""
echo -e "${RED}Autoscript By Gabut${NC}"
