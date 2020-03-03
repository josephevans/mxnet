#
# This script sets up the build environment for all linux CI builds.
#
#  These can be overwritten in the pipeline commands, if needed.
#

mkdir -p $DRONE_WORKSPACE/build /work
rm -rf /work/mxnet
ln -s $DRONE_WORKSPACE /work/mxnet
rm -rf /work/build
ln -s $DRONE_WORKSPACE/build /work/build

# setup ccache environment
CCDIR=/usr/local/ccache-redirects
CCACHE=/usr/local/bin/ccache
if [ ! -e $CCDIR ]
then
    echo "Setting up ccache symlinks."
    mkdir -p $CCDIR
    for c in cc gcc c++ g++; do
        ln -sf $CCACHE $CCDIR/$c
    done
fi
export CCACHE_MAXSIZE=20G
export CCACHE_SLOPPINESS=include_file_mtime
export CCACHE_TEMPDIR=$DRONE_WORKSPACE_BASE/ccache-tmp
export CCACHE_DIR=$DRONE_WORKSPACE_BASE/ccache
mkdir -p $CCACHE_TEMPDIR $CCACHE_DIR
export CC=$CCDIR/gcc
export CXX=$CCDIR/g++

export PATH=$CCDIR:/usr/local/bin:/usr/local/cuda/bin:$PATH

export MXNET_HOME=$DRONE_WORKSPACE

#export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/cuda/lib64:/usr/local/cuda/compat:$LD_LIBRARY_PATH



