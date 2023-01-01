#!/bin/bash
set -x;

SOURCE=$1 
TARGET=$2 
COMMIT=$(git log -1 --pretty=%B | tr -d '\n')
FROM=$(basename $PWD)
# check updates
if [ ! -z $(git diff-tree --no-commit-id --name-only -r $(git log -1 --pretty=%H) | grep $SOURCE) ] 
then 
 curl -i -X PUT -H 'Authorization: token '${GITHUB_DOCS_BOT_TOKEN} -d "{\"path\": \"$TARGET\", \
   \"message\": \"from ${FROM}: ${COMMIT}\", \"content\":  \"$(openssl base64 -A -in $SOURCE)\", \"branch\": \"master\",\
    \"sha\": $(curl -X GET https://api.github.com/repos/webresto/docs/contents/$TARGET | jq .sha)}" \
    https://api.github.com/repos/webresto/docs/contents/$TARGET
else
 echo NO
fi
