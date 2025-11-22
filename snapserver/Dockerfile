FROM alpine:edge

ARG LIBRESPOT_VERSION=0.8.0-r0
ARG SNAPCAST_VERSION=0.34.0-r0

RUN apk add --no-cache bash sed curl
RUN apk add --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community --no-cache snapcast=${SNAPCAST_VERSION}
RUN apk add --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing --no-cache librespot=${LIBRESPOT_VERSION}

COPY run.sh /
COPY eventhandler.sh /
RUN chmod -R 777 /eventhandler.sh
CMD ["/run.sh"]

ENV DEVICE_NAME=Marantz
EXPOSE 1704/tcp 1705/tcp
