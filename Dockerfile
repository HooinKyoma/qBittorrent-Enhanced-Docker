FROM alpine:3.19 as compilingqB

#compiling qB

ARG  LIBTORRENT_VER=1.2.19
ARG  QBITTORRENT_VER=4.6.3.10

RUN  apk add --no-cache ca-certificates make g++ gcc qt5-qtsvg-dev boost-dev qt5-qttools-dev file qt5-qtbase-dev \
&&   mkdir /qbtorrent \
#&&   wget -P /qbtorrent https://github.com/arvidn/libtorrent/releases/download/libtorrent-`echo "$LIBTORRENT_VER"|sed 's#\.#_#g'`/libtorrent-rasterbar-${LIBTORRENT_VER}.tar.gz \
&&   wget -P /qbtorrent https://github.com/arvidn/libtorrent/releases/download/v${LIBTORRENT_VER}/libtorrent-rasterbar-${LIBTORRENT_VER}.tar.gz \
&&   tar -zxvf /qbtorrent/libtorrent-rasterbar-${LIBTORRENT_VER}.tar.gz -C /qbtorrent \
&&   cd /qbtorrent/libtorrent-rasterbar-${LIBTORRENT_VER} \
&&   ./configure --host=x86_64-alpine-linux-musl \
&&   make install-strip -j$(nproc) \
#qBittorrent-Enhanced-Edition
&&   wget -P /qbtorrent https://github.com/c0re100/qBittorrent-Enhanced-Edition/archive/refs/tags/release-${QBITTORRENT_VER}.zip \
&&   unzip /qbtorrent/release-${QBITTORRENT_VER}.zip -d /qbtorrent \
&&   cd /qbtorrent/qBittorrent-Enhanced-Edition-release-${QBITTORRENT_VER} \
&&   ./configure --disable-gui --host=x86_64-alpine-linux-musl \
&&   make install -j$(nproc) \
&&   ldd /usr/local/bin/qbittorrent-nox   |cut -d ">" -f 2|grep lib|cut -d "(" -f 1|xargs tar -chvf /qbtorrent/qbittorrent.tar \
&&   mkdir /qbittorrent \
&&   tar -xvf /qbtorrent/qbittorrent.tar -C /qbittorrent \
&&   cp --parents /usr/local/bin/qbittorrent-nox /qbittorrent

 # docker qB
FROM alpine:3.19

ARG  S6_VER=3.1.6.2

ENV TRACKERSAUTO=true
ENV TRACKERS_LIST_URL=https://jsd.cdn.zzko.cn/gh/XIU2/TrackersListCollection/best.txt
ENV TZ=Asia/Shanghai
ENV WEBUIPORT=8989
ENV PUID=1000
ENV PGID=100
ENV UMASK=022

COPY root /
COPY --from=compilingqB /qbittorrent /

#install bash curl tzdata python3 shadow qt6
#RUN apk add --no-cache bash curl ca-certificates tzdata python3 shadow qt5-qtbase-sqlite qt5-qtbase libexecinfo \
RUN apk add --no-cache bash curl ca-certificates tzdata python3 shadow qt5-qtbase-sqlite qt5-qtbase \
#install s6-overlay
&& if [ "$(uname -m)" = "x86_64" ];then s6_arch=x86_64;elif [ "$(uname -m)" = "aarch64" ];then s6_arch=aarch64;elif [ "$(uname -m)" = "armv7l" ];then s6_arch=arm; fi \
&& wget --no-check-certificate https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-${s6_arch}.tar.xz \
&& wget --no-check-certificate https://github.com/just-containers/s6-overlay/releases/download/v${S6_VER}/s6-overlay-noarch.tar.xz \
&& tar -C / -Jxpf s6-overlay-${s6_arch}.tar.xz \
&& tar -C / -Jxpf s6-overlay-noarch.tar.xz \
#create qbittorrent user
&& useradd -u 1000 -U -d /config -s /bin/false qbittorrent \
&& usermod -G users qbittorrent \
#install Search
&& wget -P /tmp https://github.com/qbittorrent/search-plugins/archive/refs/heads/master.zip \
&& unzip /tmp/master.zip -d /tmp \
&& mkdir -p /usr/local/qbittorrent/defaults/Search \
&& cp /tmp/search-plugins-master/nova3/engines/*.py /usr/local/qbittorrent/defaults/Search \
#conf trackers
&& curl -so /tmp/trackers_all.txt $TRACKERS_LIST_URL \
&& Newtrackers="Bittorrent\TrackersList=$(awk '{if(!NF){next}}1' /tmp/trackers_all.txt|sed ':a;N;s/\n/\\n/g;ta' )" \
&& echo $Newtrackers >/tmp/Newtrackers.txt \
&& sed -i '/Bittorrent\\TrackersList=/r /tmp/Newtrackers.txt' /usr/local/qbittorrent/defaults/qBittorrent.conf \
&& sed -i '1,/^Bittorrent\\TrackersList=.*/{//d;}' /usr/local/qbittorrent/defaults/qBittorrent.conf \
#clear
&& rm s6-overlay-${s6_arch}.tar.xz \
&& rm s6-overlay-noarch.tar.xz \
&& rm -rf /var/cache/apk/* /tmp/* \
&& chmod a+x /usr/local/qbittorrent/updatetrackers.sh \
&& chmod a+x /usr/local/bin/qbittorrent-nox

VOLUME /downloads /config
EXPOSE 8989  6881  6881/udp
ENTRYPOINT [ "/init" ]
