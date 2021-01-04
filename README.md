Generator for PIC32 compiler headers & libraries
------------------------------------------------

This small script takes a set of configuration files and data files and spits
out a full set of processor-specific (include/proc/p32...h) header files and SFR
libraries (lib/proc/lib32...a) to overlay over a vanilla mips GCC compiler.

`.reg` files in the `chips` directory define which chips the system builds
the files for.  Other directories (`peripherals`, `pinmap` etc) contain snippets
that are included into other files.

Files are made up of lists of directives and parameters. They may also contain
token replacements and query replacements (akin to ternary operators).

The basic format of a file is:

```
DIRECTIVE parameter parameter parameter ...
... etc ...
```

Each chip definition must contain at least the following directives:

* `FLASH <size>`
The amount of flash memory in bytes in the chip

* `SRAM <size>`
The amount of SRAM in bytes in the chip

* `BOOT <size>`
The size of any boot flash in the chip in bytes

* `SPEED <Hz>`
The maximum frequency of the chip in Hz

* `FAMILY <MX/MZ>`
The family the chip belongs to. At the moment MX and MZ are supported but other
families will be added later.

Other directives:

* `DRAM <size>`
The amount of DRAM present in the chip (for MZ/DA chips for example) in bytes

* `FEATURES <f> ...`
A list of optional features the chip supports. Equivalent to `SET <f> 1` and also 
sets internal processing options.

* `PIN <func/func/func...>`
A pin definition. The list of functions is a direct copy-and-paste from the
chip datasheet. For example `PIN PGED1/AN2/C1IND/C2INB/C3IND/RPB0/RB0`

* `INMAP <pins> <functions>`
Input PPS mapping groups. Pins and functions are / separated.  For example: `INMAP RPA0/RPB3/RPB4/RPB15/RPB7 INT4/T2CK/IC4/SS1/REFCLKI`

* `OUTMAP <pins> <functions>`
As `INMAP` but for output functions.

* `PERIPHERAL <base address> <name>`
Define a new peripheral. The base address is given in HEX with no prefix.

* `REG <base address> <name> [flags]`
Create a new register structure. Base address is given in HEX with no prefix. Flags
may be any of `CLR` `SET` `INV` and define which additional registers are generated.

* `BIT <range> <name>`
Define a new bit for the current REG. `range` may be a single number or a range
in the form `h-l` (such as `31-16`). `name` may be set to `UNUSED` to omit the
bit from the bitmap.

* `SET <key> <value>`
Create a new (or update an existing) replacement token.

* INCLUDE <file> [key=val...]
Include another file at this point. Any `key=val` pairs added after the filename are
overlaid on the token replacement list for processing this file. See *tokens* below.

Tokens
------

Token replacement and query replacement is where the real power of the system becomes
apparant. Certain directives create or update internal tokens and these tokens can be
inserted into files at any point. Simple if-then-else constructs can be created using
query replacements, which are akin to ternary operators in C and other languages.

The basic format of a replacement is:

```
<operator>{<token construct>}
```

The `operator` can be either `$` for a token replacement or `?` for a query replacement.
The `token construct` varies depending on the type of replacement.

Token Replacements
------------------

A basic token replacement simply uses the `token construct` as a name and looks it up
in the database. The associated value is then replaced verbatim in the file.

However if a `+` is included in the `token construct` it is split into two parts - the
leftmost being the name used in the lookup, and the rightmost a value which is added to
the returned value. 

For example if BASE is set to bf880000 then ${BASE+1000} is replaced with bf881000.

Query Replacements
------------------

A query replacement peforms a simple logical check on two values and selects one of two
possible strings to replace with.  The format is:

```
?{query:true:false}

If `query` is logically true then the whole block is replaced with `true`, otherwise
it's replaced with `false`.

Queries can be `==`, `!=`, `>`, `>=`, `<` or `<=`.

For example, if USB is set to 1 then:
```
?{USB==1:HAS_USB:DOESNT_HAVE_USB}`
```
is replaced with `HAS_USB`.


