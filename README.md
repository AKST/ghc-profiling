# ghc-profiling

Finding bottle necks in GHC

## Usage

Before doing anything you'll need to setup vagrant, once you've done that
boot to the following `precise32` image

```
vagrant box add precise32 http://files.vagrantup.com/precise32.box
vagrant init precise32
vagrant up
```

Once that is up you should run `project.bash init`, which will fetch, extract
and build the different versions of GHC + fetch cabal + test source

### Initialise Project

```
bash project.bash init
```

This will download the various versions of GHC, Cabal, and test source used to compile

### Help

```
bash project.bash help
```

Provides a list of commands
