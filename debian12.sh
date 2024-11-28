#!/bin/bash

echo "Actualizando el sistema..."
apt update && apt upgrade -y

echo "Instalando paquetes requeridos..."
apt install -y ca-certificates apt-transport-https wget gnupg procps

echo "Agregando el repositorio de UniFi..."
echo 'deb [arch=amd64,arm64] https://www.ui.com/downloads/unifi/debian stable ubiquiti' > /etc/apt/sources.list.d/100-ubnt-unifi.list

echo "Agregando la clave GPG del repositorio de UniFi..."
wget -qO- https://dl.ui.com/unifi/unifi-repo.gpg | gpg --dearmor -o /usr/share/keyrings/unifi-archive-keyring.gpg

echo "Configurando MongoDB 5.0 (compatible con Debian 12)..."
wget -qO- https://www.mongodb.org/static/pgp/server-5.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg
echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg] https://repo.mongodb.org/apt/debian bullseye/mongodb-org/5.0 main" > /etc/apt/sources.list.d/mongodb-org-5.0.list

apt update
apt install -y mongodb-org

echo "Instalando UniFi Network Server..."
apt update && apt install -y unifi

echo "Configurando permisos y directorios para UniFi..."
chown -R unifi /var/lib/unifi /var/log/unifi /var/run/unifi

mkdir -p /var/lib/unifi/data
echo "unifi.db.name=ace" > /var/lib/unifi/data/system.properties
echo "unifi.db.host=localhost" >> /var/lib/unifi/data/system.properties
echo "unifi.db.port=27117" >> /var/lib/unifi/data/system.properties

echo "Instalando rsyslog..."
apt install -y rsyslog
mkdir -p /dev
mknod /dev/log c 1 3

echo "Iniciando el servicio de UniFi..."
service unifi start

echo "Mostrando logs de UniFi Network Server..."
tail -f /var/log/unifi/server.log

echo "La instalación ha finalizado. Puedes acceder a UniFi Network Server en: https://localhost:8443"
