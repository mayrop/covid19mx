# Container image that runs your code
FROM python:3

RUN apt-get update

RUN apt-get install -y ghostscript poppler-utils unzip zip && \
  rm -rf /var/lib/apt/lists/*

# upgrade pip
RUN pip install --upgrade pip

# Set working environment
COPY . /usr/app
WORKDIR /usr/app

# install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY "entrypoint.sh" "/entrypoint.sh"
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# docker build --no-cache -t mayrop/myparser .
# docker run -it -v $(pwd):/usr/app mayrop/myparser bash
# docker-compose run --rm mx-covid bash
