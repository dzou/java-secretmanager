#!/bin/bash

# Fail on any error.
set -e

# Display commands being run.
# WARNING: please only enable 'set -x' if necessary for debugging, and be very
#  careful if you handle credentials (e.g. from Keystore) with 'set -x':
#  statements like "export VAR=$(cat /tmp/keystore/credentials)" will result in
#  the credentials being printed in build logs.
#  Additionally, recursive invocation with credentials as command-line
#  parameters, will print the full command, with credentials, in the build logs.
set -x

# Code under repo is checked out to ${KOKORO_ARTIFACTS_DIR}/github.
# The final directory name in this path is determined by the scm name specified
# in the job configuration.
cd "${KOKORO_ARTIFACTS_DIR}/github/java-secretmanager"

# include common functions
source .kokoro/common.sh

# Print out Maven & Java version
mvn -version
echo ${JOB_TYPE}

# Install GraalVM
graalvmDir=${KOKORO_ARTIFACTS_DIR}/graalvm
mkdir ${graalvmDir}

retry_with_backoff 3 10 \
  curl --fail --show-error --silent --location \
  https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.2.0/graalvm-ce-java11-linux-amd64-21.2.0.tar.gz \
  | tar xz --directory ${graalvmDir} --strip-components=1

# Set GraalVM as the Java installation
export JAVA_HOME=${graalvmDir}
export PATH="$JAVA_HOME/bin:$PATH"

# Install Native Image
gu install native-image

# Test Java
java -version



