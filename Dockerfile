FROM ubuntu:jammy

RUN apt update && apt install -y jq wget busybox
RUN wget 'https://vault.bitwarden.com/download/?app=cli&platform=linux' -O - | \
  busybox unzip -p - > /usr/local/bin/bw && chmod +x /usr/local/bin/bw
COPY bw_export.sh /

ENTRYPOINT [ "/bw_export.sh" ]
