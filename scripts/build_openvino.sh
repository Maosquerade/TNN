# TNN/scripts/
TNN_DIR=$(pwd)/../
thirdparty_dir=${TNN_DIR}/source/tnn/device/openvino/thirdparty/
mkdir ${thirdparty_dir}
mkdir ${thirdparty_dir}/openvino
mkdir ${thirdparty_dir}/openvino/lib
mkdir ${thirdparty_dir}/ngraph

mkdir build_openvino && cd build_openvino

# TNN/scripts/build_openvino
git clone https://github.com/openvinotoolkit/openvino.git
cd openvino

# TNN/scripts/build_openvino/openvino
git submodule update --init --recursive

sed -i '152,152s/SHARED/STATIC/g' inference-engine/src/inference_engine/CMakeLists.txt
sed -i 's/SHARED/STATIC/g' inference-engine/src/legacy_api/CMakeLists.txt
sed -i 's/SHARED/STATIC/g' inference-engine/src/transformations/CMakeLists.txt
sed -i 's/SHARED/STATIC/g' inference-engine/src/low_precision_transformations/CMakeLists.txt
sed -i 's/SHARED/STATIC/g' ngraph/src/ngraph/CMakeLists.txt

mkdir build && cd build

# TNN/scripts/build_openvino/openvino/build
cmake ../ \
-DENABLE_OPENCV=OFF \
-DCMAKE_INSTALL_PREFIX=${TNN_DIR}/scripts/build_openvino/openvinoInstall \
-DENABLE_CLDNN=OFF \
-DENABLE_TBB_RELEASE_ONLY=OFF \
-DTHREADING=SEQ \
-DNGRAPH_COMPONENT_PREFIX="deployment_tools/ngraph/" \

make -j8
make install
cd ../../

# TNN/scripts/build_openvino/
cp -r openvinoInstall/deployment_tools/inference_engine/include/ ${thirdparty_dir}/openvino/
cp -r openvinoInstall/deployment_tools/ngraph/include/ ${thirdparty_dir}/ngraph/
cp openvinoInstall/deployment_tools/inference_engine/lib/intel64/libinference_engine.a ${thirdparty_dir}/openvino/lib/
cp openvinoInstall/deployment_tools/inference_engine/lib/intel64/libinference_engine_legacy.a ${thirdparty_dir}/openvino/lib/
cp openvinoInstall/deployment_tools/inference_engine/lib/intel64/libinference_engine_transformations.a ${thirdparty_dir}/openvino/lib/
cp openvinoInstall/deployment_tools/inference_engine/lib/intel64/libinference_engine_lp_transformations.a ${thirdparty_dir}/openvino/lib/
cp openvinoInstall/deployment_tools/inference_engine/lib/intel64/libMKLDNNPlugin.so ${thirdparty_dir}/openvino/lib/
cp openvinoInstall/deployment_tools/inference_engine/lib/intel64/plugins.xml ${thirdparty_dir}/openvino/lib/
cp openvinoInstall/deployment_tools/inference_engine/lib/intel64/plugins.xml ./
cp openvinoInstall/deployment_tools/ngraph/lib64/libngraph.a ${thirdparty_dir}/openvino/lib/
cp openvinoInstall/lib64/libpugixml.a ${thirdparty_dir}/openvino/lib/

# delete useless git repo
rm -r openvinoInstall/deployment_tools/inference_engine/samples/
rm -r openvino

cmake ../../ \
-DTNN_OPENVINO_ENABLE=ON \
-DTNN_TEST_ENABLE=ON \
-DTNN_CPU_ENABLE=ON \
-DDEBUG=ON \

make -j8