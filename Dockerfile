FROM chambana/uwsgi-php:latest

MAINTAINER Josh King <jking@chambana.net>

RUN apt-get -qq update && \
	apt-get install -y --no-install-recommends ca-certificates unzip wget php-xml && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

ENV PODCASTGEN_VERSION 3.1
ENV PHP_SIZE 300

EXPOSE 80

VOLUME ["/var/www"]

ADD podcastgen.conf /etc/uwsgi/apps-available/podcastgen.conf

## Add startup script.
ADD bin/run.sh /app/bin/run.sh
RUN chmod 0755 /app/bin/run.sh

ENTRYPOINT ["/app/bin/run.sh"]
CMD ["uwsgi", "--uid", "www-data", "--gid", "www-data", "--ini", "/etc/uwsgi/apps-available/podcastgen.conf"]
