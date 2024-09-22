CLASS zcl_mm_004 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MM_004 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA lt_original_data TYPE STANDARD TABLE OF zc_smm011 WITH DEFAULT KEY.

    lt_original_data = CORRESPONDING #( it_original_data ).

    LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<fs_original_data>).

      SPLIT <fs_original_data>-materialdocumentheadertext AT '-' INTO TABLE DATA(lt_result).

      READ TABLE lt_result INTO DATA(lv_str1) INDEX 1.
      IF sy-subrc = 0.
        <fs_original_data>-shipmentdocument = lv_str1.
      ENDIF.

      READ TABLE lt_result INTO DATA(lv_str2) INDEX 2.
      IF sy-subrc = 0.
        <fs_original_data>-containernumber = lv_str2.
      ENDIF.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #(  lt_original_data ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
