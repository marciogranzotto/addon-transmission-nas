ARG BUILD_FROM
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Setup base
RUN apk add --no-cache \
    coreutils=8.32-r2 \
    transmission-daemon=3.00-r2 \
    transmission-cli=3.00-r2 \
    openvpn=2.5.0-r1 \
    nginx=1.18.0-r13 \
    cifs-utils=6.12-r0

        
# Copy root filesystem
COPY rootfs /

# Small hack needed for ingress support
#
# Transmission always uses "transmission" as a subdirectory in the URL, so the web interface can for instance be found at:
#
#   http://<server>/transmission/web/
#
# The same goes for the RPC API, which is exposed under /transmission/rpc. When using ingress, this is not the case however
# and "transmission" directory is not part of the URL. So transmission is basically served under the root (/), e.g.:
#
#   http://10.0.10.110:8123/api/hassio_ingress/rQEi5X4zJFTmZ82ghplDjsx2AoK3r2lqx0zZHHjZ69Q/
#
# As the web UI uses a relative path when resolving the RPC endpoint, it basically becomes:
#
#   http://10.0.10.110:8123/api/hassio_ingress/rQEi5X4zJFTmZ82ghplDjsx2AoK3r2lqx0zZHHjZ69Q/../rpc
#
# which obviously is:
#
#   http://10.0.10.110:8123/api/hassio_ingress
#
# This will not work. The sed statement below changes the way the RPC endpoint is determined by keeping the regular endpoint
# when accessing transmission as usual, but stripping the relative part when using ingress.
RUN sed -i 's|'"'"'\.\./rpc'"'"'|window.location.pathname.endsWith("/web/") ? "../rpc" : "rpc"|' /usr/share/transmission/web/javascript/remote.js

# Build arugments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="Transmission NAS" \
    io.hass.description="The torrent client for Home Assistant with OpenVPN and Samba Share support" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Marcio Granzotto <contato@automarcio.com.br>" \
    org.opencontainers.image.title="Transmission" \
    org.opencontainers.image.description="The torrent client for Home Assistant with OpenVPN and Samba Share support" \
    org.opencontainers.image.vendor="Marcio Granzotto" \
    org.opencontainers.image.authors="Marcio Granzotto <contato@automarcio.com.br>" \
    org.opencontainers.image.source="https://github.com/marciogranzotto/addon-transmission-nas" \
    org.opencontainers.image.documentation="https://github.com/marciogranzotto/addon-transmission-nas/blob/master/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
