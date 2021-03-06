#!/bin/bash
set -e

################################################################################
# This script performs the steps of the BASIS Quick Start tutorial
#
#   http://opensource.andreasschuh.com/cmake-basis/quickstart.html
#
# It is recommended, however, to perform these steps manually in order to
# get familiar with BASIS.
#
# Requirements: git, cmake, ninja or make
################################################################################

LOCALDIR="${PWD}/BASIS Quick Start"

if [ $# -eq 1 ]; then
  LOCALDIR="$1"
elif [ $# -gt 1 ]; then
  echo "usage: `basename "$0"` [working_directory]" 1>&2
  exit 1
fi

[ -n "$LOCALDIR" ] || { echo "Invalid working directory argument!" 1>&2; exit 1; }
 
buildtool=`which ninja` && generator='Ninja'
[ $? -eq 0 ] || { buildtool=`which make` && generator='Unix Makefiles'; }
[ $? -eq 0 ] || { echo "Either GNU Make or Ninja must be installed!" 1>&2; exit 1; }

echo "
################################################################################
# Clone BASIS
################################################################################
"

    mkdir -p "${LOCALDIR}/src" && cd "${LOCALDIR}/src"
    git clone https://github.com/schuhschuh/cmake-basis.git
    cd cmake-basis

echo "
################################################################################
# Build and Install BASIS
################################################################################
"

    mkdir -p build && cd build
    cmake .. "-G${generator}" "-DCMAKE_INSTALL_PREFIX=${LOCALDIR}" "-DBASIS_INSTALL_SCHEME=usr" -DBUILD_EXAMPLE=ON
    
    "${buildtool}" install

echo "
################################################################################
# Set variables to simplify later steps
################################################################################
"

    export PATH="${LOCALDIR}/bin:${PATH} "
    export BASIS_EXAMPLE_DIR="${LOCALDIR}/share/basis/example"
    export HELLOBASIS_RSC_DIR="${BASIS_EXAMPLE_DIR}/hellobasis"

echo "
################################################################################
# Create a BASIS project
################################################################################
"

    basisproject create --name HelloBasis --description "This is a BASIS project." --root "${LOCALDIR}/src/hellobasis"

echo "
################################################################################
# Add an Executable
################################################################################
"

    cd "${LOCALDIR}/src/hellobasis"
    cp "${HELLOBASIS_RSC_DIR}/helloc++.cxx" src/
    
    echo "
    basis_add_executable(helloc++.cxx)
    " >> src/CMakeLists.txt


echo "
################################################################################
# Add a private Library
################################################################################
"

    cd "${LOCALDIR}/src/hellobasis"
    cp "${HELLOBASIS_RSC_DIR}"/foo.* src/
    
    echo "
    basis_add_library(foo foo.cxx)
    " >> src/CMakeLists.txt

echo "
################################################################################
# Add a public Library
################################################################################
"

    cd "${LOCALDIR}/src/hellobasis"
    mkdir include/hellobasis
    
    echo "
    basis_add_library(bar bar.cxx)
    " >> src/CMakeLists.txt
    
    cp "${HELLOBASIS_RSC_DIR}/bar.cxx" src/
    cp "${HELLOBASIS_RSC_DIR}/bar.h" include/hellobasis/
    
echo "
################################################################################
# Compile HelloBasis Module
################################################################################
"

    mkdir "${LOCALDIR}/src/hellobasis/build"
    cd "${LOCALDIR}/src/hellobasis/build"
    cmake .. "-G${generator}" -DBUILD_DOCUMENTATION=ON "-DCMAKE_INSTALL_PREFIX=${LOCALDIR}"
    
    "${buildtool}" install

echo "
################################################################################
# Create a top-level project
################################################################################
"
    TOPLEVEL_DIR="${LOCALDIR}/src/HelloTopLevel"
    basisproject create --name HelloTopLevel --description "This is a BASIS TopLevel project. It demonstrates how easy it is to create a simple BASIS project." --root "${TOPLEVEL_DIR}" --toplevel

    
echo "
################################################################################
# Create a subproject which provides a library
################################################################################
"
    MODA_DIR="${LOCALDIR}/src/HelloTopLevel/modules/moda"
    basisproject create --name moda --description "Subproject library to be used elsewhere" --root "${MODA_DIR}" --module --include
    cp "${HELLOBASIS_RSC_DIR}/moda.cxx" "${MODA_DIR}/src/"
    mkdir "${MODA_DIR}/include/hellotoplevel"
    cp "${HELLOBASIS_RSC_DIR}/moda.h" "${MODA_DIR}/include/hellotoplevel/"
    
    echo "
    basis_add_library(moda SHARED moda.cxx)
    " >> "${MODA_DIR}/src/CMakeLists.txt"
    
echo "
################################################################################
# Create another subproject which uses the library of the first module
################################################################################
"
    MODB_DIR="${LOCALDIR}/src/HelloTopLevel/modules/modb"
    basisproject create --name modb --description "User example subproject executable utility repository that uses the library"  --root "${MODB_DIR}" --module --src --use moda
    cp "${HELLOBASIS_RSC_DIR}/userprog.cxx" "${MODB_DIR}/src/"
    
    echo "
    basis_add_executable(userprog.cxx)
    basis_target_link_libraries(userprog moda)
    " >> "${MODB_DIR}/src/CMakeLists.txt"

echo "
################################################################################
# Compile HelloTopLevel Module
################################################################################
"

    mkdir "${TOPLEVEL_DIR}/build"
    cd "${TOPLEVEL_DIR}/build"
    cmake .. "-G${generator}" "-DCMAKE_INSTALL_PREFIX=${LOCALDIR}" "-DBASIS_INSTALL_SCHEME=usr"
    
    "${buildtool}" install

echo "
################################################################################
# Testing the installed example executables
################################################################################
"

    export LD_LIBRARY_PATH="${LOCALDIR}/lib/hellotoplevel"
    export DYLD_LIBRARY_PATH="${LD_LIBRARY_PATH}"

    "${LOCALDIR}/bin/helloc++" | grep "How is it going?"           | echo "helloc++ test passed"
    "${LOCALDIR}/bin/userprog" | grep "Called the moda() function" | echo "userprog test passed"
