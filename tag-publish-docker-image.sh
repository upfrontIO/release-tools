#!/bin/bash

set -e

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - HELPERS
isRequestingHelp () { [[ $1 == --help ]]; }
hasNotEnoughArguments () { [[ "$#" -lt "7" ]]; }
displayHelp () {
  echo "This script tags and pushes a local Docker image to the Docker Hub."
  echo "Argument 1 (MUST)     : <DOCKER_SLUG> f.e. livingdocs/service-server"
  echo "Argument 2 (MUST)     : <DOCKER_LOGIN_USERNAME>"
  echo "Argument 3 (MUST)     : <DOCKER_LOGIN_PASSWORD>"
  echo "Argument 4 (MUST)     : <DOCKER_LOCAL_IMAGE>"
  echo "Argument 5 (MUST)     : <GIT_BRANCH>"
  echo "Argument 6 (MUST)     : <PULL_REQUEST_NUMBER> is a number or false"
  echo "Argument 7 (MUST)     : <COMMIT_HASH>"
  echo "Argument 8            : <TEST_MODE>"
}

isReleaseBranch () { [[ $GIT_BRANCH =~ ^release- ]]; }
isMasterBranch () { [[ $GIT_BRANCH == master ]]; }
isPullRequest () { [[ $PULL_REQUEST_NUMBER != false ]]; }
isNotPullRequest () { ! isPullRequest; }

isFeatureBranch () { isMasterBranch && isPullRequest; }
isMergingOnMaster () { isMasterBranch && isNotPullRequest; }
isMergingOnRelease () { isReleaseBranch && isNotPullRequest; }

prepareTags () {
  HASH_TAG="hash-$COMMIT_HASH"
  FEATURE_TAG="tag-feature-$COMMIT_HASH"
  RELEASE_BRANCH_TAG="hash-$GIT_BRANCH"
}

hasDockerTags () { [ "x$DOCKER_TAGS" != "x" ]; }

dockerLogin () {
  execute \
    "docker login -u=\"$DOCKER_LOGIN_USERNAME\" -p=\"$DOCKER_LOGIN_PASSWORD\""
}

dockerTagAndPush () {
  DOCKER_TAG=$1
  DOCKER_REMOTE_IMAGE=$DOCKER_SLUG:$DOCKER_TAG
  execute "docker tag $DOCKER_LOCAL_IMAGE $DOCKER_REMOTE_IMAGE"
  execute "docker push $DOCKER_REMOTE_IMAGE"
}

execute () {
  if [[ $TEST_MODE == true ]]; then
    echo $1
  else
    eval $1
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ARGUMENTS
DOCKER_SLUG=$1
DOCKER_LOGIN_USERNAME=$2
DOCKER_LOGIN_PASSWORD=$3
DOCKER_LOCAL_IMAGE=$4
GIT_BRANCH=$5
PULL_REQUEST_NUMBER=$6
COMMIT_HASH=$7
TEST_MODE=$8

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - EXECUTION
SCRIPT_ARGS=$@
if isRequestingHelp $SCRIPT_ARGS || hasNotEnoughArguments $SCRIPT_ARGS; then
  displayHelp
  exit 1
fi

prepareTags

if isFeatureBranch; then
  DOCKER_TAGS="$HASH_TAG $FEATURE_TAG"
fi

if isMergingOnMaster; then
  DOCKER_TAGS="$HASH_TAG"
fi

if isMergingOnRelease; then
  DOCKER_TAGS="$HASH_TAG $RELEASE_BRANCH_TAG"
fi

if hasDockerTags; then
  dockerLogin
  for TAG in $DOCKER_TAGS; do dockerTagAndPush $TAG; done
fi
