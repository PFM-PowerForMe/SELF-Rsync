FROM docker.io/library/alpine:3.24 AS runtime

RUN apk add --no-cache rsync \
    && rm -f /etc/rsyncd.conf \
    && mkdir /data

COPY rootfs/entrypoint /usr/bin/entrypoint
RUN chmod +x /usr/bin/entrypoint

EXPOSE 873
VOLUME /data
ENTRYPOINT ["/usr/bin/entrypoint"]
