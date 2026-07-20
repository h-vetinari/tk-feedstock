#!/bin/bash

set -ex

pushd tcl${PKG_VERSION}/unix
  # autoreconf -vfi
  # build and install a native interpreter first
  mkdir native
  cd native
  ../configure --prefix="${BUILD_PREFIX}" --host="${BUILD}" \
    CC="${CC_FOR_BUILD}" CFLAGS="-O3 -isystem ${BUILD_PREFIX}/include"
  make -j${CPU_COUNT} ${VERBOSE_AT} install-binaries install-libraries
  cd ..

  # build the actual package
  ./configure --prefix="${PREFIX}" --with-system-libtommath
  make -j${CPU_COUNT} ${VERBOSE_AT}
popd

if [[ "$target_platform" == osx-* ]]; then
  CONFIGURE_ARGS="${CONFIGURE_ARGS} --enable-aqua=yes"
elif [[ "$tk_variant" == xft ]]; then
  CONFIGURE_ARGS="${CONFIGURE_ARGS} --enable-xft"
  pkg-config --cflags xft fontconfig
fi

pushd tk${PKG_VERSION}/unix
  # autoreconf -vfi
  ./configure --prefix="${PREFIX}"        \
              --with-tcl=../../tcl${PKG_VERSION}/unix  \
              ${CONFIGURE_ARGS}
  cat config.log
  make -j${CPU_COUNT} ${VERBOSE_AT}
popd
