# Usar una imagen base ligera
FROM debian:bullseye-slim

# Configurar variables de entorno
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y gnupg wget ca-certificates openjdk-17-jre-headless binutils libcap2 curl logrotate procps  && apt clean && rm -rf /var/lib/apt/lists/* && apt --fix-broken install

RUN java -version

RUN echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

RUN wget -O /tmp/unifi.deb https://dl.ui.com/unifi/8.6.9/unifi_sysvinit_all.deb

RUN wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add - && echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" > /etc/apt/sources.list.d/mongodb-org-4.4.list

RUN apt update && apt install -y mongodb-org && apt clean && rm -rf /var/lib/apt/lists/*

# Crear el archivo system.properties con configuraciones predeterminadas
RUN mkdir -p /usr/lib/unifi/data && \
    echo "unifi.db.name=ace" > /usr/lib/unifi/data/system.properties && \
    echo "unifi.db.host=localhost" >> /usr/lib/unifi/data/system.properties && \
    echo "unifi.db.port=27117" >> /usr/lib/unifi/data/system.properties

RUN dpkg -i /tmp/unifi.deb || apt -f install -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# Crear volúmenes para persistencia de datos y logs
VOLUME ["/var/lib/unifi", "/var/log/unifi", "/var/run/unifi"]

# Exponer los puertos necesarios para UniFi
EXPOSE 8080 8443 8843 8880 3478/udp

# Configurar el punto de entrada para iniciar el servicio UniFi
ENTRYPOINT ["/usr/lib/jvm/java-17-openjdk-amd64/bin/java", "-Xmx1024M", "-jar", "/usr/lib/unifi/lib/ace.jar", "start"]
