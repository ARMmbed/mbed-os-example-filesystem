![](./resources/official_armmbed_example_badge.png)
# Getting started with the Mbed OS file system

This example demonstrates how to use the Mbed OS file system.

You can find more information about the Mbed OS file system and other related pieces of the Mbed OS storage stack [in the storage overview](https://os.mbed.com/docs/latest/reference/storage.html).

**Table of contents:**

1. [Hardware requirements](#hardware-requirements)
1. [Usage](#usage)
   - [Import the example](#import-the-example)
   - [Compile the example](#compile-the-example)
   - [Run the example](#run-the-example)
   - [Troubleshooting](#troubleshooting)
1. [Changing the file system](#changing-the-file-system)
1. [Changing the block device](#changing-the-block-device)
1. [Tested configurations](#tested-configurations)

## Hardware requirements

This example uses a block device as storage. This can be one of:

* A built-in SPI flash, such as on the [FRDM-K82F](https://os.mbed.com/platforms/FRDM-K82F/).
* An external block device (one of SPI flash, DataFlash or an SD card). 
* Simulated on a heap block device on boards with enough RAM.

This example uses an instance of the LittleFileSystem API (LittleFS) on external SPI flash.
The section [changing the filesystem](#changing-the-file-system) describes
how to switch between the LittleFileSystem and the FatFileSystem.

## Usage

#### Import the example

Make sure you have an Mbed development environment set up. [Get started with Mbed OS](https://os.mbed.com/docs/latest/tutorials/mbed-os-quick-start.html)
to set everything up.

From the command-line, import the example:

```
mbed import mbed-os-example-filesystem
cd mbed-os-example-filesystem
```

#### Compile the example

Invoke `mbed compile`, and specify the name of your platform and your favorite
toolchain. For example, for the ARM toolchain:

```
mbed compile -m K64F -t ARM
```

Your PC may take a few minutes to compile your code. At the end, you see the
following result:

```
[snip]
| Module              |  .text |.data |   .bss |
|---------------------|--------|------|--------|
| [lib]/c_w.l         |  13137 |   16 |    348 |
| [lib]/fz_wm.l       |     34 |    0 |      0 |
| [lib]/libcppabi_w.l |     44 |    0 |      0 |
| [lib]/m_wm.l        |     48 |    0 |      0 |
| anon$$obj.o         |     32 |    0 | 197888 |
| main.o              |   2406 |    0 |    256 |
| mbed-os/components  |   5568 |    0 |      0 |
| mbed-os/drivers     |   2700 |    0 |   1136 |
| mbed-os/events      |   1716 |    0 |   3108 |
| mbed-os/features    |  16586 |    0 |    509 |
| mbed-os/hal         |   1622 |    4 |     67 |
| mbed-os/platform    |   7009 |   64 |    542 |
| mbed-os/rtos        |  12132 |  168 |   6634 |
| mbed-os/targets     |  19773 |   12 |    985 |
| Subtotals           |  82807 |  264 | 211473 |
Total Static RAM memory (data + bss): 211737 bytes
Total Flash memory (text + data): 83071 bytes

Image: ./BUILD/K64F/ARM/mbed-os-example-filesystem.bin
```

#### Run the example

1. Connect your Mbed Enabled device to the computer over USB.
1. Open a serial terminal to to the serial port of your connected target. For
   example, `mbed sterm`.
1. Copy the binary file to the Mbed Enabled device.
1. Press the reset button to start the program.

   
**Note:** The default serial port baud rate is 9600 bit/s.

Expected output:

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
- UBLOX_EVK_ODIN_W2 \[1\] + Heap + LittleFS
- UBLOX_EVK_ODIN_W2 \[1\] + Heap + FATFS
- UBLOX_EVK_ODIN_W2 \[1\] + SD + LittleFS
- UBLOX_EVK_ODIN_W2 \[1\] + SD + FATFS
- UBLOX_EVK_ODIN_W2 \[1\] + SPIF (requires shield) + LittleFS
- UBLOX_EVK_ODIN_W2 \[1\] + SPIF (requires shield) + FATFS
- UBLOX_EVK_ODIN_W2 \[1\] + DataFlash (requires shield) + LittleFS
- UBLOX_EVK_ODIN_W2 \[1\] + DataFlash (requires shield) + FATFS
- NUCLEO_F429ZI + Heap + LittleFS
- NUCLEO_F429ZI + Heap + FATFS
- NUCLEO_F429ZI + SD (requires shield) + LittleFS
- NUCLEO_F429ZI + SD (requires shield) + FATFS
- NUCLEO_F429ZI + SPIF (requires shield) + LittleFS
- NUCLEO_F429ZI + SPIF (requires shield) + FATFS
- NUCLEO_F429ZI + DataFlash (requires shield) + LittleFS
- NUCLEO_F429ZI + DataFlash (requires shield) + FATFS

\[1\]: Note: The UBLOX_EVK_ODIN_W2 SPI pins conflict with the default serial
pins. A different set of serial pins must be selected to use SPI flash with
serial output.

``` cpp
// Connect Tx, Rx, and ground pins to a separte board running the passthrough example:
// https://os.mbed.com/users/sarahmarshy/code/SerialPassthrough/file/2a3a62ee17fa/main.cpp/
Serial pc(TX, RX);   

pc.printf("...");    // Replace printf with pc.printf in the example
```

### License and contributions

The software is provided under Apache-2.0 license. Contributions to this project are accepted under the same license. Please see [contributing.md](CONTRIBUTING.md) for more info.

This project contains code from other projects. The original license text is included in those source files. They must comply with our license guide.
