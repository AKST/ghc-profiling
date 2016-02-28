#!/bin/bash

main() {
  local operation=$1
  local sub_operation="${*:2}"

  if [ -z $operation ]; then
    >&2 echo -e "You need specify a command"
    project_help
    exit 1
  fi

  case $operation in
    init) install_deps $sub_operation;;
    test) profile_version $sub_operation;;
    help) project_help ;;
    *)    project_help ;;
  esac
}


#
# provides instructions to new comer
#
project_help() {
  echo "  help    provides help"
  echo
  echo "  init    downloads depenencies"
  echo "    1. OPTIONAL, aspect (packages,cabal,projects,ghc)"
  echo
  echo "  test    tests a vesion"
  echo "    1. ghc version number"
  echo "    2. test project"
  echo
}


#
# installs dependencies
#
install_deps() {
  local aspect=$1

  check_for_vm

  if [ -z $aspect ]; then
    install_packages
    install_cabal
    install_projects
    install_ghc
  fi

  case $aspect in
    packages) install_packages ;;
    cabal) install_cabal       ;;
    projects) install_projects ;;
    ghc) install_ghc           ;;
    *) help && exit 1;;
  esac
}


check_for_vm() {
  if [ ! $USER = "vagrant" ]; then
    >&2 echo "needs to be run in the vm"
    exit 1
  fi
}


#
# installs required packages for VM
#
install_packages() {
  sudo apt-get update
  sudo apt-get install make libgmp3c2 freeglut3 \
                       freeglut3-dev libssl-dev \
                       build-essential curl \
                       git-core -y
}


#
# installs required cabal versions
#
install_cabal() {
  local versions="./fixtures/cabal-versions.csv"

  rm -rf bins/cabal

  mkdir -p tmp/cabal-zips
  mkdir -p bins/cabal

  while IFS=, read version url
  do
    curl -L $url > tmp/cabal-zips/$version
    mkdir ./bins/cabal/$version
    cd ./bins/cabal/$version
    tar xvf ../../../tmp/cabal-zips/$version
    cd ../../..
  done < $versions
}


#
# downloads source to test compliation
#
install_projects() {
  local example_projects="./fixtures/example-projects.csv"

  rm -rf example-projects

  mkdir example-projects

  while IFS=, read name source_url
  do
    local temp_name=$(uuidgen)
    cd example-projects
    curl -L $source_url > $temp_name
    tar xjvf $temp_name
    rm -rf $temp_name
    cd ..
  done < $example_projects
}


#
# installed different GHC versions which will be profiled
#
install_ghc() {
  local versions="./fixtures/ghc-versions.csv"
  local rootpath=`pwd`

  rm -rf bins/ghc
  rm -rf tmp/ghc-zips
  rm -rf tmp/ghc-extracts

  mkdir -p tmp/ghc-zips
  mkdir -p tmp/ghc-extracts
  mkdir -p bins/ghc

  while IFS=, read version binary_url
  do
    mkdir tmp/ghc-extracts/$version
    mkdir bins/ghc/$version
    curl -L $binary_url > tmp/ghc-zips/$version

    #
    # `pwd`/tmp/ghc-extracts
    #
    cd ./tmp/ghc-extracts
    tar xjvf ../ghc-zips/$version

    #
    # `pwd`/tmp/ghc-extracts/ghc-$version
    #
    cd ghc-$version
    ./configure --prefix=$rootpath/bins/ghc/$version
    make install

    #
    # pwd
    #
    cd ../../..
  done < $versions
}


main $@
