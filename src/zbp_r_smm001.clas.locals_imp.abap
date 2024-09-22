CLASS lhc_zr_smm001 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_smm001 RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ zr_smm001 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zr_smm001.

    METHODS rba_shipmentcontainer FOR READ
      IMPORTING keys_rba FOR READ zr_smm001\_shipmentcontainer FULL result_requested RESULT result LINK association_links.

    METHODS rba_shipmentitem FOR READ
      IMPORTING keys_rba FOR READ zr_smm001\_shipmentitem FULL result_requested RESULT result LINK association_links.

    METHODS cba_shipmentcontainer FOR MODIFY
      IMPORTING entities_cba FOR CREATE zr_smm001\_shipmentcontainer.

ENDCLASS.

CLASS lhc_zr_smm001 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_shipmentcontainer.
  ENDMETHOD.

  METHOD rba_shipmentitem.
  ENDMETHOD.

  METHOD cba_shipmentcontainer.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zr_smm002 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ zr_smm002 RESULT result.

    METHODS rba_shipmentheader FOR READ
      IMPORTING keys_rba FOR READ zr_smm002\_shipmentheader FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_zr_smm002 IMPLEMENTATION.

  METHOD read.
  ENDMETHOD.

  METHOD rba_shipmentheader.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zr_smm003 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ zr_smm003 RESULT result.

    METHODS rba_shipmentheader FOR READ
      IMPORTING keys_rba FOR READ zr_smm003\_shipmentheader FULL result_requested RESULT result LINK association_links.

    METHODS rba_shipmentserialnumber FOR READ
      IMPORTING keys_rba FOR READ zr_smm003\_shipmentserialnumber FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_zr_smm003 IMPLEMENTATION.

  METHOD read.
  ENDMETHOD.

  METHOD rba_shipmentheader.
  ENDMETHOD.

  METHOD rba_shipmentserialnumber.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zr_smm004 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS read FOR READ
      IMPORTING keys FOR READ zr_smm004 RESULT result.

    METHODS rba_shipmentcontainer FOR READ
      IMPORTING keys_rba FOR READ zr_smm004\_shipmentcontainer FULL result_requested RESULT result LINK association_links.

    METHODS rba_shipmentheader FOR READ
      IMPORTING keys_rba FOR READ zr_smm004\_shipmentheader FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_zr_smm004 IMPLEMENTATION.

  METHOD read.
  ENDMETHOD.

  METHOD rba_shipmentcontainer.
  ENDMETHOD.

  METHOD rba_shipmentheader.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_smm001 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_smm001 IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
