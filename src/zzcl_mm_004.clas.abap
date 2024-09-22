CLASS zzcl_mm_004 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_MM_004 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA lt_original_data TYPE STANDARD TABLE OF zc_smm019 WITH DEFAULT KEY.

    lt_original_data = CORRESPONDING #( it_original_data ).
    IF lt_original_data IS INITIAL.
      EXIT.
    ENDIF.

    SELECT a~shipmentnumber,
           a~purchaseorder,
           a~purchaseorderitem,
           SUM( a~loadingquantity ) AS loadingquantity,
           SUM( a~receivedquantity ) AS receivedquantity,
           SUM( a~openquantity ) AS openquantity
      FROM zc_tmm002 AS a
      JOIN @lt_original_data AS b ON b~shipmentnumber = a~shipmentnumber
                                 AND b~purchaseorder = a~purchaseorder
                                 AND b~purchaseorderitem = a~purchaseorderitem
     GROUP BY a~shipmentnumber,
              a~purchaseorder,
              a~purchaseorderitem
      INTO TABLE @DATA(lt_mm002).

    SORT lt_mm002 BY shipmentnumber purchaseorder purchaseorderitem.

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).
      READ TABLE lt_mm002 INTO DATA(ls_mm002) WITH KEY shipmentnumber    = <fs_original_data>-shipmentnumber
                                                       purchaseorder     = <fs_original_data>-purchaseorder
                                                       purchaseorderitem = <fs_original_data>-purchaseorderitem
                                                       BINARY SEARCH.
      IF sy-subrc = 0.
        <fs_original_data>-loadingquantity = ls_mm002-loadingquantity.
        <fs_original_data>-loadingvariance = <fs_original_data>-orderquantity - <fs_original_data>-loadingquantity.
        <fs_original_data>-receivedquantity = ls_mm002-receivedquantity.
        <fs_original_data>-openquantityforreceiving = ls_mm002-openquantity.
      ENDIF.
    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_original_data ).
  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
