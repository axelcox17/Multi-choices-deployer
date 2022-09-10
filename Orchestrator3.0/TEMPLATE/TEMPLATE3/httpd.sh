#!/bin/bash

ping -c1 -w1 1.1.1.1
while [ $? -ne 0 ]
do
	ping -c1 -w1 1.1.1.1
done

apt update -y
apt install -y apache2 php libapache*php

rm /var/www/html/index.html
echo "<?php phpinfo(); ?>" | tee /var/www/html/index.php
