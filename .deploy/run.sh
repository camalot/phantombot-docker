#!/usr/bin/env bash 
set -e;

base_dir=$(dirname "$0");
# shellcheck source=/dev/null
source "${base_dir}/shared.sh";

get_opts() {
	while getopts ":v:n:o:f" opt; do
		case $opt in
			v) export opt_version="$OPTARG";
			;;
			n) export opt_name="$OPTARG";
			;;
			o) export opt_org="$OPTARG";
			;;
			f) export opt_force=1;
			;;
			\?) __error "Invalid option '-${OPTARG}'";
			;;
	  esac;
	done;

	return 0;
};

get_opts "$@";

LISTEN_PORT="25000";
PORT_MAP="49120:${LISTEN_PORT}";

FORCE_DEPLOY=${opt_force:-0};
BUILD_PROJECT="${opt_project_name:-"${CI_PROJECT_NAME}"}";
BUILD_VERSION="${opt_version:-"${CI_BUILD_VERSION:-"1.0.0-snapshot"}"}";
BUILD_ORG="${opt_org:-"${CI_DOCKER_ORGANIZATION}"}";
PULL_REPOSITORY="${DOCKER_REGISTRY}";

[[ -z "${PULL_REPOSITORY// }" ]] && __error "Environment Variable 'DOCKER_REGISTRY' missing or is empty";
[[ -z "${BUILD_PROJECT// }" ]] && __error "Environment Variable 'CI_PROJECT_NAME' missing or is empty";
[[ -z "${BUILD_VERSION// }" ]] && __error "Environment variable 'CI_BUILD_VERSION' missing or is empty";
[[ -z "${BUILD_ORG// }" ]] && __error "Environment variable 'CI_DOCKER_ORGANIZATION' missing or is empty";

[[ -z "${HEROKU_AUTH// }" ]] && __error "Environment variable 'HEROKU_AUTH' missing or is empty";
[[ -z "${HEROKU_EMAIL// }" ]] && __error "Environment variable 'HEROKU_EMAIL' missing or is empty";
[[ -z "${HEROKU_APP// }" ]] && __error "Environment variable 'HEROKU_APP' missing or is empty";

DOCKER_IMAGE="${BUILD_ORG}/${BUILD_PROJECT}:${BUILD_VERSION}";

echo "${DOCKER_REGISTRY}/${DOCKER_IMAGE}";

docker login --username "${ARTIFACTORY_USERNAME}" "${PULL_REPOSITORY}" --password-stdin <<< "${ARTIFACTORY_PASSWORD}";

docker pull "${DOCKER_REGISTRY}/${DOCKER_IMAGE}";

# # TODO: this should check if these exist before writing...
# echo -e "machine api.heroku.com\n\tlogin ${HEROKU_EMAIL}\n\tpassword ${HEROKU_AUTH}\n\n" >> ~/.netrc;
# echo -e "machine git.heroku.com\n\tlogin ${HEROKU_EMAIL}\n\tpassword ${HEROKU_AUTH}\n\n" >> ~/.netrc;
# --rm -v ~/.netrc:/root/.netrc:ro

docker run -e HEROKU_API_KEY="${HEROKU_AUTH}" wingrunr21/alpine-heroku-cli container:push web --verbose --app "${HEROKU_APP}";
docker run -e HEROKU_API_KEY="${HEROKU_AUTH}" wingrunr21/alpine-heroku-cli container:release web --verbose --app "${HEROKU_APP}";

# docker run -d \
# 	--user 0 \
# 	--restart unless-stopped \
# 	--name "${BUILD_PROJECT}" \
# 	--net=host \
# 	--device /dev/snd \
# 	-e PUID=1000 -e PGID=1000 \
# 	-e GNTP_PASSWORD="${GNTP_PASSWORD}" \
# 	-e PB_USERNAME="${PB_USERNAME}" \
# 	-e PB_OAUTH="${PB_OAUTH}" \
# 	-e PB_CHANNEL="${PB_CHANNEL}" \
# 	-e PB_OWNER="${PB_OWNER}" \
# 	-e PB_WEBPASSWORD="${PB_WEBPASSWORD}" \
# 	-e PB_WEBUSER="${PB_WEBUSER}" \
# 	-e PB_WEBAUTH="${PB_WEBAUTH}" \
# 	-e PB_WEBAUTHRO="${PB_WEBAUTHRO}" \
# 	-e PB_YTAUTH="${PB_YTAUTH}" \
# 	-e PB_YTAURHRO="${PB_YTAURHRO}" \
# 	-e PB_APIOAUTH="${PB_APIOAUTH}" \
# 	-e PB_DISCORDCLIENTID="${PB_DISCORDCLIENTID}" \
# 	-e PB_DISCORDTOKEN="${PB_DISCORDTOKEN}" \
# 	-e PB_TWITTERACCESSTOKEN="${PB_TWITTERACCESSTOKEN}" \
# 	-e PB_TWITTERCONSUMERKEY="${PB_TWITTERCONSUMERKEY}" \
# 	-e PB_TWITTERCONSUMERSECRET="${PB_TWITTERCONSUMERSECRET}" \
# 	-e PB_TWITTERSECRETTOKEN="${PB_TWITTERSECRETTOKEN}" \
# 	-e PB_DATARENDERSERVICE_TOKEN="${PB_DATARENDERSERVICE_TOKEN}" \
# 	-v /mnt/data/${BUILD_PROJECT}/config:/app/config \
# 	-v /mnt/data/${BUILD_PROJECT}/logs:/app/logs \
# 	-v /mnt/data/${BUILD_PROJECT}/dbbackup:/app/dbbackup \
# 	-v /mnt/data/${BUILD_PROJECT}/labels:/app/labels \
# 	-e TZ=America_Chicago \
# 	-t "${PULL_REPOSITORY}/${DOCKER_IMAGE}";
# 	# -p "${PORT_MAP}" \
# 	# -P \

# https://github.com/linuxserver/docker-plex
