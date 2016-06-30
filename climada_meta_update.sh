#!/bin/sh

# Set defaults
CLIMADA_BASE="https://github.com/davidnbresch"

# Semi hardcoded
CLIMADA_META_CONFIG="./climada_meta.conf"
CLIMADA_REPOSITORIES="climada
		      climada_module_kml_toolbox 
		      climada_module_tropical_cyclone
		      climada_module_meteorites 
		      climada_module_barisal_demo 
		      climada_module_flood 
		      climada_module_earthquake_volcano 
		      climada_module_drought_fire
		      climada_module_storm_europe
		      climada_module_salvador_demo
		      climada_module_CAM"

########################
## Code below here

initialize_repository() {

	REPOSITORY=${1}

	echo
	echo " ------ initializing \033[35m${REPOSITORY}\033[0m ------- "
	echo

	STATUS=0
	OLD_PWD=${PWD}

	if [ ${FORK} = true ]; then
		git clone ${CLIMADA_BASE}/${REPOSITORY} ${REPOSITORY} \
							2>&1 >/dev/null && \
		cd ${REPOSITORY} && \
		git remote add upstream ${CLIMADA_DEFAULT_BASE}/${REPOSITORY} \
							2>&1 >/dev/null && \
		git fetch upstream 2>&1 >/dev/null
		STATUS=$?
	else
		git clone ${CLIMADA_BASE}/${REPOSITORY} ${REPOSITORY}
		STATUS=$?
	fi

	cd ${OLD_PWD}

	echo

	if [ ${STATUS} -eq 0 ]; then 
		echo " ------           \033[32mSUCCESS\033[0m      ------"
	else
		echo " ------           \033[31mFAILURE\033[0m      ------"
	fi

	echo

}

update_repository() {

	REPOSITORY=${1}

	echo
	echo " ------ updating \033[35m${REPOSITORY}\033[0m ------- "
	echo

	STATUS=0
	OLD_PWD=${PWD}

	if [ ${FORK} = true ]; then
		cd ${REPOSITORY} && \
		git fetch upstream 2>&1 >/dev/null && \
		git checkout master 2>&1 >/dev/null && \
		git rebase upstream/master
		STATUS=$?
	else
		cd ${REPOSITORY} && \
		git pull
		STATUS=$?
	fi

	cd ${OLD_PWD}

	echo

	if [ ${STATUS} -eq 0 ]; then 
		echo " ------           \033[32mSUCCESS\033[0m      ------"
	else
		echo " ------           \033[31mFAILURE\033[0m      ------"
	fi

	echo

}

# We'll later detect if the defaults have been overridden
CLIMADA_DEFAULT_BASE="${CLIMADA_BASE}"

# Load configuration
if [ -r ${CLIMADA_META_CONFIG} ]; then
	. ${CLIMADA_META_CONFIG}
fi

# Determine whether we deal with a fork or not
FORK=false
if [ "${CLIMADA_BASE}" != "${CLIMADA_DEFAULT_BASE}" ]; then
	FORK=true
fi

for climada_repository in $CLIMADA_REPOSITORIES; do

	if [ ! -d $climada_repository ]; then
		initialize_repository $climada_repository
	else
		update_repository $climada_repository
	fi

done
