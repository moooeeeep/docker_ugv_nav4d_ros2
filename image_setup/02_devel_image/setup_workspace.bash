#!/bin/bash

# In this file you can add a script that intitializes your workspace

# stop on errors
set -e

BUILDCONF=https://github.com/moooeeeep/ugv_nav4d_buildconf.git
BRANCH=main

if [ ! $1 = "" ]; then
   echo "overriding git credential helper to $1"
   CREDENTIAL_HELPER_MODE=$1
fi

# for Continuous Deployment builds the mode needs to be overridden to be non-interactive
# if set outside this script, use that value, if unset use cache
CREDENTIAL_HELPER_MODE=${CREDENTIAL_HELPER_MODE:="cache"}

AUTOPROJ_WS_ROOT=/opt/workspace/src

if [ ! -f ${AUTOPROJ_WS_ROOT}/env.sh ]; then
    echo -e "\e[32m[INFO] First start: setting up the workspace.\e[0m"

    # set git config
    git config --global user.name "Image Builder"
    git config --global user.email "image@builder.me"
    git config --global credential.helper ${CREDENTIAL_HELPER_MODE}

    # setup ws using autoproj
    mkdir -p ${AUTOPROJ_WS_ROOT} && cd ${AUTOPROJ_WS_ROOT}
    wget https://raw.githubusercontent.com/rock-core/autoproj/master/bin/autoproj_bootstrap
    git clone $BUILDCONF /tmp/buildconf
    AUTOPROJ_BOOTSTRAP_IGNORE_NONEMPTY_DIR=1 ruby autoproj_bootstrap \
        git $BUILDCONF branch=main \
        --seed-config=/tmp/buildconf/seed-config.yaml \
        --no-color --no-progress --no-interactive
    rm -rf /tmp/buildconf

    (. env.sh && aup)

    echo -e "\e[32m[INFO] workspace successfully initialized.\e[0m"
else 
    echo -e "\e[31m[ERROR] workspace already initialized.\e[0m"
    exit 1
fi

