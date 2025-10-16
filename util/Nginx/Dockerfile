FROM --platform=$BUILDPLATFORM nginx:stable-alpine3.21

ARG TARGETPLATFORM
LABEL ye.vault.deepsafer.product="deepsafer"

ENV SSL_CERT_DIR=/etc/deepsafer/ca-certificates

RUN apk add --no-cache curl \
    shadow \
    && apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community gosu 

COPY util/Nginx/nginx.conf /etc/nginx
COPY util/Nginx/proxy.conf /etc/nginx
COPY util/Nginx/mime.types /etc/nginx
COPY util/Nginx/security-headers.conf /etc/nginx
COPY util/Nginx/security-headers-ssl.conf /etc/nginx
COPY util/Nginx/logrotate.sh /
COPY util/Nginx/entrypoint.sh /

EXPOSE 8080
EXPOSE 8443

RUN chmod +x /entrypoint.sh \
    && chmod +x /logrotate.sh

HEALTHCHECK CMD curl --insecure -Lfs https://192.168.168.40:8443/alive || curl -Lfs https://192.168.168.40:8080/alive || exit 1

ENTRYPOINT ["/entrypoint.sh"]
