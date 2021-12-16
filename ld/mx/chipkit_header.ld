SECTIONS
{
  .header_info ALIGN(4) :
  {
    _image_header_info = . ;
    LONG(SIZEOF(.header_info))                 /* size of this structure       */
    LONG(0xFFFFFFFF)                           /* bootloader version           */
    KEEP(*(.mpide_version *.mpide_version.*))  /* MPIDE build version          */
    LONG(0xFFFFFFFF)                           /* booloader capabilities       */
    LONG(0xFFFFFFFF)                           /* VID and PID                  */
    LONG(_IMAGE_TYPE)                          /* image type and options       */
    LONG(_JUMP_ADDR)                           /* image execution address      */
    LONG(_ebase_address)                       /* image base address           */
    LONG(_IMAGE_FLASH_SIZE)                    /* size of image flash used     */
    LONG(ORIGIN(kseg0_eeprom_mem))             /* eeprom location              */
    LONG(LENGTH(kseg0_eeprom_mem))             /* eeprom size                  */
    LONG(ORIGIN(configsfrs))                   /* config bits location         */
    LONG(LENGTH(configsfrs))                   /* config bits size             */
    LONG(_ram_header_addr)                     /* ram header pointer           */
    LONG(SIZEOF(.ram_exchange_data))           /* ram Header size              */
    LONG(0xFFFFFFFF)                           /* what the bootloader skips    */
    LONG(_original_vector_0)                   /* the original vector 0        */
    LONG(_new_vector_0)                        /* new/indirect vector 0        */
    LONG(_vector_spacing << 5)                 /* spacing of both org/new vec  */
    _image_header_info_end = . ;
  } > kseg0_program_mem
  ASSERT (SIZEOF(.header_info) == 76, "MPIDE Version not specfied correctly") 
}
