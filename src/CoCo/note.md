# Notes

I retyped this source code from paper notes on the XROAR
emulator, using Disk EDTASM+ for assmebly, ensuring that
the output produced was the same as the binary output
from many years ago.

In so doing, I realized that the MAIN.ASM source code was
much too large for the existing buffer.  I recall assmebling
it in one pass, but I didn't not use Disk EDTASM+ in those days.

Instead, I used a patched version of the cartridge EDTASM;
this was "Super Patched EDTASM+", by Roger Schrag, published
in the September 1983 issue of RAINBOW magazine.  This patch
added many improvements, but most of all, it allowed the full
64KB of RAM to be used by the EDTASM cartirdge.

However, when I re-typed this patch into XROAR emulator and
tried it out, it didn't seem to work as expected (and I didn't
spend time to try to diagnose why).

Instead, I have entered the code as three separate files on
the STARSPO2.DSK disk, and assembled on the PC side (after
extraction and concatenation).

I may or may not come back to this to get it to assemble in
Super Patched EDTASM+; at the moment, it's not clear whether
the issue is with my typing, the patch as published, or the
XROAR emulator.
