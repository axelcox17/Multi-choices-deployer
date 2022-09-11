#!/bin/bash
INFRA_NAME=$1
KEY_NAME=$2
NUMBER=$3
TEMPLATE=$4

mkdir DEPLOYED
cp -r TEMPLATE/${TEMPLATE} DEPLOYED/${INFRA_NAME}
cd DEPLOYED/${INFRA_NAME}
if [ ${NUMBER} -gt 0 ]
then
        for (( i=1; i<=${NUMBER}; i++ ))
        do
            cp ../../TEMPLATE/TEMPLATE3/server-web.tf server-web${i}.tf
            sed -i "s|<##NUM##>|${i}|g" server-web${i}.tf
        done

        rm -rf server-web.tf
fi

sed -i "s|<##INFRA_NAME##>|${INFRA_NAME}|g" *
sed -i "s|<##KEY_NAME##>|${KEY_NAME}|g" *
terraform init
terraform apply -auto-approve

IP=$(cat temp_ip)
NB_SPACE=$(( 16 - $(echo ${IP} | wc -c) ))
SPACES=""
I=0
while [ $I -lt $NB_SPACE ]
do
        SPACES=${SPACES}" "
        I=$(( $I + 1 ))
done
cat << EOF
############################################################
############################################################
########                                           #########
########                                           #########
########    Web App Available at : ${IP}${SPACES}#########
########                                           #########
########                                           #########
############################################################
############################################################
EOF
exit
