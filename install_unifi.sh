#!/bin/bash

echo "Actualizando el sistema..."
apt update && apt upgrade -y 

echo "Instalando paquetes requeridos..."
apt install -y ca-certificates apt-transport-https wget gnupg procps

echo "Agregando el repositorio de UniFi..."
echo 'deb [arch=amd64,arm64] https://www.ui.com/downloads/unifi/debian stable ubiquiti' > /etc/apt/sources.list.d/100-ubnt-unifi.list

echo "Agregando la clave GPG del repositorio de UniFi..."
wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg

echo "Configurando MongoDB 4.4 (requerido para UniFi)..."
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - 
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" > /etc/apt/sources.list.d/mongodb-org-4.4.list

apt update
apt install -y mongodb-org

echo "Instalando UniFi Network Server..."
apt update && apt install -y unifi

chown -R unifi /var/lib/unifi /var/log/unifi /var/run/unifi

mkdir -p /var/lib/unifi/data && \
    echo "unifi.db.name=ace" > /var/lib/unifi/data/system.properties && \
    echo "unifi.db.host=localhost" >> /var/lib/unifi/data/system.properties && \
    echo "unifi.db.port=27117" >> /var/lib/unifi/data/system.properties

apt install -y rsyslog
mkdir -p /dev
mknod /dev/log c 1 3


echo "Iniciando el servicio de UniFi..."
service unifi start

tail -f /var/log/unifi/server.log

echo "La instalación ha finalizado. Puedes acceder a UniFi Network Server en: https://localhost:8443"
