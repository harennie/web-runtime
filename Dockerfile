FROM ghcr.io/xtls/xray-core:latest AS xray

FROM alpine:3
COPY --from=xray /usr/local/bin/xray /usr/local/bin/xray
COPY --chmod=755 entrypoint.sh /entrypoint.sh
# Guard against CRLF if the file was edited on Windows
RUN sed -i 's/\r$//' /entrypoint.sh
USER nobody
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
