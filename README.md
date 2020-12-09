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
The [changing the block device](#changing-the-block-device) section describes
how to change the file system or block device in the example.

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
toolchain (`GCC_ARM`, `ARM`, `IAR`). For example, for the ARM toolchain:

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
1. Open the UART of the board in your favorite UART viewing program. For
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

In Mbed OS, C++ classes that inherit from the [FileSystem](https://os.mbed.com/docs/latest/reference/storage.html#declaring-a-file-system)
interface represent each file system. You can change the file system in the
example by changing the class declared in main.cpp.

``` diff
- LittleFileSystem fs("fs");
+ FATFileSystem fs("fs");
```

**Note:** Different file systems require different minimum numbers of storage
blocks to function. For the `FATFileSystem`, this example requires a minimum of
256 blocks, and for the `LittleFileSystem`, this example requires a minimum of 6
blocks. You can find the number of blocks on a block device by dividing the
block device's size by its erase size.

Mbed OS has two filesystem options:

- [**LittleFileSystem**](https://os.mbed.com/docs/latest/reference/littlefilesystem.html) -
  The little file system is a fail-safe file system we designed
  for embedded systems, specifically for microcontrollers that use flash
  storage.
  
  ``` cpp
  LittleFileSystem fs("fs");
  ```

  - **Bounded RAM/ROM** - This file system works with a limited amount of memory.
    It avoids recursion and limits dynamic memory to configurable
    buffers.
  
  - **Power-loss resilient** - We designed this for operating systems
    that may have random power failures. It has strong copy-on-write
    guarantees and keeps storage on disk in a valid state.
  
  - **Wear leveling** - Because the most common form of embedded storage is
    erodible flash memories, this file system provides a form of dynamic wear
    leveling for systems that cannot fit a full flash translation layer.

- **FATFileSystem** - The FAT file system is a well-known file system that you
  can find on almost every system, including PCs. The Mbed OS implementation of
  the FAT file system is based on ChanFS and is optimized for small embedded systems.
  
  ``` cpp
  FATFileSystem fs("fs");
  ```

  - **Portable** - Almost every operating system supports the FAT file system,
    which is the most common file system found on portable storage, such as SD
    cards and flash drives. The FAT file system is the easiest way to support
    access from a PC.

## Changing the block device

Mbed-OS supports a variety of block device types, more information on supported devices can be found [here](https://os.mbed.com/docs/mbed-os/v6.5/apis/data-storage.html#Default-BlockDevice-configuration).

Each device is represented by a C++ class that inherits from the super class [BlockDevice](https://os.mbed.com/docs/latest/reference/storage.html#block-devices). These classes take their default configuration from the component configuration file. This may be found in `/mbed-os/storage/blockdevice/` under the path corresponding to the block device type. The default settings can be overridden in either this file, or, in `mbed_app.json`.

For instance, to add a SPI flash block device to an STM32F29ZI board, the following modifications are made to the application configuration file.
```
   "target_overrides": {
         ...
         "NUCLEO_F429ZI": {
             "target.components_add": ["SPIF"],
         },
         ...
     }
```

Then, if the pin assignments do not match, reassignments are added to the component configuration.  
```
   "target_overrides": {
         ...
         "NUCLEO_F429ZI": {
             "SPI_MOSI": "PC_12",
             "SPI_MISO": "PC_11",
             "SPI_CLK":  "PC_10",
             "SPI_CS":   "PA_15"
         },
         ...
     }
```
This can also be done through the application configuration file.
 
```
    "target_overrides": {
          ...
          "NUCLEO_F429ZI": {
              "spif-driver.SPI_MOSI": "PC_12",
              "spif-driver.SPI_MISO": "PC_11",
              "spif-driver.SPI_CLK":  "PC_10",
              "spif-driver.SPI_CS":   "PA_15"
          },
          ...
      }
 ```

Alternatively, `BlockDevice::get_default_instance()` may be re-implemented by the user to bypass all default settings.

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

```c++
// Connect Tx, Rx, and ground pins to a separte board running the passthrough example:
// https://os.mbed.com/users/sarahmarshy/code/SerialPassthrough/file/2a3a62ee17fa/main.cpp/
Serial pc(TX, RX);   

pc.printf("...");    // Replace printf with pc.printf in the example
```

### License and contributions

The software is provided under Apache-2.0 license. Contributions to this project are accepted under the same license. Please see [contributing.md](CONTRIBUTING.md) for more info.

This project contains code from other projects. The original license text is included in those source files. They must comply with our license guide.
