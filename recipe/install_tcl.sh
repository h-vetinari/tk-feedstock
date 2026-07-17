#!/bin/bash

set -ex

IFS="." read -a VER_ARR <<<"${PKG_VERSION}"

pushd tcl${PKG_VERSION}/unix
  make -j${CPU_COUNT} ${VERBOSE_AT} install install-private-headers
popd

rm -rf "${PREFIX}"/{man,share}

# Link binaries to non-versioned names to make them easier to find and use.
ln -s "${PREFIX}"/bin/tclsh${VER_ARR[0]}.${VER_ARR[1]} "${PREFIX}"/bin/tclsh

# Remove buildroot traces
sed -i.bak -e "s,${SRC_DIR}/tcl${PKG_VERSION}/unix,${PREFIX}/lib,g" -e "s,${SRC_DIR}/tcl${PKG_VERSION},${PREFIX}/include,g" ${PREFIX}/lib/tclConfig.sh
rm -f ${PREFIX}/lib/tclConfig.sh.bak
