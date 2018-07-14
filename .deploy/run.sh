#!/usr/bin/env bash 
set -e;
exit 9;

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

[[ -z "${GNTP_PASSWORD// }" ]] && __error "Environment variable 'GNTP_PASSWORD' missing or is empty";

DOCKER_IMAGE="${BUILD_ORG}/${BUILD_PROJECT}:${BUILD_VERSION}";

echo "${DOCKER_REGISTRY}/${DOCKER_IMAGE}";

docker login --username "${ARTIFACTORY_USERNAME}" "${PULL_REPOSITORY}" --password-stdin <<< "${ARTIFACTORY_PASSWORD}";

docker pull "${DOCKER_REGISTRY}/${DOCKER_IMAGE}";


# CHECK IF IT IS CREATED, IF IT IS, THEN DEPLOY
DC_INFO=$(docker ps --all --format "table {{.Status}}\t{{.Names}}" | awk '/phantombot$/ {print $0}');
__info "DC_INFO: $DC_INFO";
DC_STATUS=$(echo "${DC_INFO}" | awk '{print $1}');
__info "DC_STATUS: $DC_STATUS";
__info "FORCE_DEPLOY: $FORCE_DEPLOY";
if [[ -z "${DC_STATUS}" ]] && [ $FORCE_DEPLOY -eq 0 ]; then
	__warning "Container '$DOCKER_IMAGE' not deployed. Skipping deployment";
	exit 0;
fi

if [[ ! $DC_STATUS =~ ^Exited$ ]]; then
  __info "stopping container";
	docker stop "${BUILD_PROJECT}" || __warning "Unable to stop '${BUILD_PROJECT}'";
fi
if [[ ! -z "${DC_INFO}" ]]; then
  __info "removing image";
	docker rm "${BUILD_PROJECT}" || __warning "Unable to remove '${BUILD_PROJECT}'";
fi


docker run -d \
	--user 0 \
	--restart unless-stopped \
	--name "${BUILD_PROJECT}" \
	--net=host \
	--device /dev/snd \
	-e PUID=1000 -e PGID=1000 \
	-e GNTP_PASSWORD="${GNTP_PASSWORD}" \
	-e PB_USERNAME="${PB_USERNAME}" \
	-e PB_OAUTH="${PB_OAUTH}" \
	-e PB_CHANNEL="${PB_CHANNEL}" \
	-e PB_OWNER="${PB_OWNER}" \
	-e PB_WEBPASSWORD="${PB_WEBPASSWORD}" \
	-e PB_WEBUSER="${PB_WEBUSER}" \
	-e PB_WEBAUTH="${PB_WEBAUTH}" \
	-e PB_WEBAUTHRO="${PB_WEBAUTHRO}" \
	-e PB_YTAUTH="${PB_YTAUTH}" \
	-e PB_YTAURHRO="${PB_YTAURHRO}" \
	-e PB_APIOAUTH="${PB_APIOAUTH}" \
	-e PB_DISCORDCLIENTID="${PB_DISCORDCLIENTID}" \
	-e PB_DISCORDTOKEN="${PB_DISCORDTOKEN}" \
	-e PB_TWITTERACCESSTOKEN="${PB_TWITTERACCESSTOKEN}" \
	-e PB_TWITTERCONSUMERKEY="${PB_TWITTERCONSUMERKEY}" \
	-e PB_TWITTERCONSUMERSECRET="${PB_TWITTERCONSUMERSECRET}" \
	-e PB_TWITTERSECRETTOKEN="${PB_TWITTERSECRETTOKEN}" \
	-e PB_DATARENDERSERVICE_TOKEN="${PB_DATARENDERSERVICE_TOKEN}" \
	-v /mnt/data/${BUILD_PROJECT}/config:/app/config \
	-v /mnt/data/${BUILD_PROJECT}/logs:/app/logs \
	-v /mnt/data/${BUILD_PROJECT}/dbbackup:/app/dbbackup \
	-v /mnt/data/${BUILD_PROJECT}/labels:/app/labels \
	-e TZ=America_Chicago \
	-t "${PULL_REPOSITORY}/${DOCKER_IMAGE}";
	# -p "${PORT_MAP}" \
	# -P \

# https://github.com/linuxserver/docker-plex
