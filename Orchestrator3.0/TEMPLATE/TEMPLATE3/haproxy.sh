#!/bin/bash

apt update -y
apt install -y haproxy

cat << EOF >> /etc/haproxy/haproxy.cfg

frontend web_server
	bind *:80
	use_backend web_backend

backend web_backend
	server backend1 10.0.2.41:80
	server backend2 10.0.2.42:80
	server backend3 10.0.2.43:80
	server backend4 10.0.2.44:80
	server backend5 10.0.2.45:80
EOF

systemctl restart haproxy
