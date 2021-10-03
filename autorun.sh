# Installing GeoGabut Auto Start Service
cat > /etc/systemd/system/geo.service << END
[Unit]
Description=GeoGabut Auto Starting Service
Documentation=https://sampiiiiu
Documentation=https://t.me/sampiiiiu/
[Service]
Type=oneshot
ExecStart=/bin/bash /etc/autorun.sh
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
END

# Make GeoGabut Service Configuration 
cat > /etc/autorun.sh << END
echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6 # Disable IPV6
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 1500 # Running BadVPN
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 1500 # Running BadVPN
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1500 # RUnning BadVPN
END

# Giving Permissiong For Autorun
chmod +x /etc/autorun.sh

# Starting GeoGabut Service
systemctl enable geo
systemctl start geo