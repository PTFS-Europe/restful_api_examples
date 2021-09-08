#!/bin/bash -e
#
# jake deery 2021
# koha restapi debug scripts - get_patron.sh
#set -x # uncomment to debug
shopt -s nocasematch # don't match casing, its not necessary
SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)" # get current script dir portibly
CONFIG_FILE=${SCRIPT_DIR}/config/config.json # config location
REQUIRED_ARGS_COUNTER=0 # tracking for successful operation
PAYLOAD=''



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

function addPatron() {
	# vars
	local locRequestUrl=${CONFIG_ARR[0]}/api/v1/patrons
	local locFilePath=${PAYLOAD}

	# check its a json file -- dumb check
	if [[ ${locFilePath} != *.json ]]; then
		echo '[E]	That is not a json file!'
		exit 1
	fi

	# grab it
	fetchString=$(curl -s -X POST -H 'Authorization: Bearer '${tokenString} -H '' -d @${locFilePath} ${locRequestUrl})

	# print it
	echo ${fetchString}

	# all is ok
	return 0
}



#
#
# process

#
# first, handle all arguments
for (( i=0; i<$#; i++)); do
	# vars
	j=$((i+1))

	# --config
	if [[ ${!i} == '--config' ]]; then
		if [[ ! -f ${!j} ]]; then
			echo '[E]	'${!j}' is not a valid file path!'
			exit 1
		else
			CONFIG_FILE=${!j}
		fi
	fi

	# --in
	if [[ ${!i} == '--in' ]]; then
		if [[ ! -f ${!j} ]]; then
			echo '[E]	'${!j}' is not a valid file path!'
			exit 1
		else
			PAYLOAD=${!j}
			REQUIRED_ARGS_COUNTER=$((REQUIRED_ARGS_COUNTER+1)) # up the required
		fi
	fi
done

#
# begin main logic
echo '[I]	add_patron RESTful script, Jake Deery @ PTFS-Europe, 2021'
if [[ ${REQUIRED_ARGS_COUNTER} != 1 ]]; then # if the wrong number of args are passed
	echo '[E]	Usage: '${0}' --in <file>'
	echo
	echo '[E]	Required flags:'
	echo '[E]		--in <file>		What to send. File must be json.'
	echo
	echo '[E]	Optional flags:'
	echo '[E]		--config <file>			The json file used to configure this script. Will default to <script-dir>/config/config.json if unspecified.'
	exit 1
else
	echo '[I]	Setting up, please allow upto a minute . . . '
	getConfig # grab our config
	getToken # grab a token
	echo '[W]	Using '${CONFIG_ARR[0]}' as our API host, is this correct?'
	echo '[I]	Our access token is '${tokenString}' . . . '
	echo '[I]	Sending request . . . '
	addPatron

fi