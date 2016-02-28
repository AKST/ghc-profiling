install_deps() {
  install_cabal
  install_projects
  install_ghc
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

  rm -rf bins/ghc

  mkdir -p tmp/ghc-zips
  mkdir -p bins/ghc

  while IFS=, read version binary_url
  do
    curl -L $binary_url > tmp/ghc-zips/$version
    cd ./bins/ghc
    tar xjvf ../../tmp/ghc-zips/$version
    cd ../..
  done < $versions
}


install_deps
