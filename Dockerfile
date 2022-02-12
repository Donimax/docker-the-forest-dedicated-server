FROM donimax/steamcmd:latest

LABEL maintainer="Donimax"

ENV WINEPREFIX=/winedata/WINE64 \
    WINEARCH=win64 \
    USER=steam \
    DISPLAY=:1.0 \
    TIMEZONE=Europe/Berlin \
    DEBIAN_FRONTEND=noninteractive \
    PUID=1000 \
    PGID=1000 \
    SERVERSTEAMACCOUNT=""

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get dist-upgrade -y \
    && apt-get install -y --no-install-recommends --no-install-suggests software-properties-common apt-transport-https gnupg2 wget procps lib32gcc-s1 nano winbind xvfb \
    && wget https://dl.winehq.org/wine-builds/winehq.key \
    && apt-key add winehq.key \
    && rm winehq.key \
    && echo "deb https://dl.winehq.org/wine-builds/debian/ bullseye main" >> /etc/apt/sources.list.d/winehq.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends winehq-stable \
    && apt-get remove -y --purge software-properties-common apt-transport-https gnupg2 \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir -p /config /winedata \
    && chown steam:steam /config \
    && chown steam:steam /winedata \
    && chown steam:steam /etc/bash.bashrc


COPY --chown=steam:steam servermanager.sh /usr/bin
COPY --chown=steam:steam defaults steamcmdinstall.txt server.cfg.example /

RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
    && echo $TIMEZONE > /etc/timezone \
    && chmod +x /usr/bin/servermanager.sh

EXPOSE 8766/tcp 8766/udp 27015/tcp 27015/udp 27016/tcp 27016/udp

# Switch to user
USER ${USER}

CMD ["servermanager.sh"]
