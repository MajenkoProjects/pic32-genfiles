OUTPUT_FORMAT("elf32-littlemips")
ENTRY(_reset)
EXTERN (_min_stack_size _min_heap_size)
PROVIDE(_min_stack_size = 0x800) ;
PROVIDE(_min_heap_size = 0x800) ;

INPUT(lib32mx795f512l.a)

MEMORY
{
  exception_mem              : ORIGIN = 0x9D000000, LENGTH = 0x1000
  kseg0_program_mem    (rx)  : ORIGIN = 0x9D001000, LENGTH = %{-{FLASH,2K}} #0x7E000
  kseg0_eeprom_mem           : ORIGIN = 0x9D07F000, LENGTH = 0x1000
  kseg0_boot_mem             : ORIGIN = 0x9FC00490, LENGTH = 0
  kseg1_boot_mem             : ORIGIN = 0xBFC00000, LENGTH = 0 
  debug_exec_mem             : ORIGIN = 0xBFC02000, LENGTH = 0
  config3                    : ORIGIN = 0xBFC02FF0, LENGTH = 4 
  config2                    : ORIGIN = 0xBFC02FF4, LENGTH = 4
  config1                    : ORIGIN = 0xBFC02FF8, LENGTH = 4
  config0                    : ORIGIN = 0xBFC02FFC, LENGTH = 4
  kseg1_data_mem       (w!x) : ORIGIN = 0xA0000000, LENGTH = 0x20000
  sfrs                       : ORIGIN = 0xBF800000, LENGTH = 0x100000
  configsfrs                 : ORIGIN = 0xBFC02FF0, LENGTH = 0x10
}

_ebase_address  	    = ORIGIN(exception_mem);
_IMAGE_PTR_TABLE       	= _ebase_address + 0x0F8;
_IMAGE_HEADER_ADDR      = _ebase_address + 0x0FC;
_GEN_EXCPT_ADDR         = _ebase_address + 0x180;
_RESET_ADDR             = ORIGIN(kseg0_program_mem);
_EEPROM_ADDR            = ORIGIN(kseg0_eeprom_mem);
_BEV_EXCPT_ADDR         = 0xBFC00380;
_DBG_EXCPT_ADDR         = 0xBFC00480;
_DBG_CODE_ADDR          = ORIGIN(debug_exec_mem);

_imageReserved                      = 0x00000000 ;
_imageMPIDE                         = 0x00000001 ;
_imageBootFlashBootloader           = 0x00000002 ;
_imageProgramFlashBootloader        = 0x00000004 ;
_imageSplitFlashBootloader          = 0x00000008 ;
_imageFullFlashEraseLess4KEEProm    = 0x00010000 ;
_imageJustInTimeFlashErase          = 0x00020000 ;
_imageLinkerSpecifiedFlashErase     = 0x00040000 ;
_imageFullFlashErase                = 0x00080000 ;
_imageExecutionJumpAddress          = 0x01000000 ;
_imageExecutionJumpToFirstInFlash   = 0x02000000 ;
 
 _IMAGE_TYPE            = _imageMPIDE | _imageJustInTimeFlashErase | _imageExecutionJumpAddress;
 _IMAGE_FLASH_SIZE      = LENGTH(exception_mem) + LENGTH(kseg0_program_mem);
 _JUMP_ADDR             = _RESET_ADDR;

SECTIONS
{
  /* Boot Sections */
  .reset _RESET_ADDR :
  {
    KEEP(*(.reset))
  } > kseg0_program_mem
}

