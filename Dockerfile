ARG NGINX_VERSION=stable
FROM nginx:$NGINX_VERSION-alpine AS builder
ARG RTMP_VERSION=1.2.2

RUN wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
    tar -xf nginx-$NGINX_VERSION.tar.gz

RUN wget https://github.com/arut/nginx-rtmp-module/archive/refs/tags/v$RTMP_VERSION.tar.gz && \
    tar -xf v$RTMP_VERSION.tar.gz

RUN apk add gcc \
            libc-dev \
            make \
            openssl-dev \
            pcre-dev \
            zlib-dev \
            linux-headers \
            curl \
            gnupg \
            libxslt-dev \
            gd-dev \
            geoip-dev

RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
    CONFARGS=${CONFARGS/-Os -fomit-frame-pointer -g/-Os} && \
    cd /nginx-$NGINX_VERSION && \
    ./configure $CONFARGS --add-dynamic-module=/nginx-rtmp-module-$RTMP_VERSION/ && \
    make -j${nproc} modules && \
    mv /nginx-rtmp-module-$RTMP_VERSION/stat.xsl /srv/rtmp_stat.xsl

RUN wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz https://johnvansickle.com/ffmpeg/release-readme.txt && \
    tar -xf ffmpeg-release-amd64-static.tar.xz && \
    mv /ffmpeg-$(cat release-readme.txt | grep version: | sed 's/\s*version:\s*//')-amd64-static/ffmpeg /usr/bin


FROM nginx:$NGINX_VERSION-alpine
ENV TZ=Europe/Berlin
COPY --from=builder /nginx-$NGINX_VERSION/objs/ngx_rtmp_module.so /etc/nginx/modules/
COPY --from=builder /srv/rtmp_stat.xsl /srv/
COPY --from=builder /usr/bin/ffmpeg /usr/bin/
COPY nginx.conf /etc/nginx/nginx.conf
COPY gen-vod.sh gen-live.sh /docker-entrypoint.d/
COPY index.html /srv/

EXPOSE 80 1935