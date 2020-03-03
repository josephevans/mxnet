#!/bin/sh

SRC_CACHE_FILE=src-${DRONE_COMMIT}-${DRONE_BUILD_NUMBER}.tgz
SRC_CACHE_DIR=$DRONE_WORKSPACE_BASE/src-cache
SRC_TARBALL=$SRC_CACHE_DIR/$SRC_CACHE_FILE
SRC_CACHE_S3_URL=s3://mxnet-ci-drone-src-cache
BUILD_DIR=$DRONE_WORKSPACE
EXPIRE_DATE=$(date +'%Y-%m-%dT%H:%M:%SZ' -d @$(expr $(date +%s) + 14400))

mkdir -p $SRC_CACHE_DIR

clone_source()
{
	/usr/local/bin/clone-commit
	git submodule update --init --recursive
	echo "Caching source code for other build pipelines"
	tar -czf $SRC_TARBALL .
	aws s3 cp $SRC_TARBALL $SRC_CACHE_S3_URL/$SRC_CACHE_FILE --quiet --no-progress --expires "$EXPIRE_DATE"
}

if [ "$DRONE_STAGE_NAME" == "sanity" ]; then
	echo "Checking out source code from Github"
	mkdir -p $BUILD_DIR
	cd $BUILD_DIR
	clone_source
	cd $DRONE_WORKSPACE
elif [ -e $SRC_TARBALL ]; then
	echo "Using cached source code file $SRC_CACHE_FILE"
	mkdir -p $BUILD_DIR
	tar -xzf $SRC_TARBALL -C $BUILD_DIR
else
	echo "Attempting to fetch cached source code"
	aws s3 cp $SRC_CACHE_S3_URL/$SRC_CACHE_FILE $SRC_TARBALL --quiet --no-progress
	if [ -e $SRC_TARBALL ]; then
		echo "Extracting cached source code"
		mkdir -p $BUILD_DIR
		tar -xzf $SRC_TARBALL -C $BUILD_DIR
	else
		echo "Cached source code not found, checking out from Github"
		mkdir -p $BUILD_DIR
		cd $BUILD_DIR
		clone_source
		cd $DRONE_WORKSPACE
	fi
fi
