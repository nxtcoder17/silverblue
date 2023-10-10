ARG FEDORA_MAJOR_VERSION=39

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}
COPY ./script.sh /tmp/script.sh
RUN chmod +x /tmp/script.sh && /tmp/script.sh
