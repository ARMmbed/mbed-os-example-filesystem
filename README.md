![](./resources/official_armmbed_example_badge.png)
# Getting started with the Mbed OS file system

This example demonstrates how to use the Mbed OS file system.

You can find more information about the Mbed OS file system and other related pieces of the Mbed OS storage stack [in the storage overview](https://os.mbed.com/docs/latest/reference/storage.html).

## Hardware requirements

This example uses a block device as storage. This can be one of:

* A built-in SPI flash, such as on the [FRDM-K82F](https://os.mbed.com/platforms/FRDM-K82F/).
* An external block device (one of SPI flash, DataFlash or an SD card). 
* Simulated on a heap block device on boards with enough RAM.

This example uses an instance of the LittleFileSystem API (LittleFS) on external SPI flash.
The section [changing the filesystem](#changing-the-file-system) describes
how to switch between the LittleFileSystem and the FatFileSystem.

## Mbed OS build tools

### Mbed CLI 2
Starting with version 6.5, Mbed OS uses Mbed CLI 2. It uses Ninja as a build system, and CMake to generate the build environment and manage the build process in a compiler-independent manner. If you are working with Mbed OS version prior to 6.5 then check the section [Mbed CLI 1](#mbed-cli-1).
1. [Install Mbed CLI 2](https://os.mbed.com/docs/mbed-os/latest/build-tools/install-or-upgrade.html).
1. From the command-line, import the example: `mbed-tools import mbed-os-example-filesystem`
1. Change the current directory to where the project was imported.

### Mbed CLI 1
1. [Install Mbed CLI 1](https://os.mbed.com/docs/mbed-os/latest/quick-start/offline-with-mbed-cli.html).
1. From the command-line, import the example: `mbed import mbed-os-example-filesystem`
1. Change the current directory to where the project was imported.

## Building and running

1. Connect a USB cable between the USB port on the board and the host computer.
1. Run the following command to build the example project, program the microcontroller flash memory and open a serial monitor:

    * Mbed CLI 2

    ```bash
    $ mbed-tools compile -m <TARGET> -t <TOOLCHAIN> --flash --sterm
    ```

    * Mbed CLI 1

    ```bash
    $ mbed compile -m <TARGET> -t <TOOLCHAIN> --flash --sterm
    ```

Your PC may take a few minutes to compile your code.

## Expected output

```
--- Mbed OS filesystem example ---
Mounting the filesystem... Fail :(
No filesystem found, formatting... OK
Opening "/fs/numbers.txt"... Fail :(
No file found, creating a new file... OK
Writing numbers (10/10)... OK
Seeking file... OK
Incrementing numbers (10/10)... OK
Closing "/fs/numbers.txt"... OK
Opening the root directory... OK
root directory:
    .
    ..
    numbers.txt
Closing the root directory... OK
Opening "/fs/numbers.txt"...OK
numbers:
    1
    2
    3
    4
    5
    6
    7
    8
    9
    10
Closing "/fs/numbers.txt"... OK
Unmounting... OK
Mbed OS filesystem example done!
```

You can also reset the board to see the data persist across boots. Each boot
increments the numbers stored on disk:

```
--- Mbed OS filesystem example ---
Mounting the filesystem... OK
Opening "/fs/numbers.txt"... OK
Incrementing numbers (10/10)... OK
Closing "/fs/numbers.txt"... OK
Opening the root directory... OK
root directory:
    .
    ..
    numbers.txt
Closing the root directory... OK
Opening "/fs/numbers.txt"...OK
numbers:
    2
    3
    4
    5
    6
    7
    8
    9
    10
    11
Closing "/fs/numbers.txt"... OK
Unmounting... OK
Mbed OS filesystem example done!
```

If you find yourself with a corrupted file system, you can reset the storage
by pressing BUTTON1:

```
Initializing the block device... OK
Erasing the block device... OK
Deinitializing the block device... OK
```

Note that if you press the reset button at the wrong time, you may corrupt
a file system that is not power resilient!

#### Troubleshooting

If you have problems, you can review the [documentation](https://os.mbed.com/docs/latest/tutorials/debugging.html)
for suggestions on what could be wrong and how to fix it.

## Changing the file system

In Mbed OS, C++ classes that inherit from the [FileSystem](https://os.mbed.com/docs/mbed-os/latest/apis/filesystem.html)
interface are used to implement a file system instance. Mbed OS currently supports the [LittleFileSystem](https://os.mbed.com/docs/mbed-os/latest/apis/littlefilesystem.html), and [FATFileSystem](https://os.mbed.com/docs/mbed-os/latest/apis/fatfilesystem.html).  In this example, you can determine which is used, by modifying the declaration of the object ```fs``` in main.cpp.

For instance, to use the FATFileSystem, declare ```fs``` as an instance of the class FATFileSystem: 
``` diff
- LittleFileSystem fs("fs");
+ FATFileSystem fs("fs");
```

**Note:** Different file systems require different minimum numbers of storage
blocks to function. For the `FATFileSystem`, this example requires a minimum of
256 blocks, and for the `LittleFileSystem`, this example requires a minimum of 6
blocks. You can find the number of blocks on a block device by dividing the
block device's size by its erase size.

## Changing the block device

Mbed-OS supports a variety of [block devices](https://os.mbed.com/docs/mbed-os/latest/apis/data-storage.html#Default-BlockDevice-configuration). You can find information on configuring, and changing the block device used in this example [here](https://github.com/ARMmbed/mbed-os-example-blockdevice#changing-the-block-device).

## Tested configurations

- K64F + Heap + LittleFS
- K64F + Heap + FATFS
- K64F + SD + LittleFS
- K64F + SD + FATFS
- K64F + SPIF (requires shield) + LittleFS
- K64F + SPIF (requires shield) + FATFS
- K64F + DataFlash (requires shield) + LittleFS
- K64F + DataFlash (requires shield) + FATFS
- NUCLEO_F429ZI + Heap + LittleFS
- NUCLEO_F429ZI + Heap + FATFS
- NUCLEO_F429ZI + SD (requires shield) + LittleFS
- NUCLEO_F429ZI + SD (requires shield) + FATFS
- NUCLEO_F429ZI + SPIF (requires shield) + LittleFS
- NUCLEO_F429ZI + SPIF (requires shield) + FATFS
- NUCLEO_F429ZI + DataFlash (requires shield) + LittleFS
- NUCLEO_F429ZI + DataFlash (requires shield) + FATFS

### License and contributions

The software is provided under Apache-2.0 license. Contributions to this project are accepted under the same license. Please see [contributing.md](CONTRIBUTING.md) for more info.

This project contains code from other projects. The original license text is included in those source files. They must comply with our license guide.
