echo "Enter the Service IP: "
read IP

echo "Enter the Service Port: "
read PORT

while true; do wget -q -O- http://$IP:$PORT ;done
