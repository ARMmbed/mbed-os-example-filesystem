#!/bin/bash
set -eo pipefail

hg clone https://os.mbed.com/teams/mbed-os-examples/code/mbed-os-example-littlefs EXAMPLE
cp $(git ls-tree --name-only HEAD) EXAMPLE
cd EXAMPLE
hg add $(cd .. ; git ls-tree --name-only HEAD)
if [ -n "$(hg status -q)" ]
then
    hg commit -u mbed -m "$(git rev-parse HEAD)"
    hg push https://os.mbed.com/teams/mbed-os-examples/code/mbed-os-example-littlefs
fi
cd ..
rm -rf EXAMPLE

hg clone https://os.mbed.com/teams/mbed-os-examples/code/mbed-os-example-fatfs EXAMPLE
cp $(git ls-tree --name-only HEAD) EXAMPLE
cd EXAMPLE
sed -i 's/LittleFileSystem fs/FATFileSystem fs/g' main.cpp
sed -i 's/SPIFBlockDevice bd/SDBlockDevice bd/g' main.cpp
sed -i 's/MBED_CONF_SPIF/MBED_CONF_SD/g' main.cpp
hg add $(cd .. ; git ls-tree --name-only HEAD)
if [ -n "$(hg status -q)" ]
then
    hg commit -u mbed -m "$(git rev-parse HEAD)"
    hg push https://os.mbed.com/teams/mbed-os-examples/code/mbed-os-example-fatfs
fi
cd ..
rm -rf EXAMPLE
