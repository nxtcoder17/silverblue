FROM quay.io/fedora-ostree-desktops/silverblue:39
COPY ./script.sh ./script.sh
RUN chmod +x ./script.sh && ./script.sh
