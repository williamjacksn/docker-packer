FROM python:3.8.1-alpine3.11

ARG PACKER_VERSION="1.5.1"

RUN /usr/local/bin/pip install --no-cache-dir "ruamel.yaml==0.16.5" \
 && /usr/bin/wget "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" \
 && /usr/bin/unzip "/packer_${PACKER_VERSION}_linux_amd64.zip" -d /usr/local/bin \
 && /bin/rm "/packer_${PACKER_VERSION}_linux_amd64.zip"

COPY packer.py /packer.py

ENTRYPOINT ["/usr/local/bin/python", "/packer.py"]

LABEL org.opencontainers.image.authors="William Jackson <william@subtlecoolness.com>" \
      org.opencontainers.image.version="${PACKER_VERSION}"
