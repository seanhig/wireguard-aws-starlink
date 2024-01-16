
WG_CONFIG="/etc/wireguard/wg0.conf"
WG_SRV_ADDRESS="192.168.10.1/24"
WG_LISTEN_PORT=51820

sudo apt-get update
sudo apt-get -y install wireguard iperf inetutils-ping resolvconf 

wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey

PUBLICKEY=`sudo cat /etc/wireguard/publickey` 
PRIVATEKEY=`sudo cat /etc/wireguard/privatekey` 

echo "Public Key: ${PUBLICKEY}"
echo "Private Key: ${PRIVATEKEY}"

NIC_NAME=`sudo ls /sys/class/net | grep e`

cat << EOF > $WG_CONFIG
[Interface]
Address = ${WG_SRV_ADDRESS}
MTU = 1300
SaveConfig = true
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ${NIC_NAME} -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ${NIC_NAME} -j MASQUERADE
ListenPort = ${WG_LISTEN_PORT}
PrivateKey = ${PRIVATEKEY}
EOF

sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -p

sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

