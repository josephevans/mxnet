#!/bin/bash


# mxnet libraries
mx_lib="build/libmxnet.so build/3rdparty/tvm/libtvm_runtime.so build/libtvmop.so build/tvmop.conf build/libcustomop_lib.so build/libcustomop_gpu_lib.so build/libsubgraph_lib.so build/3rdparty/openmp/runtime/src/libomp.so"
mx_lib_cython="build/libmxnet.so build/3rdparty/tvm/libtvm_runtime.so build/libtvmop.so build/tvmop.conf build/libcustomop_lib.so build/libcustomop_gpu_lib.so build/libsubgraph_lib.so python/mxnet/_cy3/*.so build/3rdparty/openmp/runtime/src/libomp.so python/mxnet/_ffi/_cy3/*.so"
mx_lib_make="lib/libmxnet.so lib/libmxnet.a lib/libtvm_runtime.so lib/libtvmop.so lib/tvmop.conf build/libcustomop_lib.so build/libcustomop_gpu_lib.so build/libsubgraph_lib.so 3rdparty/dmlc-core/libdmlc.a 3rdparty/tvm/nnvm/lib/libnnvm.a"

# Python wheels
mx_pip="build/*.whl"

# mxnet cmake libraries in cmake builds we do not produce a libnvvm static library by default.
mx_cmake_lib="build/libmxnet.so build/3rdparty/tvm/libtvm_runtime.so build/libtvmop.so build/tvmop.conf build/tests/mxnet_unit_tests build/3rdparty/openmp/runtime/src/libomp.so"
mx_cmake_lib_no_tvm_op="build/libmxnet.so build/libcustomop_lib.so build/libcustomop_gpu_lib.so build/libsubgraph_lib.so build/tests/mxnet_unit_tests build/3rdparty/openmp/runtime/src/libomp.so"
mx_cmake_lib_cython="build/libmxnet.so build/3rdparty/tvm/libtvm_runtime.so build/libtvmop.so build/tvmop.conf build/tests/mxnet_unit_tests build/3rdparty/openmp/runtime/src/libomp.so python/mxnet/_cy3/*.so python/mxnet/_ffi/_cy3/*.so"

# mxnet cmake libraries in cmake builds we do not produce a libnvvm static library by default.
mx_cmake_lib_debug="build/libmxnet.so build/3rdparty/tvm/libtvm_runtime.so build/libtvmop.so build/tvmop.conf build/libcustomop_lib.so build/libcustomop_gpu_lib.so build/libsubgraph_lib.so build/tests/mxnet_unit_tests"
mx_mkldnn_lib="build/libmxnet.so build/3rdparty/tvm/libtvm_runtime.so build/libtvmop.so build/tvmop.conf build/3rdparty/openmp/runtime/src/libomp.so build/libcustomop_lib.so build/libcustomop_gpu_lib.so build/libsubgraph_lib.so"
mx_mkldnn_lib_make="lib/libmxnet.so lib/libmxnet.a lib/libtvm_runtime.so lib/libtvmop.so lib/tvmop.conf build/libcustomop_lib.so build/libcustomop_gpu_lib.so build/libsubgraph_lib.so 3rdparty/dmlc-core/libdmlc.a 3rdparty/tvm/nnvm/lib/libnnvm.a"
mx_tensorrt_lib="build/libmxnet.so build/3rdparty/tvm/libtvm_runtime.so build/libtvmop.so build/tvmop.conf build/3rdparty/openmp/runtime/src/libomp.so lib/libnvonnxparser_runtime.so.0 lib/libnvonnxparser.so.0 lib/libonnx_proto.so lib/libonnx.so"
mx_lib_cpp_examples="build/libmxnet.so build/3rdparty/tvm/libtvm_runtime.so build/libtvmop.so build/tvmop.conf build/3rdparty/openmp/runtime/src/libomp.so build/libcustomop_lib.so build/libcustomop_gpu_lib.so build/libsubgraph_lib.so build/cpp-package/example/* python/mxnet/_cy3/*.so python/mxnet/_ffi/_cy3/*.so"
mx_lib_cpp_examples_make="lib/libmxnet.so lib/libmxnet.a lib/libtvm_runtime.so lib/libtvmop.so lib/tvmop.conf build/libcustomop_lib.so build/libcustomop_gpu_lib.so build/libsubgraph_lib.so 3rdparty/dmlc-core/libdmlc.a 3rdparty/tvm/nnvm/lib/libnnvm.a 3rdparty/ps-lite/build/libps.a deps/lib/libprotobuf-lite.a deps/lib/libzmq.a build/cpp-package/example/* python/mxnet/_cy3/*.so python/mxnet/_ffi/_cy3/*.so"
mx_lib_cpp_capi_make="lib/libmxnet.so lib/libmxnet.a lib/libtvm_runtime.so lib/libtvmop.so lib/tvmop.conf libsample_lib.so lib/libmkldnn.so.1 lib/libmklml_intel.so 3rdparty/dmlc-core/libdmlc.a 3rdparty/tvm/nnvm/lib/libnnvm.a 3rdparty/ps-lite/build/libps.a deps/lib/libprotobuf-lite.a deps/lib/libzmq.a build/cpp-package/example/* python/mxnet/_cy3/*.so python/mxnet/_ffi/_cy3/*.so build/tests/cpp/mxnet_unit_tests"
mx_lib_cpp_examples_no_tvm_op="build/libmxnet.so build/libcustomop_lib.so build/libcustomop_gpu_lib.so build/libsubgraph_lib.so build/3rdparty/openmp/runtime/src/libomp.so build/cpp-package/example/* python/mxnet/_cy3/*.so python/mxnet/_ffi/_cy3/*.so"
mx_lib_cpp_examples_cpu="build/libmxnet.so build/3rdparty/tvm/libtvm_runtime.so build/libtvmop.so build/tvmop.conf build/3rdparty/openmp/runtime/src/libomp.so build/cpp-package/example/*"


BUILD_ID=$1
BUILD_LIBS=$2

if [ -z "$BUILD_ID" -o -z "$BUILD_LIBS" ]; then
	echo "Usage: $0 <build-id> <libs>"
	exit
fi

libsvar="$BUILD_LIBS"
echo "Stashing build for [$BUILD_ID] using files: ${!libsvar}"

cd $DRONE_WORKSPACE
#FILELIST="$(ls ${!libsvar} 2>/dev/null | grep -v CMakeLists)"
FILELIST="$(ls ${!libsvar} | grep -v CMakeLists)"
#echo "Files found to stash: $FILELIST"

TARTMP="stash-${BUILD_ID}-${DRONE_BUILD_NUMBER}.tgz"
EXPIRE_DATE=$(date +'%Y-%m-%dT%H:%M:%SZ' -d @$(expr $(date +%s) + 14400))

if [ ! -z "$FILELIST" ]; then
	echo "Stashing files into $TARTMP"
	tar czvf /tmp/$TARTMP $FILELIST
	aws s3 cp /tmp/$TARTMP s3://mxnet-ci-build-stash/$TARTMP --quiet --no-progress --expires "$EXPIRE_DATE"
fi




