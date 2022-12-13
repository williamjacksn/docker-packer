FROM hashicorp/packer:1.8.5
# The preceding line is only for Dependabot

FROM python:3.11.1-alpine3.16

ARG PACKER_VERSION="1.8.4"

RUN /usr/sbin/adduser -g python -D python

USER python
RUN /usr/local/bin/python -m venv /home/python/venv

COPY --chown=python:python requirements.txt /home/python/docker-packer/requirements.txt
RUN /home/python/venv/bin/pip install --no-cache-dir --requirement /home/python/docker-packer/requirements.txt

WORKDIR /home/python/docker-packer

RUN /usr/bin/wget "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" \
 && /usr/bin/unzip "/home/python/docker-packer/packer_${PACKER_VERSION}_linux_amd64.zip" -d /home/python/docker-packer \
 && /bin/rm "/home/python/docker-packer/packer_${PACKER_VERSION}_linux_amd64.zip"

COPY --chown=python:python packer.py /home/python/docker-packer/packer.py
ENTRYPOINT ["/home/python/venv/bin/python", "/home/python/docker-packer/packer.py"]

LABEL org.opencontainers.image.authors="William Jackson <william@subtlecoolness.com>" \
      org.opencontainers.image.source="https://github.com/williamjacksn/docker-packer" \
      org.opencontainers.image.version="${PACKER_VERSION}"
