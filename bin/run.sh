#!/bin/bash - 

. /app/lib/common.sh

CHECK_BIN "wget"
CHECK_BIN "unzip"
CHECK_BIN "uwsgi"
CHECK_VAR PODCASTGEN_VERSION
CHECK_VAR PHP_SIZE

DIR=/var/www/PodcastGenerator

if [[ ! -d $DIR ]]; then
	MSG "Downloading podcastgen..."
	wget -O /tmp/podcastgen.zip \
		https://github.com/albertobeta/PodcastGenerator/archive/v${PODCASTGEN_VERSION}.zip
	[[ $? -eq 0 ]] || { ERR "Failed to download podcastgen, aborting."; exit 1; }
	unzip -o -d /tmp /tmp/podcastgen.zip
	[[ $? -eq 0 ]] || { ERR "Failed to unzip podcastgen, perhaps file is invalid?"; exit 1; }
	mv /tmp/PodcastGenerator-${PODCASTGEN_VERSION} ${DIR}
	[[ -d $DIR ]] || { ERR "Directory $DIR does not exist, aborting."; exit 1; }
	chown -R www-data:www-data /var/www/
	sed -i -e "s#^php-docroot\ *=\ {{\ PODCASTGEN_DIR\ }}#php-docroot\ =\ ${DIR}#" \
		-e "s#^static-safe\ *=\ {{\ PODCASTGEN_DIR\ }}#static-safe\ =\ ${DIR}#" \
		 -e "s#^php-set\ =\ post_max_size=100M#php-set\ =\ post_max_size=${PHP_SIZE}#" \
		  -e "s#^php-set\ =\ upload_max_filesize=100M#php-set\ =\ upload_max_filesize=${PHP_SIZE}#" \		  
		/etc/uwsgi/apps-available/podcastgen.conf
fi

MSG "Serving site..."

exec "$@"
