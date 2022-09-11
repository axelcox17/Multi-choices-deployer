#!/bin/bash

apt update -y
apt install -y haproxy

cat << EOF >> /etc/haproxy/haproxy.cfg

frontend web_server
	bind *:80
	use_backend web_backend

backend web_backend
for (( i=1 ; i <= ${<##NUM##>} ; i++ ))
do
        cat << EOF >> /etc/haproxy/haproxy.cfg
server bckend 10.0.2.${i}:80
EOF
done

systemctl restart haproxy
