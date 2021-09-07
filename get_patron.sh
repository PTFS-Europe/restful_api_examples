#!/bin/bash -e
#
# jake deery 2021
# koha restapi debug scripts - get_patron.sh
#set -x # uncomment to debug
shopt -s nocasematch # don't match casing, its not necessary
SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)" # get current script dir portibly
CONFIG_FILE=${SCRIPT_DIR}/config/config.json # config location
ARG1=${1}
ARG2=${2} # load arguments into vars



#
#
# functions
function getConfig() { # fetch config values from file
	# check file exists
	if [[ ! -f ${CONFIG_FILE} ]]; then
		echo '[E]	Config file does not exist at '${CONFIG_FILE}' . . . '
		exit 1
	fi

	# vars
	local locConfigJson=$(cat ${CONFIG_FILE})

	# get each item into the array
	CONFIG_ARR+=( $(echo ${locConfigJson} | jq --raw-output '."staff-client-url"') )
	CONFIG_ARR+=( $(echo ${locConfigJson} | jq --raw-output '."client-id"') )
	CONFIG_ARR+=( $(echo ${locConfigJson} | jq --raw-output '."client-secret"') )

	# all is ok
	return 0
}

function getToken() { # fetch token from api endpoint
	# vars
	local locRequestUrl=${CONFIG_ARR[0]}/api/v1/oauth/token
	local locClientId=${CONFIG_ARR[1]}
	local locClientSecret=${CONFIG_ARR[2]}

	# fetch
	local locTokenJson=$(curl -s -X POST -F grant_type=client_credentials -F client_id=${locClientId} -F client_secret=${locClientSecret} ${locRequestUrl})

	# parse & catch
	tokenString=$(echo ${locTokenJson} | jq --raw-output '.access_token')
	if [[ ${tokenString} == 'null' ]]; then
		echo '[E]	No access_token was provided! Check client-id and client-secret in config.json . . . '
		exit 1
	fi

	# all is ok
	return 0
}

function getPatron() {
	# vars
	local locRequestUrl=${CONFIG_ARR[0]}/api/v1/patrons
	local locMatchpointName=${ARG1}
	local locMatchpointValue=${ARG2}

	#  grab it
	fetchString=$(curl -s -H 'Authorization: Bearer '${tokenString} -H 'x-koha-query: {"'${locMatchpointName}'":"'${locMatchpointValue}'"}' ${locRequestUrl})

	# print it
	echo ${fetchString}

	# all is ok
	return 0
}



#
#
# process
if [[ $# != 2 ]]; then
	echo '[E]	Usage: '${0}' matchpoint-name matchpoint-value'
	echo '[E]	Valid matchpoint-name: patron_id, userid, cardnumber'
	exit 1
else
    echo '[I]   Setting up, please allow upto a minute . . . '
	getConfig # grab our config
	getToken # grab a token
	echo '[W]	Using '${CONFIG_ARR[0]}' as our API host, is this correct?'
	echo '[I]	Our access token is '${tokenString}' . . . '
	echo ''
	echo '[I]	Sending request . . . '
	getPatron

fi
