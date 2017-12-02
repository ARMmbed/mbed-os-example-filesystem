# Getting started with the Mbed OS filesystem

This example demonstrates how to use the Mbed OS filesystem.

Please install [Mbed CLI](https://github.com/ARMmbed/mbed-cli#installing-mbed-cli).

## Hardware requirements

This example uses a block device as storage. This can be either an external
block device, or simulated on a heap block device on boards with enough RAM.

## Usage

#### Import the example

Make sure you have an Mbed development environment set up. See
[Getting Started with Mbed OS](TODO LINK ME) to get everything set up.

From the command-line, import the example:

```
mbed import mbed-os-example-filesystem
cd mbed-os-example-filesystem
```

#### Compile the example

Invoke `mbed compile`, and specify the name of your platform and your favorite toolchain (`GCC_ARM`, `ARM`, `IAR`). For example, for the ARM Compiler 5:

```
mbed compile -m K64F -t ARM
```

Your PC may take a few minutes to compile your code. At the end, you see the following result:

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

Image: ./BUILD/K64F/gcc_arm/mbed-os-example-fat-filesystem.bin
```

#### Run the example

1. Connect your mbed device to the computer over USB.
1. Copy the binary file to the mbed device.
1. Press the reset button to start the program.
1. Open the UART of the board in your favorite UART viewing program. For example, `screen /dev/ttyACM0`.

You should see the following output:

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
will increment the numbers stored on disk:

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

If you find yourself with a corrupted filesystem, you can reset the storage
by pressing BUTTON1:

```
Initializing the block device... OK
Erasing the block device... OK
Deinitializing the block device... OK
```

Note that if you press the reset button at the wrong time you may corrupt
a non-power-resilient filesystem!

## Changing the filesystem

In Mbed OS, each filesystem is represented by a C++ classes that inherits from
the [FileSystem](TODO LINK ME) interface. You can change the filesystem in the
example by changing the class declared in main.cpp.

``` diff
- LittleFileSystem fs("fs");
+ FATFileSysten fs("fs");
```

Currently, Mbed OS has two options for the filesystem:

1. [LittleFileSystem](TODO LINK ME, TO DOCS PAGE?)

   The littlefs is a little fail-safe filesystem designed for embedded systems.

   **Bounded RAM/ROM** - The littlefs is designed to work with a limited amount
   of memory. Recursion is avoided, and dynamic memory is limited to configurable
   buffers that can be provided statically.
   
   **Power-loss resilient** - The littlefs is designed for systems that may have
   random power failures. The littlefs has strong copy-on-write guarantees, and
   storage on disk is always kept in a valid state.
   
   **Wear leveling** - Because the most common form of embedded storage is erodible
   flash memories, littlefs provides a form of dynamic wear leveling for systems
   that cannot fit a full flash translation layer.

   You can find more info about the littlefs [here](TODO LINK ME, TO DOCS PAGE?).

1. [FATFileSystem](TODO LINK ME, TO DOCS PAGE?)

   The FAT filesystem is a well known filesystem that you can find on almost every
   system, including PCs. Mbed OS's implementation of the FAT filesystem is based
   on [ChanFS](TODO LINK ME?), and is optimized for small embedded systems.

   **Portable** - The FAT filesystem is supported on almost every system, and is
   the most common filesystem found on portable storage such as SD cards and flash
   drives. The FAT filesystem is the easiest way to support access from a PC.

   You can find more info about the FAT filesystem [here](TODO LINK ME, TO DOCS PAGE?).

## Changing the block device

In Mbed OS, each block device is represented by a C++ classes that inherits from
the [BlockDevice](TODO LINK ME) interface. You can change the filesystem in the
example by changing the class declared in main.cpp.

**Note:** Most block devices require pin assignments. It's a good idea to double
check that the pins in `driver/mbed_lib.json` are correct.

``` diff
-SPIFBlockDevice bd(
-        MBED_CONF_SPIF_DRIVER_SPI_MOSI,
-        MBED_CONF_SPIF_DRIVER_SPI_MISO,
-        MBED_CONF_SPIF_DRIVER_SPI_CLK,
-        MBED_CONF_SPIF_DRIVER_SPI_CS);
+SDBlockDevice bd(
+        MBED_CONF_SD_DRIVER_SPI_MOSI,
+        MBED_CONF_SD_DRIVER_SPI_MISO,
+        MBED_CONF_SD_DRIVER_SPI_CLK,
+        MBED_CONF_SD_DRIVER_SPI_CS);
```

Currently, Mbed OS has four options for the block device:

1. [SPIFBlockDevice](TODO LINK ME)

   Block device driver for NOR based SPI flash devices that support SFDP.

   NOR based SPI flash supports byte-sized read and writes, with an erase size
   of around 4kbytes. An erase sets a block to all 1s, with successive writes
   clearing set bits.

   More info on NOR flash can be found on wikipedia:
   https://en.wikipedia.org/wiki/Flash_memory#NOR_memories

   You can find more info about the SPI flash driver [here](TODO LINK ME, TO DOCS PAGE? MAYBE JUST GIT REPO).

1. [DataFlashBlockDevice](TODO LINK ME)

   Block device driver for NOR based SPI flash devices that support the DataFlash
   protocol, such as the Adesto AT45DB series of devices.

   DataFlash is a memory protocol that combines flash with SRAM buffers for a
   simple programming interface. DataFlash supports byte-sized read and writes,
   with an erase size of around 528 bytes or sometimes 1056 bytes. DataFlash
   provides erase sizes with and extra 16 bytes for error correction codes (ECC)
   so that a flash translation layer (FTL) may still present 512 byte erase sizes.

   More info on DataFlash can be found on wikipedia:
   https://en.wikipedia.org/wiki/DataFlash

   You can find more info about the DataFlash driver [here](TODO LINK ME, TO DOCS PAGE? MAYBE JUST GIT REPO).

1. [SDBlockDevice](TODO LINK ME)

   Block device driver for SD cards and eMMC memory chips.

   SD cards or eMMC chips offer a full FTL layer on top of NAND flash. This
   makes the storage well suited for systems that require a very large amount of
   memory (>1GB).

   Additionally, SD cards are a popular form of portable storage, and useful
   if you want to store data that can be accessed from a PC.

   More info on SD cards can be found on wikipedia:
   https://en.wikipedia.org/wiki/Secure_Digital

   You can find more info about the SD driver [here](TODO LINK ME, TO DOCS PAGE? MAYBE JUST GIT REPO).

1. [HeapBlockDevice](TODO LINK ME)

   Block device that simulates storage in RAM using the heap.

   The heap block device is useless for storing data persistently, given that a
   power loss will cause complete loss of data. However, it is useful for testing
   applications when a storage device is not available.

   You can find more info about the heap block device [here](TODO LINK ME, TO DOCS PAGE?).

Additionally, Mbed OS contains several utility block device:

- [SlicingBlockDevice](TODO LINK ME)

  With the slicing block device, you can partition storage into smaller
  block devices that you can use independently.

- [ChainingBlockDevice](TODO LINK ME)

  With the chaining block device, you can chain multiple block devices
  together and extend the usable amount of storage.

- [MBRBlockDevice](TODO LINK ME)

  Mbed OS comes with support for storing partitions on disk with a Master Boot
  Record (MBR). The MBRBlockDevice provides this functionality and supports
  creating partitions at runtime or using pre-formatted partitions configured
  separately from outside the application.

- [ReadOnlyBlockDevice](TODO LINK ME)

  With the read-only block device, you can wrap a block device in a read-only
  layer. Insuring that the storage is not modified by the user of the block device.

- [ProfilingBlockDevice](TODO LINK ME)

  With the profiling block device, you can profile the quantity of erase, program,
  and read operations that are incured on a block device.

- [ObservingBlockDevice](TODO LINK ME)

  The observing block device grants the user the ability to register a callback
  on block device operations. This can be used to inspect the state of the block
  device, log different metrics, or perform some other operation.

- [ExhaustibleBlockDevice](TODO LINK ME)

  Useful for evaluating how filesystems respond to wear, the exhaustible block
  device simulates wear on another form of storage, and can be configured to
  expire blocks as necessary.

