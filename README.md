# Compile Monero 0.10.1 on Ubuntu 16.04 x64

The example shows how to compile the current github version of [Monero](https://getmonero.org/), as of 14 Dec 2016, on Ubuntu 16.04 x64 or 16.10.

## Dependencies
Before proceeding with the compilation, the following packages are required:

```bash
# update Ubuntu's repository
sudo apt update

#install git to download latest Monero source code from github
sudo apt install git

# install dependencies to be able to compile Monero
sudo apt install build-essential cmake libboost-all-dev miniupnpc libunbound-dev graphviz doxygen libunwind8-dev pkg-config libssl-dev libcurl4-openssl-dev libgtest-dev


# For Fedora 25
#
# sudo dnf install git
# sudo dnf install make automake cmake gcc-c++ boost-devel miniupnpc-devel graphviz doxygen unbound-devel libunwind-devel pkgconfig openssl-devel libcurl-devel

```

## Compilation


```bash
# download the latest Monero source code from github
git clone https://github.com/monero-project/monero

# go into monero folder
cd monero/

# compile the release version.
make # or make -j number_of_threads, e.g., make -j 2

# alternatively `make release` can be used instead of `make`. This compiles
# the source code without compiling unique tests which is faster, and can
# avid problems if there are compilation errors with compiling the tests
```

## Installation
After successful compilation, the Monero binaries should be located in `./build/release/bin`. I usually move the binaries into `/opt/monero/` folder. This can be done as follows:

```bash
# optional
sudo mkdir -p /opt/monero
sudo mv -v ./build/release/bin/* /opt/monero/
```

This should result in:
```bash
/opt/monero/
├── monero-blockchain-export
├── monero-blockchain-import
├── monerod
└── monero-wallet-cli
```

Now we can start the Monero daemon, i.e., `monerod`, and let it
download the blockchain and synchronize itself with the Monero network. After that, you can run your the `monero-wallet-cli`.

```bash
# launch the Monero daemon and let it synchronize with the Monero network
/opt/monero/monerod

# launch the Monero wallet
/opt/monero/monero-wallet-cli
```

## Useful aliases (with rlwrap)
`monerod` and `monero-wallet-cli` do not have tab-compliton nor history.
This problem can be overcome using [rlwrap](https://github.com/hanslub42/rlwrap).

```bash
# install rlwrap
sudo apt install rlwrap

# download monerod and monero-wallet-cli commands files
wget -O ~/.bitmonero/monerocommands_bitmonerod.txt https://raw.githubusercontent.com/moneroexamples/compile-monero-09-on-ubuntu-16-04/master/monerocommands_bitmonerod.txt

wget -O ~/.bitmonero/monerocommands_simplewallet.txt https://raw.githubusercontent.com/moneroexamples/compile-monero-09-on-ubuntu-16-04/master/monerocommands_simplewallet.txt

# add aliases to .bashrc
echo "alias moneronode='rlwrap -f ~/.bitmonero/monerocommands_bitmonerod.txt /opt/monero/monerod'" >> ~/.bashrc
echo "alias monerowallet='rlwrap -f ~/.bitmonero/monerocommands_simplewallet.txt /opt/monero/monero-wallet-cli'" >> ~/.bashrc

# reload .bashrc
source ~/.bashrc
```

With this, we can just start the daemon and wallet simply using
`moneronode` and `monerowallet` commands. `rlwrap` will provide
tab-complition and history for the monero programs.

## Example screenshot

![Ubuntu Screeshot](https://raw.githubusercontent.com/moneroexamples/compile-monero-09-on-ubuntu-16-04/master/imgs/ubuntu_screen.jpg)


## Monero C++11 development (optional)

If you want to develop your own C++11 programs on top of Monero 0.9,
Monero's static libraries and headers will be needed. Below is shown
how they can be setup for use to write your own C++11 programs based
on Monero. An example of such a program is  [access-blockchain-in-cpp](https://github.com/moneroexamples/access-blockchain-in-cpp).


### Monero static libraries

When the compilation finishes, a number of static Monero libraries
should be generated. We will need them to link against in our C++11 programs.

Since they are spread out over different subfolders of the `./build/` folder, it is easier to just copy them into one folder. I assume that
 `/opt/monero-dev/libs` is the folder where they are going to be copied to.

```bash
# create the folder
sudo mkdir -p /opt/monero-dev/libs

# find the static libraries files (i.e., those with extension of *.a)
# and copy them to /opt/monero-dev/libs
# assuming you are still in monero/ folder which you downloaded from
# github
sudo find ./build/ -name '*.a' -exec cp -v {} /opt/monero-dev/libs  \;
```

 This should results in the following file structure:

 ```bash
/opt/monero-dev/libs/
├── libblockchain_db.a
├── libblocks.a
├── libcommon.a
├── libcrypto.a
├── libcryptonote_core.a
├── libcryptonote_protocol.a
├── libdaemonizer.a
├── libgtest.a
├── libgtest_main.a
├── liblmdb.a
├── libminiupnpc.a
├── libmnemonics.a
├── libotshell_utils.a
├── libp2p.a
├── libringct.a
├── librpc.a
└── libwallet.a
```

### Monero headers

Now we need to get Monero headers, as this is our interface to the
Monero libraries. Folder `/opt/monero-dev/headers` is assumed
to hold the headers.

```bash
# create the folder
sudo mkdir -p /opt/monero-dev/headers

# find the header files (i.e., those with extension of *.h)
# and copy them to /opt/monero-dev/headers.
# but this time the structure of directories is important
# so rsync is used to find and copy the headers files
sudo rsync -zarv --include="*/" --include="*.h" --include="*.hpp" --exclude="*" --prune-empty-dirs ./ /opt/monero-dev/headers
```

This should results in the following file structure:

```bash
# ... only part shown to save some space
├── src
│   ├── blockchain_db
│   │   ├── berkeleydb
│   │   ├── blockchain_db.h
│   │   ├── db_types.h
│   │   └── lmdb
│   ├── blockchain_utilities
│   │   ├── blockchain_utilities.h
│   │   ├── blocksdat_file.h
│   │   ├── bootstrap_file.h
│   │   ├── bootstrap_serialization.h
│   │   └── fake_core.h
│   ├── blocks
│   │   └── blocks.h
```
### Compilation and setup of libraries and header files in one command.

Add this to your `.bashrc`:

```bash
compilemonero() {

	local no_threads=1;

	[[ -n $1 ]] && no_threads=$1;

	echo "Compiling with $no_threads threads";

	make -j $no_threads;
	sudo mkdir -p /opt/monero/
	sudo mv -v ./build/release/bin/* /opt/monero/;
	sudo rm -rvf /opt/monero-dev/libs;
	sudo mkdir -p /opt/monero-dev/libs;
	sudo find ./build/ -name '*.a' -exec cp -v {} /opt/monero-dev/libs  \;
	sudo rm -rvf  -p /opt/monero-dev/headers
	sudo rsync -zarv --include="*/" --include="*.h" --include="*.hpp" --exclude="*" --prune-empty-dirs ./ /opt/monero-dev/headers;
}
```

and then, for example:

```bash
source .bashrc
cd monero
compilemonero 2 
```

### Applying Monero pull requests

Often when working with development version of Monero, it is necessery to patch the source code
with [pull requests](https://github.com/monero-project/monero/pulls), for testing or to quickly fix something without waiting for when they get
officially marged into master brunch. Doing this all the time manually can be time consuming. However, the following function can simply it. Just add it to your `.bashrc`

```bash
myapply() {
	curl -L https://github.com/monero-project/monero/pull/$1.patch | git apply -v -
}
```

And then, inside Monero folder, execte it as follows:

```bash
myapply 1689
```
where 1689 is example pull request number.

## Other examples

Other examples can be found on  [github](https://github.com/moneroexamples?tab=repositories).
Please know that some of the examples/repositories are not
finished and may not work as intended.

## How can you help?

Constructive criticism, code and website edits are always good. They can be made through github.

