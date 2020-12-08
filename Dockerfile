FROM python:3.9.1-alpine3.12

ARG PACKER_VERSION="1.6.5"

COPY requirements.txt /requirements.txt
RUN /usr/local/bin/pip install --no-cache-dir --requirement /requirements.txt

RUN /usr/bin/wget "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" \
 && /usr/bin/unzip "/packer_${PACKER_VERSION}_linux_amd64.zip" -d /usr/local/bin \
 && /bin/rm "/packer_${PACKER_VERSION}_linux_amd64.zip"

COPY packer.py /packer.py

ENTRYPOINT ["/usr/local/bin/python", "/packer.py"]

LABEL org.opencontainers.image.authors="William Jackson <william@subtlecoolness.com>" \
      org.opencontainers.image.version="${PACKER_VERSION}"
