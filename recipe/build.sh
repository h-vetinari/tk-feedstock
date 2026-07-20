#!/bin/bash

set -ex

export CC=$(basename ${CC})
export CPP=$(basename ${CPP})
export CC_FOR_BUILD=$(basename ${CC_FOR_BUILD})

mv tcl${PKG_VERSION}/pkgs tcl${PKG_VERSION}/pkgs2

pushd tcl${PKG_VERSION}/unix
  # package these separately
  # autoreconf -vfi
  if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
    # build and install a native interpreter first
    mkdir -p native
    cd native
    ../configure --prefix="${BUILD_PREFIX}"                     \
                 --host="${BUILD}"                              \
                 --disable-zipfs                                \
                 CC="${CC_FOR_BUILD}"                           \
                 CFLAGS="-O3 -isystem ${BUILD_PREFIX}/include"
    make -j${CPU_COUNT} ${VERBOSE_AT} install-binaries install-libraries
    cd ..
  fi

  # build the actual package
  # --enable-zipfs causes Tcl to embed its standard library in the exec
  # this is unnecessary, and also breaks signing on macOS
  ./configure --prefix="${PREFIX}"      \
              --with-system-libtommath  \
              --disable-zipfs
  make -j${CPU_COUNT} ${VERBOSE_AT}
  make -j${CPU_COUNT} ${VERBOSE_AT} install
popd

if [[ "$target_platform" == osx-* ]]; then
  CONFIGURE_ARGS="${CONFIGURE_ARGS} --enable-aqua=yes"
elif [[ "$tk_variant" == xft ]]; then
  CONFIGURE_ARGS="${CONFIGURE_ARGS} --enable-xft"
  pkg-config --cflags xft fontconfig
fi

pushd tk${PKG_VERSION}/unix
  # autoreconf -vfi
  ./configure --prefix="${PREFIX}"                     \
              --with-tcl=../../tcl${PKG_VERSION}/unix  \
              --disable-zipfs                          \
              ${CONFIGURE_ARGS}
  cat config.log
  make -j${CPU_COUNT} ${VERBOSE_AT}
  make -j${CPU_COUNT} ${VERBOSE_AT} install
popd

rm -rf "${PREFIX}"/{man,share}

IFS="." read -a VER_ARR <<<"${PKG_VERSION}"

# Link binaries to non-versioned names to make them easier to find and use.
ln -s "${PREFIX}"/bin/wish${VER_ARR[0]}.${VER_ARR[1]} "${PREFIX}"/bin/wish
ln -s "${PREFIX}"/bin/tclsh${VER_ARR[0]}.${VER_ARR[1]} "${PREFIX}"/bin/tclsh

# Remove buildroot traces
sed -i.bak -e "s,${SRC_DIR}/tk${PKG_VERSION}/unix,${PREFIX}/lib,g" -e "s,${SRC_DIR}/tk${PKG_VERSION},${PREFIX}/include/tk-private,g" ${PREFIX}/lib/tkConfig.sh
sed -i.bak -e "s,${SRC_DIR}/tcl${PKG_VERSION}/unix,${PREFIX}/lib,g" -e "s,${SRC_DIR}/tcl${PKG_VERSION},${PREFIX}/include/tcl-private,g" ${PREFIX}/lib/tclConfig.sh
rm -f ${PREFIX}/lib/tkConfig.sh.bak
rm -f ${PREFIX}/lib/tclConfig.sh.bak

# copy headers
for folder in generic unix compat libtommath; do
  mkdir -p "${PREFIX}"/include/tcl-private/${folder}
  cp "${SRC_DIR}"/tcl${PKG_VERSION}/${folder}/*.h "${PREFIX}"/include/tcl-private/${folder}
done
for folder in generic unix macosx; do
  mkdir -p "${PREFIX}"/include/tk-private/${folder}
  cp "${SRC_DIR}"/tk${PKG_VERSION}/${folder}/*.h "${PREFIX}"/include/tk-private/${folder}
done
