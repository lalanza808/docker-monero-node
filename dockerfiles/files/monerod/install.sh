#!/bin/bash

# Refer to the current hashes.txt, verify signatures, and install binaries to /usr/local/bin

set -ex

# Helper script to return proper binary download URL
get_dl_url() {
    DL_FILE=$(grep ${1} hashes.txt | awk '{print $2}')
    echo "https://downloads.getmonero.org/cli/${DL_FILE}"
}

# Detect architecture and set URL/hash accordingly
if [ "$(uname -m)" = "x86_64" ]; then
    echo "Architecture x86_64 detected"
    export MONERO_FILE=monero-linux-x64
    export MONERO_DL_URL=$(get_dl_url ${MONERO_FILE})
elif [ "$(uname -m)" = "aarch64" ]; then
    echo "Architecture ARM64 detected"
    export MONERO_FILE=monero-linux-armv8
    export MONERO_DL_URL=$(get_dl_url ${MONERO_FILE})
else
    echo "Unsupported architecture: $(uname -m)"
    exit 1
fi

# Verify trusted distributor gpg
gpg --import binaryfate.asc
gpg --verify hashes.txt
if [ "$?" -eq 0 ]; then
    echo -e "[+] Valid hashes.txt - proceeding with installation"
else
    echo -e "[!] Invalid hashes.txt, does not match verified gpg key - exiting"
    exit 2
fi

# Download binaries
echo "Downloading: ${MONERO_DL_URL}"
wget -q ${MONERO_DL_URL}
grep ${MONERO_FILE} hashes.txt | sha256sum -c -
if [ "$?" -eq 0 ]; then
    echo -e "[+] Hashes match - proceeding with installation"
else
    echo -e "[!] Hashes do not match - exiting"
    exit 3
fi

# Extract monero binaries and install all to system-wide path
mkdir ./tmp
tar xjf *.bz2 -C ./tmp --strip 1
mv ./tmp/* /usr/local/bin/

# Clean up
rm -rf ./tmp *bz2 *gz *tar