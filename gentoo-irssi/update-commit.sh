#!/bin/bash
set -e

container="gentoo-irssi"
image="haven/gentoo-stage3"

if [ ! "$( docker images | grep $image )" ]; then
  echo $image does not seem to exist.
  exit
fi

docker rm -f "$container" > /dev/null 2>&1 || true
( set -x; docker run -t  -v /usr/portage:/usr/portage:ro -v /usr/portage/distfiles:/usr/portage/distfiles --name "$container" "$image" bash -exc $'
  emerge -u irssi
	emerge --depclean
' )

docker rmi haven/${container}
( set -x; docker commit "$container" "haven/${container}" )
docker rm "$container"
