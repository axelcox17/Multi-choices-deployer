#!/bin/bash

apt update -y
apt install -y haproxy

cat << EOF >> /etc/haproxy/haproxy.cfg

frontend web_server
	bind *:80
	use_backend web_backend

backend web_backend
	server bckend 10.0.2.40:80

EOF

systemctl restart haproxy
