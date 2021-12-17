/* Default linker script, for normal executables */
OUTPUT_FORMAT("elf32-tradlittlemips")
OUTPUT_ARCH(pic32mx)
ENTRY(_reset)
/*
 * Provide for a minimum stack and heap size
 * - _min_stack_size - represents the minimum space that must be made
 *                     available for the stack.  Can be overridden from
 *                     the command line using the linker's --defsym option.
 * - _min_heap_size  - represents the minimum space that must be made
 *                     available for the heap.  Can be overridden from
 *                     the command line using the linker's --defsym option.
 */
EXTERN (_min_stack_size _min_heap_size)
PROVIDE(_min_stack_size = 0x400) ;
PROVIDE(_min_heap_size = 0) ;
/*************************************************************************
 * Processor-specific object file.  Contains SFR definitions.
 *************************************************************************/
INPUT("processor.o")

/*************************************************************************
 * For interrupt vector handling
 *************************************************************************/
PROVIDE(_vector_spacing = 0x00000001);
_ebase_address  = 0x9FC00000;

/*************************************************************************
 * Memory Regions
 *
 * Memory regions without attributes cannot be used for orphaned sections.
 * Only sections specifically assigned to these regions can be allocated
 * into these regions.
 *************************************************************************/
MEMORY
{
  kseg1_boot_mem             : ORIGIN = 0xBFC00000, LENGTH = 0x0200
  kseg0_boot_mem             : ORIGIN = 0x9FC00200, LENGTH = 0x0
  kseg0_program_mem    (rx)  : ORIGIN = 0x9FC00200, LENGTH = 0x9F0
  split_program_mem    (rx)  : ORIGIN = 0x${tohex ${rpn 0x9D000000 ${FLASH} + ${SPLIT} -}}, LENGTH = 0x${tohex ${SPLIT}}
  exception_mem              : ORIGIN = 0x9FC00480, LENGTH = 0x0
  debug_exec_mem             : ORIGIN = 0x9FC00490, LENGTH = 0x0
  /* debug_exec_mem             : ORIGIN = 0x9FC00490, LENGTH = 0x760 */
  config3                    : ORIGIN = 0xBFC00BF0, LENGTH = 0x4
  config2                    : ORIGIN = 0xBFC00BF4, LENGTH = 0x4
  config1                    : ORIGIN = 0xBFC00BF8, LENGTH = 0x4
  config0                    : ORIGIN = 0xBFC00BFC, LENGTH = 0x4
  kseg1_data_mem       (w!x) : ORIGIN = 0xA0000000, LENGTH = 0x${tohex ${SRAM}}
  sfrs                       : ORIGIN = 0xBF800000, LENGTH = 0x100000
  configsfrs                 : ORIGIN = 0xBFC00BF0, LENGTH = 0x10
}

/*************************************************************************
 * Memory Address Equates
 *************************************************************************/
_ebase_address  			= ORIGIN(kseg1_boot_mem);
_RESET_ADDR             	= _ebase_address;
//_DBG_EXCPT_ADDR         	= ORIGIN(exception_mem);
//_DBG_CODE_ADDR 			= ORIGIN(debug_exec_mem);
_RAM_SKIP_SIZE				= 0x600;

SECTIONS
{
  .config_BFC00BF0 : {
    KEEP(*(.config_BFC00BF0))
  } > config3
  .config_BFC00BF4 : {
    KEEP(*(.config_BFC00BF4))
  } > config2
  .config_BFC00BF8 : {
    KEEP(*(.config_BFC00BF8))
  } > config1
  .config_BFC00BFC : {
    KEEP(*(.config_BFC00BFC))
  } > config0
}

SECTIONS
{
  .reset _RESET_ADDR :
  {
    KEEP(*(.reset))
    KEEP(*(.reset.startup)) 
  } > kseg1_boot_mem

  .splittext ORIGIN(split_program_mem):
  {
    KEEP (*(.text.split))
    KEEP (*(.text.split.*))
  } >split_program_mem

  .splitrodata :
  {
    KEEP (*(.rodata.split))
    KEEP (*(.rodata.split.*))
  } >split_program_mem
}
