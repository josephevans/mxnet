#!/bin/sh
#
# This script sets up symlinks for ccache in the clone-src step. We can't
#  set environment variables here because the builds and tests are run in
#  different containers.
#

echo "Syncing ccache from S3 bucket."

aws s3 sync s3://mxnet-ci-drone-ccache/${DRONE_STAGE_NAME}-ccache $DRONE_WORKSPACE_BASE/ccache --no-progress --size-only --quiet || true




