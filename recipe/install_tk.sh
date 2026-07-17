#!/bin/bash

set -ex

IFS="." read -a VER_ARR <<<"${PKG_VERSION}"

pushd tk${PKG_VERSION}/unix
  make -j${CPU_COUNT} ${VERBOSE_AT} install
popd

rm -rf "${PREFIX}"/{man,share}

# Link binaries to non-versioned names to make them easier to find and use.
ln -s "${PREFIX}"/bin/wish${VER_ARR[0]}.${VER_ARR[1]} "${PREFIX}"/bin/wish

# copy headers
cp "${SRC_DIR}"/tk${PKG_VERSION}/{unix,macosx,generic}/*.h "${PREFIX}"/include/

# Remove buildroot traces
sed -i.bak -e "s,${SRC_DIR}/tk${PKG_VERSION}/unix,${PREFIX}/lib,g" -e "s,${SRC_DIR}/tk${PKG_VERSION},${PREFIX}/include,g" ${PREFIX}/lib/tkConfig.sh
rm -f ${PREFIX}/lib/tkConfig.sh.bak
