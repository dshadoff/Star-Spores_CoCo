# Star-Spores_CoCo - Build Notes

How to build the code in this repository

## Memory Map

Start Addr | End Addr | Module # | Source File | Function
-----------|----------|-----------|-------------|---------
$2D00 | $4D4B | 1 | SPORES.ASM | Main Program
$4D4C | $4DFF | - | - | (unused)
$4E00 | $511E | 2 | XPLODE.ASM | Ship Explosion
$511F | $517D | - | - | (unused)
$517E | $526C | 3 | BONUS.ASM | Bonus Round
$526D | $55B4 | 4 | DATA1 | Bonus Round
$55B5 | $563D | 5 | PUTSPR.ASM | Drawing of Aliens
$563E | $5AA5 | 6 | DATA2 | Data
$5AA6 | $5BDB | 7 | LINDRW.ASM | Line Draw Routine
$5BDC | $5CC6 | 8 | DATA3 | Data
$5CC7 | $5D0A | 9 | SOUND.ASM | Sound Routine
$5D08 | $5D8C | 10 | NOISE.ASM | Noise (random sound) Routine
$5D8D | $5DC3 | 11 | SETPT.ASM | Graphic Function to set a point
$5DC4 | $66EA | 12 | DATA4 | Data

## Background of original code environment

The game was written in 6809 assembler on a 32K Color Computer with
Extended Color Basic, plus Disk controller and Shugart-type disk drives.
Radio Shack's Disk Extended Color BASIC was embedded in the disk controller,
and Radio Shack's "Disk EDTASM" Editor/Assembler was used to manage and
assemble the original source.  Some data was also prepared by hand, and entered
using ZBUG (included with Disk EDTASM).

As the source code was too large to be assembled as a single source file,
the code was broken into several pieces, with values of some key labels
being tracked by hand, and adjusted in the referencing source modules if
the values were to change.

As these modules were consuming most of the RAM needed in order to
execute an assembly, comments were not able to be kept in the source
code; rather, they were often managed separately by hand on paper.

The data in this repository is a reconstruction of the notes I archived at the
completion of the game.

## Code Reconstruction

The code has been re-entered into DISK EDTASM on a Color Computer Emulator,
and saved to disk in .DSK (.JVC) format.

Then, each of the source files was extracted using 'imgtool' from the MAME distribution:

`imgtool get coco_jvc_rsdos SPORES.DSK SPORES.ASM --filter=ascii`

The files were built using 'lwasm' from the lwtools set, which can be found here:
[http://www.lwtools.ca/](http://www.lwtools.ca/)

## How to Build:

### 1. On Original Machine or Emulated Color Computer:

Use Disk EDTASM+ to assemble each of the source modules into their
corresponding BIN files.  Unfortunately, the buffer was not large enough
to contain the MAIN/ASM file as a single unit.

I had originally used "Suepr Patched EDTASM+", a patch written by Roger Schrag
and published in RAINBOW magazine in Septemebr of 1983 - which allows the
EDTASM cartridge program to use the full 64KB of RAM for assembly, and also to
save to disk.  Unfortunately, I was not able to get this version to work on
the XROAR emulator, so I was forced to cross-assemble it.  I may in future
come back and revisit that EDTASM patch, but not in this release.

### 2. Cross-Assembly on a Modern PC:

Use the included asm.bat file to assemble all of the sources into their
corresponding BIN files.

### Re-assembly of the objects into the final executable:

Pre-Format the RAM, then load all fo the binaries, then save as
a complete unit (since thes are not likely to all fit on a single
diskette or disk image, use explicit drive numbers as appropriate):

PCLEAR 1
FOR I= &H2D00 to &H66EA STEP 2:POKE I,0:POKE I+1,255:NEXT I
LOADM "MAIN/BIN"
LOADM "XPLODE/BIN"
LOADM "BONUS/BIN"
LOADM "DATA1/BIN"
LOADM "PUTSPR/BIN"
LOADM "DATA2/BIN"
LOADM "LINDRW/BIN"
LOADM "DATA3/BIN"
LOADM "SOUND/BIN"
LOADM "NOISE/BIN"
LOADM "SETPT/BIN"
LOADM "DATA4A/BIN"
LOADM "DATA4B/BIN"
LOADM "DATA4C/BIN"
SAVEM "SPORES/BIN",&H2D00,&H66EA,&H2D00

