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

Features that affect the build:
```
FPU - enables hardware FPU support when compiling support libraries
```

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

* ABORT <message>
Terminate all processing with the specified error

* RETURN
Stop processing the current file and drop back to where you came from

Tokens
------

Token replacement and query replacement is where the real power of the system becomes
apparant. Certain directives create or update internal tokens and these tokens can be
inserted into files at any point. Simple if-then-else constructs can be created using
query replacements, which are akin to ternary operators in C and other languages.
Simple mathematics can be performed with mathematical directives.

The basic format of a replacement is:

```
${<token construct>}
```

There are many types of token each with its own token construct format.

Token Replacements
------------------

A basic token replacement simply uses the `token construct` as a name and looks it up
in the database. The associated value is then replaced verbatim in the file.

For example if BASE is set to bf880000 then ${BASE} is replaced with bf880000.

Command Replacements
------------------

A command replacement executes a specific function and replaces the content with the
result of that function. 

```
${if <vali1> <comparison> <val2> ? <true value> : <false value>
```

if the `comparison` between `val1` and `val2` is true `true value` is used, otherwise
`false value` is used. Possible comparisons are: `==`, `!=`, `>=`, `>`, `<=`, `<`

```
${tohex <value>}
```

Simply converts the given value to hexadecimal. It does *not* prefix the value with 0x.
If you need that prefix it is your job to manuall add it.  For example: `0x${tohex 69}`

```
${fromhex <value>}
```

Interprets `value` as a hexadecimal value and returns the decimal equivalent.

```
${rpn ...}
```

Performs mathematics using a simple Reverse Polish Notation.  Provide a sequence of values
(which are pushed to the stack) and operators (which pop values from the stack, operate on
them, and push the result back to the stack). The last value pushed to the stack is taken as
the result.  Possible operations are `+`, `-`, `/` and `*`.

Example: `${rpn ${BASE} 0x10 +}`  - will add 16 to the `BASE` value

Example: `${rpn ${INDEX} 4 * ${BASE} +}` - Will multiply `INDEX` by 4 then add it to the `BASE` value.
