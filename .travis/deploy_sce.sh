#!/bin/bash

# SCE is published to snowplow-maven which doesn't work with release-manager
# that's why there is a specific script

tag_version=$1

mkdir ~/.bintray/
FILE=$HOME/.bintray/.credentials
cat <<EOF >$FILE
realm = Bintray API Realm
host = api.bintray.com
user = $BINTRAY_SNOWPLOW_MAVEN_USER
password = $BINTRAY_SNOWPLOW_MAVEN_API_KEY
EOF

cd "${TRAVIS_BUILD_DIR}/3-enrich/scala-common-enrich"

project_version=$(sbt version -Dsbt.log.noformat=true | awk 'END{print}' | sed -r 's/\[info\]\s(.*)/\1/' | xargs echo -n)
if [ "${project_version}" == "${tag_version}" ]; then
    sbt +publish
    sbt +bintraySyncMavenCentral
else
    echo "Tag version '${tag_version}' doesn't match version in scala project ('${project_version}'). Aborting!"
    exit 1
fi
