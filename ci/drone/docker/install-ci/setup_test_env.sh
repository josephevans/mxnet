#
# This sets up the environment for all linux CI tests defined in ci/drone/pipelines.yaml
#
#  If you need to overwrite any of these, you can do so in the commands for the pipeline.
#

mkdir -p /work
rm -rf /work/mxnet
ln -s $DRONE_WORKSPACE /work/mxnet
rm -rf /work/build
ln -s $DRONE_WORKSPACE/build /work/build

export MXNET_HOME=$DRONE_WORKSPACE

#export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/cuda/lib64:/usr/local/cuda/compat:$LD_LIBRARY_PATH
#export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH


