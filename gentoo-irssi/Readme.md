We use an update script to build gentoo images for the sole reason that
we cannot mount portage volumes using the VOLUME command as needed to
build gentoo images.

Because of this we do things the hard way - its easy to forget why so
this is why.

There are two ways to build this image:
./update-build.sh build an image and add it to a Dockerfile - this
produces a large standalone image
./update-commit.sh use docker commit to store just a diff between this
image and the stage3 base. Small image but requires the base file to be
present as well.

By Default I use update-commit.sh for size reasons.

To run this image I use the following:

docker run -it --rm --name irssi -v ${HOME}/.irssi:/root/.irssi
--sig-proxy=false haven/gentoo-irssi /usr/bin/irssi

Obviously change "haven" for your docker username or whatever user you
have assigned the image to.
