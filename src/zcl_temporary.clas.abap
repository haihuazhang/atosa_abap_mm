CLASS zcl_temporary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_TEMPORARY IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    " Clear QAS System's Dirty data
    DELETE FROM ztmm002 WHERE shipment_number IN ( 'Atlanta 210', 'Chicago 210', 'Dallas 210', 'Dallas 888' ) .
    DELETE FROM ztmm003 WHERE shipment_number IN ( 'Atlanta 210', 'Chicago 210', 'Dallas 210', 'Dallas 888' ) .

  ENDMETHOD.
ENDCLASS.
