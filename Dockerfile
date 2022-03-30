FROM alpine:3.14 as buildstage

ARG UDP2RAW_VERSION=20200818.0

RUN \
  echo " ****  Installing udp2raw ****" && \
  apk add --no-cache curl gzip && \
  mkdir -p /root-layer/usr/local/bin /tmp/udp2raw/ && \
  curl -fsSL "https://github.com/wangyu-/udp2raw/releases/download/${UDP2RAW_VERSION}/udp2raw_binaries.tar.gz" | \
    tar -xz -C /tmp/udp2raw/ && \
  chmod +x /tmp/udp2raw/udp2raw* && \
  mv /tmp/udp2raw/udp2raw* /root-layer/usr/local/bin/
  
# runtime stage
FROM alpine:3.14

ARG UDP2RAW_ARCH=amd64

LABEL maintainer="Ivan Moreno"

# Add files from buildstage
COPY --from=buildstage /root-layer/ /

RUN \
  echo "*** Configure udp2raw ***" && \
  mkdir -p /etc/udp2raw/ && \
  apk add --no-cache libstdc++ iptables && \
  echo "**** Symilink /usr/bin/udp2raw -> /usr/local/bin/udp2raw_$UDP2RAW_ARCH ****" && \
  ln -vs /usr/local/bin/udp2raw_${UDP2RAW_ARCH} /usr/bin/udp2raw

COPY udp2raw.conf /etc/udp2raw/udp2raw.conf

ENTRYPOINT ["/usr/bin/udp2raw"] 
CMD ["--conf-file", "/etc/udp2raw/udp2raw.conf"]
