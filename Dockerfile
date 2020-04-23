# Container image that runs your code
FROM mayrop/python

# Set working environment
COPY . /usr/app
WORKDIR /usr/app

COPY "entrypoint.sh" "/entrypoint.sh"
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# docker build --no-cache -t mayrop/myparser .
# docker run -it -v $(pwd):/usr/app mayrop/myparser bash
# docker-compose run --rm mx-covid bash
