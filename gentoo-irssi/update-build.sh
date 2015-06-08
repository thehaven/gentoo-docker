#!/bin/bash
set -e

container="gentoo-irssi"
image="haven/docker-gentoo-stage3"

if [ ! "$( docker images | grep $image )" ]; then
  echo $image does not seem to exist.
  exit
fi

if [ ! -x /usr/bin/pbzip2 ]; then sudo emerge pbzip2; fi
if [ ! -x /usr/bin/pv ]; then sudo emerge pb; fi

docker rm -f "$container" > /dev/null 2>&1 || true
( set -x; docker run -t  -v /usr/portage:/usr/portage:ro -v /usr/portage/distfiles:/usr/portage/distfiles --name "$container" "$image" bash -exc $'
  emerge -u irssi
	emerge --depclean
' )

bz2="${container}.tar.bz2"
( set -x; docker export "$container" | pbzip2 -z -9 > "$bz2" )

docker rm "$container"
docker rmi "$image"

echo 'FROM scratch' > Dockerfile
if [ -f MAINTAINER ]; then cat MAINTAINER >> Dockerfile; fi
echo "ADD $bz2 /" >> Dockerfile
echo 'CMD ["/usr/bin/irssi"]' >> Dockerfile

user="$(docker info | awk '/^Username:/ { print $2 }')"
[ -z "$user" ] || user="$user/"
( set -x; docker build -t "${user}${container}" . )
( set -x; git add Dockerfile "$bz2" )
