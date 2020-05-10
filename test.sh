#!/usr/bin/env bash

# Start serving the mock factorio site in the background. Check that the port
# is available for use. Start the server, catch the resulting PID, then register
# the cleanup function to kill the background process upon exit.

# Port availability check
PORTNUM=8000
netstat -tulpan 2>/dev/null | grep $PORTNUM
if [ $? -eq 0 ]; then
  echo "Port already in use. Aborting."
  exit 1
fi

# Background service start
pushd vendor/mock.factorio.com || exit 1
python2 -m SimpleHTTPServer $PORTNUM &
MOCKHOSTPID=$!
echo $MOCKHOSTPID
popd || exit 1

# Exit cleanup registration
function cleanup {
  echo "Killing SimpleHTTPServer with PID $MOCKHOSTPID"
  kill -9 "${MOCKHOSTPID}"
}
trap cleanup EXIT

# The docker containers are started via docker-compose. Each dockerfile copies
# the test folder to the container and then runs the test playbook locally
# within the container

docker-compose -f tests/docker-compose.yml up --build
exit 0
