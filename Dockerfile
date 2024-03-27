FROM hackebein/steamcmd:20.04

RUN apt update \
 && apt install -y \
        curl \
        jq \
        lib32stdc++6 \
		libtinfo5:i386 \
        unzip \
        wget \
        apt-transport-https \
        software-properties-common \
 && apt clean \
 && source /etc/os-release \
 && wget -q https://packages.microsoft.com/config/ubuntu/$VERSION_ID/packages-microsoft-prod.deb \
 && dpkg -i packages-microsoft-prod.deb \
 && rm packages-microsoft-prod.deb \
 && apt update \
 && apt install -y powershell \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /opt/steam /opt/overlay /srv \
 && chmod -R a=u /opt/steam /opt/overlay \
 && adduser -D steam


COPY entrypoint.ps1 /

EXPOSE 27015/tcp 27015/udp 27020/udp

WORKDIR /opt/steam
VOLUME /opt/steam
USER steam
ENV POWERSHELL_TELEMETRY_OPTOUT=1
ENTRYPOINT ["pwsh", "/entrypoint.ps1"]