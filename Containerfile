FROM quay.io/fedora/fedora-silverblue:39
COPY ./script.sh ./script.sh
RUN chmod +x ./script.sh && ./script.sh
