#!/bin/bash

#Update your ip with digitalocean.com dns using APIv2
#ShaiChikorel

digiapi=$(cat digiapik)
homeip=$(curl -s ipinfo.io | jq -r '.ip')
remoteip=$(curl -s -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $digiapi" "https://api.digitalocean.com/v2/domains/chikorel.com/records/48211228/" | jq -r '.domain_record.data')

# check if jq install and if not install it
if [ ! -f /usr/bin/jq ]; then
	yum install jq -y 1>2 
	echo " jq was installed on your system"
fi

# compare localip with server ip
if [ $homeip != $remoteip ]; then
	curl -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer $digiapi" -d '{"data":"'"$homeip"'"}' "https://api.digitalocean.com/v2/domains/chikorel.com/records/48211228"
	echo " your localIP was update DNS myip.chikorel.com\n"
fi




# echo -e "\nyour ip is $homeip and the dns ip is $remoteip"

