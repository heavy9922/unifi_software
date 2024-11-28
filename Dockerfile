# Usar una imagen base ligera
FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    systemd systemd-sysv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

STOPSIGNAL SIGRTMIN+3

# ENV container docker

CMD ["/lib/systemd/systemd"]

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /home

# Copiar el script al contenedor
COPY install_unifi.sh /home/

# Dar permisos de ejecución al script
RUN chmod +x /home/install_unifi.sh

# # # Comando predeterminado
# RUN ./install_unifi.sh

# ENTRYPOINT ["service", "unifi", "start"]
