FROM cm2network/steamcmd:root

SHELL ["/bin/bash", "-c"]
RUN apt-get update \
 && apt-get install -y \
     wget \
 && source /etc/os-release \
 && wget -q https://packages.microsoft.com/config/debian/$VERSION_ID/packages-microsoft-prod.deb \
 && dpkg -i packages-microsoft-prod.deb \
 && rm packages-microsoft-prod.deb \
 && apt-get update \
 && apt-get install -y powershell \
 #&& rm -rf /var/lib/apt/lists/* \
 && mkdir -p /opt/steam /opt/overlay /srv  \
 && chmod -R a=u /opt/steam /opt/overlay

ENV GLST=0 CollectionID=0 MaxPlayers=1
COPY entrypoint.ps1 /

EXPOSE 27005/udp 27015/udp

WORKDIR /opt/steam
VOLUME /opt/steam
USER steam
ENV POWERSHELL_TELEMETRY_OPTOUT=1
ENTRYPOINT ["pwsh", "/entrypoint.ps1"]