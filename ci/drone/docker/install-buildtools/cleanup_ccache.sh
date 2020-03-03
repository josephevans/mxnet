#!/bin/sh
#
# This script cleans up after a build. Specifically, it syncs the used ccache back to
#  an S3 bucket so future CI builds may use it.
#


echo "Recording stats for build"

AWS_CLOUDWATCH_CMD="aws cloudwatch put-metric-data --region us-west-2 --namespace drone --unit Seconds"

$AWS_CLOUDWATCH_CMD --metric-name build-time-$DRONE_STAGE_NAME \
	--value $(expr $DRONE_BUILD_FINISHED - $DRONE_BUILD_STARTED)

$AWS_CLOUDWATCH_CMD --metric-name build-queue-$DRONE_STAGE_NAME \
	--value $(expr $DRONE_BUILD_STARTED - $DRONE_BUILD_CREATED)

if [ "$DRONE_BUILD_STATUS" == "success" ]; then
	$AWS_CLOUDWATCH_CMD --metric-name success-build-time-$DRONE_STAGE_NAME \
		--value $(expr $DRONE_BUILD_FINISHED - $DRONE_BUILD_STARTED)
else
	$AWS_CLOUDWATCH_CMD --metric-name failed-build-time-$DRONE_STAGE_NAME \
		--value $(expr $DRONE_BUILD_FINISHED - $DRONE_BUILD_STARTED)
fi

echo "Syncing ccache to S3 bucket."

aws s3 sync $DRONE_WORKSPACE_BASE/ccache s3://mxnet-ci-drone-ccache/${DRONE_STAGE_NAME}-ccache --delete --no-progress --size-only --quiet || true




