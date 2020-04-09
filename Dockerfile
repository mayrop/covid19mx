# Container image that runs your code
FROM debian:9
# see: https://tracker.debian.org/pkg/pdf2htmlex

RUN apt-get update --fix-missing

RUN apt-get install -y ghostscript poppler-utils \
    pdf2htmlex python3.5 python3-pip locales && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*
  
# adding symlink
RUN ln -s /usr/bin/python3.5 /usr/bin/python

# Install Python dependencies
COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

# see https://github.com/docker-library/python/issues/13
ENV LANG C.UTF-8

# docker build --no-cache -t mayrop/myparser .
# docker run -it -v $(pwd):/usr/app mayrop/myparser bash