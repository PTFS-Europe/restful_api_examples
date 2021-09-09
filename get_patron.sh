#!/bin/bash -e
#
# jake deery 2021
# koha restapi debug scripts - get_patron.sh
#set -x # uncomment to debug
shopt -s nocasematch # don't match casing, its not necessary
SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)" # get current script dir portibly
CONFIG_FILE=${SCRIPT_DIR}/config/config.json # config location
TOKEN_FILE=${SCRIPT_DIR}/token_file
TOKEN_STRING='' # stores fetched token
REQUIRED_ARGS_COUNTER=0 # tracking for successful operation
MATCHPOINT=''
VALUE='' # these are set with arguments



#
#
# functions
function getConfig() { # fetch config values from file
# vars
	local locConfigJson=$(cat ${CONFIG_FILE})

	# check its a json file -- dumb check
	if [[ ${CONFIG_FILE} != *.json ]]; then
		echo '[E]	That is not a json file!'
		exit 1
	fi
	# check file exists
	if [[ ! -f ${CONFIG_FILE} ]]; then
		echo '[E]	Config file does not exist at '${CONFIG_FILE}' . . . '
		exit 1
	fi

	# get each item into the array
	CONFIG_ARR+=( $(echo ${locConfigJson} | jq --raw-output '."staff-client-url"') )
	if [[ ${CONFIG_ARR[0]} == null ]]; then # check our work
		echo '[E]	Config key staff-client-url is missing, even though its required!'
		exit 1
	fi

	CONFIG_ARR+=( $(echo ${locConfigJson} | jq --raw-output '."client-id"') )
	if [[ ${CONFIG_ARR[0]} == null ]]; then # check our work
		echo '[E]	Config key staff-client-url is missing, even though its required!'
		exit 1
	fi

	CONFIG_ARR+=( $(echo ${locConfigJson} | jq --raw-output '."client-secret"') )
	if [[ ${CONFIG_ARR[0]} == null ]]; then # check our work
		echo '[E]	Config key staff-client-url is missing, even though its required!'
		exit 1
	fi

	# all is ok
	return 0
}

function getToken() { # fetch token from api endpoint
	# vars
	local locRequestUrl=${CONFIG_ARR[0]}/api/v1/oauth/token
	local locClientId=${CONFIG_ARR[1]}
	local locClientSecret=${CONFIG_ARR[2]}
	local locTokenFile=${TOKEN_FILE}

	# test to see if the file exists or its stale
	if ! test -f ${locTokenFile} || test "`find ${locTokenFile} -mmin +45`"; then
		# fetch token from api
		local locTokenJson=$(curl -s -X POST -F grant_type=client_credentials -F client_id=${locClientId} -F client_secret=${locClientSecret} ${locRequestUrl})

		# parse & catch duff responses
		TOKEN_STRING=$(echo ${locTokenJson} | jq --raw-output '.access_token')
		if [[ ${TOKEN_STRING} == 'null' ]] || [[ -z ${TOKEN_STRING} ]]; then
			echo '[E]	No access_token was provided! Check client-id and client-secret in config.json . . . '
			exit 1
		else
			# not-duff response goes in the token_file for reuse later on
			echo ${TOKEN_STRING} > ${locTokenFile}
			chmod 0600 ${locTokenFile}
		fi
	else
		# the existing token isn't stale -- reuse it
		TOKEN_STRING=$(cat ${locTokenFile})
	fi

	# token should always be 88 chars
	if [[ ${#TOKEN_STRING} != 88 ]]; then
		echo '[E]	Token is malformed or invalid! Please rerun this script'
		rm ${locTokenFile}
		exit 1
	fi

	# all is ok
	return 0
}

function getPatron() {
	# vars
	local locTokenString=${TOKEN_STRING}
	local locRequestUrl=${CONFIG_ARR[0]}/api/v1/patrons
	local locMatchpointName=${MATCHPOINT}
	local locMatchpointValue=${VALUE}

	# get it
	echo $(curl -s -H 'Authorization: Bearer '${locTokenString} -H 'x-koha-query: {"'${locMatchpointName}'":"'${locMatchpointValue}'"}' ${locRequestUrl})

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

	# --matchpoint
	if [[ ${!i} == '--matchpoint' ]]; then
		if [[ -f ${!j} ]]; then
			echo '[E]	'${!j}' is a filename! Enter a string please'
			exit 1
		elif [[ ${!j:0:2} == '--' ]]; then
			echo '[E]	Please provide a value in string form'
			exit 1
		else
			MATCHPOINT=${!j}
			REQUIRED_ARGS_COUNTER=$((REQUIRED_ARGS_COUNTER+1)) # up the required
		fi
	fi

		# --value
	if [[ ${!i} == '--value' ]]; then
		if [[ -f ${!j} ]]; then
			echo '[E]	'${!j}' is a filename! Enter a string please'
			exit 1
		elif [[ ${!j:0:2} == '--' ]]; then
			echo '[E]	Please provide a value in string or integer form'
			exit 1
		else
			VALUE=${!j}
			REQUIRED_ARGS_COUNTER=$((REQUIRED_ARGS_COUNTER+1)) # up the required
		fi
	fi
done

#
# begin main logic
if [[ ${REQUIRED_ARGS_COUNTER} != 2 ]]; then # if the wrong number of args are passed
	echo '[E]	Usage: '${0}' --matchpoint <string> --value <string|int>'
	echo
	echo '[E]	Required flags:'
	echo '[E]		--matchpoint <string>	What to lookup against. Possible values are: cardnumber, userid, patron_id'
	echo '[E]		--value <string|int>	What to lookup using. Max. length 8 chars.'
	echo
	echo '[E]	Optional flags:'
	echo '[E]		--config <file>		The json file used to configure this script. Will default to <script-dir>/config/config.json if unspecified.'
	exit 1
else
	getConfig # grab our config
	getToken # grab a token
	getPatron # do the get

fi
