#!/usr/bin/env bash
set -e;
unset DISPLAY;

cd $(dirname $(readlink -f $0));

if type -p java 1>/dev/null 2>/dev/null; then
    _java=java;
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
    _java="$JAVA_HOME/bin/java";
else
    (&>2 echo "You don't have Java installed! Download it from https://www.java.com/en/download/");
		exit 2;
fi

sed -i "s/\%PB_USERNAME\%/${PB_USERNAME}/g; 
	s/\%PB_OAUTH\%/${PB_OAUTH}/g;	
	s/\%PB_CHANNEL\%/${PB_CHANNEL}/g;	
	s/\%PB_OWNER\%/${PB_OWNER}/g; 
	s/\%PB_WEBUSER\%/${PB_WEBUSER}/g; 
	s/\%PB_WEBPASSWORD\%/${PB_WEBPASSWORD}/g; 
	s/\%PB_WEBAUTH\%/${PB_WEBAUTH}/g;
	s/\%PB_WEBAUTHRO\%/${PB_WEBAUTHRO}/g;
	s/\%PB_YTAUTH\%/${PB_YTAUTH}/g;
	s/\%PB_YTAURHRO\%/${PB_YTAURHRO}/g;
	s/\%PB_APIOAUTH\%/${PB_APIOAUTH}/g;
	s/\%PB_DISCORDCLIENTID\%/${PB_DISCORDCLIENTID}/g;
	s/\%PB_DISCORDTOKEN\%/${PB_DISCORDTOKEN}/g;
	s/\%PB_TWITTERCONSUMERSECRET\%/${PB_TWITTERCONSUMERSECRET}/g;
	s/\%PB_TWITTERCONSUMERKEY\%/${PB_TWITTERCONSUMERKEY}/g;
	s/\%PB_TWITTERACCESSTOKEN\%/${PB_TWITTERACCESSTOKEN}/g;
	s/\%PB_TWITTERSECRETTOKEN\%/${PB_TWITTERSECRETTOKEN}/g;
	s/\%PB_DATARENDERSERVICE_TOKEN\%/${PB_DATARENDERSERVICE_TOKEN}/g;
" \
"/app/init/botlogin.txt";

[ -f "/app/config/botlogin.txt" ] && rm /app/config/botlogin.txt;
cat /app/init/botlogin.txt;
cp /app/init/botlogin.txt /app/config/botlogin.txt;
# rm /app/init/botlogin.txt;

java -Dfile.encoding=UTF-8 -jar /app/PhantomBot.jar;
