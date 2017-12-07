# Getting started with the Mbed OS file system

This example demonstrates how to use the Mbed OS file system.

Please install [Mbed CLI](https://os.mbed.com/docs/v5.6/tools/setup.html).

## Hardware requirements

This example uses a block device as storage. This can be either an external
block device or simulated on a heap block device on boards with enough RAM.

## Usage

#### Import the example

Make sure you have an Mbed development environment set up. [Get started with Mbed OS](https://os.mbed.com/docs/v5.6/tutorials/your-first-program.html)
to set everything up.

From the command-line, import the example:

```
mbed import mbed-os-example-filesystem
cd mbed-os-example-filesystem
```

#### Compile the example

Invoke `mbed compile`, and specify the name of your platform and your favorite
toolchain (`GCC_ARM`, `ARM`, `IAR`). For example, for the ARM Compiler 5:

```
mbed compile -m K64F -t ARM
```

Your PC may take a few minutes to compile your code. At the end, you see the
following result:

```
[snip]
+--------------------------+-------+-------+-------+
| Module                   | .text | .data |  .bss |
+--------------------------+-------+-------+-------+
| Fill                     |   164 |     0 |  2136 |
| Misc                     | 54505 |  2556 |   754 |
| drivers                  |   640 |     0 |    32 |
| features/filesystem      | 15793 |     0 |   550 |
| features/storage         |    42 |     0 |   184 |
| hal                      |   418 |     0 |     8 |
| platform                 |  2355 |    20 |   582 |
| rtos                     |   135 |     4 |     4 |
| rtos/rtx                 |  5861 |    20 |  6870 |
| targets/TARGET_Freescale |  8382 |    12 |   384 |
| Subtotals                | 88295 |  2612 | 11504 |
+--------------------------+-------+-------+-------+
Allocated Heap: 24576 bytes
Allocated Stack: unknown
Total Static RAM memory (data + bss): 14116 bytes
Total RAM memory (data + bss + heap + stack): 38692 bytes
Total Flash memory (text + data + misc): 91947 bytes

Image: ./BUILD/K64F/ARM/mbed-os-example-filesystem.bin
```

#### Run the example

1. Connect your Mbed Enabled device to the computer over USB.
1. Copy the binary file to the Mbed Enabled device.
1. Press the reset button to start the program.
1. Open the UART of the board in your favorite UART viewing program. For
   example, `screen /dev/ttyACM0`.

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

## Changing the file system

In Mbed OS, a C++ classes that inherits from the [FileSystem](https://os.mbed.com/docs/v5.6/reference/storage.html#declaring-a-file-system)
interface represents each file system. You can change the file system in the
example by changing the class declared in main.cpp.

``` diff
- LittleFileSystem fs("fs");
+ FATFileSysten fs("fs");
```

Mbed OS has two options for the file system:

- [**LittleFileSystem**](https://os.mbed.com/docs/v5.6/reference/littlefilesystem.html) -
  The little file system (LittleFS) is a fail-safe file system we designed
  for embedded systems, specifically for microcontrollers that use flash
  storage.

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

  - **Portable** - Almost every operating system supports the FAT file system,
    which is the most common file system found on portable storage, such as SD
    cards and flash drives. The FAT file system is the easiest way to support
    access from a PC.

## Changing the block device

In Mbed OS, a C++ classes that inherits from the [BlockDevice](https://os.mbed.com/docs/v5.6/reference/storage.html#block-devices)
interface represents each block device. You can change the filesystem in the
example by changing the class declared in main.cpp.

**Note:** Most block devices require pin assignments. Double check that the
pins in `driver/mbed_lib.json` are correct.

``` diff
-SPIFBlockDevice bd(
-        MBED_CONF_SPIF_DRIVER_SPI_MOSI,
-        MBED_CONF_SPIF_DRIVER_SPI_MISO,
-        MBED_CONF_SPIF_DRIVER_SPI_CLK,
-        MBED_CONF_SPIF_DRIVER_SPI_CS);
+SDBlockDevice bd(
+        MBED_CONF_SD_SPI_MOSI,
+        MBED_CONF_SD_SPI_MISO,
+        MBED_CONF_SD_SPI_CLK,
+        MBED_CONF_SD_SPI_CS);
```

Mbed OS has several options for the block device:

- **SPIFBlockDevice** - Block device driver for NOR-based SPI flash devices that
support SFDP. NOR-based SPI flash supports byte-sized read and writes, with an
erase size of about 4kbytes. An erase sets a block to all 1s, with successive
writes clearing set bits.

- **DataFlashBlockDevice** - Block device driver for NOR-based SPI flash devices
that support the DataFlash protocol, such as the Adesto AT45DB series of
devices. DataFlash is a memory protocol that combines flash with SRAM buffers
for a programming interface. DataFlash supports byte-sized read and writes, with
an erase size of around 528 bytes or sometimes 1056 bytes. DataFlash provides
erase sizes with and extra 16 bytes for error correction codes (ECC), so a flash
translation layer (FTL) may still present 512 byte erase sizes.

- **SDBlockDevice** - Block device driver for SD cards and eMMC memory chips. SD
cards or eMMC chips offer a full FTL layer on top of NAND flash. This makes the
storage well-suited for systems that require a about 1GB of memory.
Additionally, SD cards are a popular form of portable storage. They are useful
if you want to store data that you can access from a PC.

- [**HeapBlockDevice**](https://os.mbed.com/docs/v5.6/reference/heapblockdevice.html) -
  Block device that simulates storage in RAM using the heap. Do not use the heap
  block device for storing data persistently because a power loss causes
  complete loss of data. Instead, use it fortesting applications when a storage
  device is not available.

Additionally, Mbed OS contains several utility block devices to give you better
control over the allocation of storage.

- [**SlicingBlockDevice**](https://os.mbed.com/docs/v5.6/reference/slicingblockdevice.html) -
  With the slicing block device, you can partition storage into smaller block
  devices that you can use independently.

- [**ChainingBlockDevice**](https://os.mbed.com/docs/v5.6/reference/chainingblockdevice.html) -
  With the chaining block device, you can chain multiple block devices together
  and extend the usable amount of storage.

- [**MBRBlockDevice**](https://os.mbed.com/docs/v5.6/reference/mbrblockdevice.html) -
  Mbed OS comes with support for storing partitions on disk with a Master Boot
  Record (MBR). The MBRBlockDevice provides this functionality and supports
  creating partitions at runtime or using preformatted partitions configured
  separately from outside the application.

- **ReadOnlyBlockDevice** - With the read-only block device, you can wrap a
  block device in a read-only layer, ensuring that user of the block device does
  not modify the storage.

- **ProfilingBlockDevice** - With the profiling block device, you can profile
  the quantity of erase, program and read operations that are incurred on a
  block device.

- **ObservingBlockDevice** - The observing block device grants the user the
  ability to register a callback on block device operations. You can use this to
  inspect the state of the block device, log different metrics or perform some
  other operation.

- **ExhaustibleBlockDevice** - Useful for evaluating how file systems respond to
  wear, the exhaustible block device simulates wear on another form of storage.
  You can configure it to expire blocks as necessary.

