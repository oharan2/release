#!/bin/bash

#TODO check execution
sleep 4h

set -o nounset
set -o errexit
set -o pipefail

shopt -s nullglob

# Set the ocp env variables and execute oc login
CONSOLE_URL=$(cat $SHARED_DIR/console.url)
OCP_API_URL="https://api.${CONSOLE_URL#"https://console-openshift-console.apps."}:6443"
OCP_CRED_USR="kubeadmin"
OCP_CRED_PSW="$(cat ${SHARED_DIR}/kubeadmin-password)"
oc login ${OCP_API_URL} --username=${OCP_CRED_USR} --password=${OCP_CRED_PSW} --insecure-skip-tls-verify=true

# source sdkman
set +o nounset #disable strict mode
source "/root/.sdkman/bin/sdkman-init.sh"
set -o nounset #enable back strict mode

# export maven env variable
# export _JAVA_OPTIONS=-Duser.home=$HOME

# Collect test reports into $ARTIFACT_DIR
echo "Copying results and xmls to ${ARTIFACT_DIR}"
PROJECTS=config,lifecycle-application,http/http-minimum,http/http-minimum-reactive,sql-db/sql-app,monitoring/microprofile-opentracing
for PROJECT in ${PROJECTS//","/" "}; do
  for FILE in ./$PROJECT/target/failsafe-reports/TEST-*.xml; do
    FILENAME=$(basename $FILE)
    echo $FILENAME
    cp $FILE ${ARTIFACT_DIR}/junit_${FILENAME}
  done
done
