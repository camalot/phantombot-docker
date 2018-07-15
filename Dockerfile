FROM openjdk:8u162-jdk

# set version label
ARG PROJECT_NAME="phantombot"
ARG BUILD_VERSION="1.0.0-snapshot"
ARG PHANTOMBOT_VERSION="2.4.1"
ARG SECRETWORD_VERSION="1.0.26"
ENV PB_USERNAME=""
ENV PB_OAUTH=""
ENV PB_CHANNEL="" 
ENV PB_OWNER=""


ENV DEBIAN_FRONTEND=noninteractive

LABEL LABEL="${PROJECT_NAME}-v${BUILD_VERSION}" VERSION="${BUILD_VERSION}" MAINTAINER="camalot <camalot@gmail.com>"

WORKDIR /app

RUN \
	apt-get update && \
	apt-get install jq unzip wget rsync curl -y && \
	addgroup abc && \
	adduser abc --ingroup abc --system --home /app --shell /bin/bash  && \
	wget https://github.com/PhantomBot/PhantomBot/releases/download/v${PHANTOMBOT_VERSION}/PhantomBot-${PHANTOMBOT_VERSION}.zip && \
	unzip PhantomBot-${PHANTOMBOT_VERSION}.zip && \
	mv /app/PhantomBot-${PHANTOMBOT_VERSION}/* /app && \
	wget https://cloud.zelakto.tv/s/takfSbLXGtBtMKX/download -O beta-panel.zip && \
	unzip beta-panel.zip && \
	mv beta-panel /app/web/ && \
	rm PhantomBot-${PHANTOMBOT_VERSION}.zip && \
	rm beta-panel.zip && \
	rm -rf PhantomBot-${PHANTOMBOT_VERSION} && \
	mkdir -p "/app/dbbackup" && \
	mkdir -p "/app/init" && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean;

COPY root/entrypoint.sh /app/entrypoint.sh
COPY root/config/botlogin.txt /app/init/botlogin.txt
COPY root/config/ignorebots.txt /app/addons/ignorebots.txt
COPY root/resources/web/panel/js/ion.sound.js /app/web/panel/js/ion-sound/js/ion.sound.min.js
COPY root/addons/ /app/addons/
COPY root/scripts/ /app/scripts/

RUN chmod u+x /app/entrypoint.sh && \
	chown -R abc:abc /app && \
	curl -Ls "https://github.com/camalot/phantombot-secretword/releases/download/${SECRETWORD_VERSION}/phantombot-secretword-${SECRETWORD_VERSION}.zip" -o /tmp/secretword.zip && \
	unzip /tmp/secretword.zip -d /app/ && \
	rm /tmp/secretword.zip

VOLUME "/app/logs"
VOLUME "/app/config" 
VOLUME "/app/dbbackup"

EXPOSE 25000 25001 25002 25003 25004

CMD [ "/app/entrypoint.sh" ]
