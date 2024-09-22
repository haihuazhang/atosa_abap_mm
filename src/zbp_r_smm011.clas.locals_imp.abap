CLASS lhc_zr_smm011 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_smm011 RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ zr_smm011 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zr_smm011.

    METHODS reversescaningrecord FOR MODIFY
      IMPORTING keys FOR ACTION zr_smm011~reversescaningrecord RESULT result.

ENDCLASS.

CLASS lhc_zr_smm011 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD reversescaningrecord.

    DATA lt_data TYPE TABLE OF ztmm005.
    DATA lv_timestamp TYPE tzntstmpl.
    DATA lv_serialnumber TYPE i_serialnumbermaterialdoc_2-serialnumber.
    DATA lv_has_error TYPE abap_boolean.
    DATA lv_where TYPE string.

    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " JSON -> data
    xco_cp_json=>data->from_string( key-%param-jsondata )->apply( VALUE #(
      ( xco_cp_json=>transformation->pascal_case_to_underscore )
      ( xco_cp_json=>transformation->boolean_to_abap_bool )
    ) )->write_to( REF #( lt_data ) ).

    IF lt_data IS NOT INITIAL.

      LOOP AT lt_data ASSIGNING FIELD-SYMBOL(<lfs_data>) WHERE serial_number IS NOT INITIAL.
        CONDENSE <lfs_data>-serial_number NO-GAPS.
        <lfs_data>-serial_number = |{ <lfs_data>-serial_number ALPHA = IN }|.
      ENDLOOP.

      SELECT materialdocumentyear,
             materialdocument,
             materialdocumentitem,
             serialnumber,
             goodsmovementtype,
             materialdocumentheadertext,
             material,
             quantityinentryunit,
             purchaseorder,
             purchaseorderitem,
             shipmentdocument,
             containernumber,
             isreversed
        FROM zc_smm011
         FOR ALL ENTRIES IN @lt_data
       WHERE materialdocumentyear = @lt_data-material_document_year
         AND materialdocument     = @lt_data-material_document
         AND materialdocumentitem = @lt_data-material_document_item
        INTO TABLE @DATA(lt_records).

      IF lt_records IS NOT INITIAL.
        LOOP AT lt_records ASSIGNING FIELD-SYMBOL(<lfs_record>).
          SPLIT <lfs_record>-materialdocumentheadertext AT '-' INTO TABLE DATA(lt_text).

          READ TABLE lt_text INTO DATA(lv_str1) INDEX 1.
          IF sy-subrc = 0.
            <lfs_record>-shipmentdocument = to_upper( lv_str1 ).
          ENDIF.

          READ TABLE lt_text INTO DATA(lv_str2) INDEX 2.
          IF sy-subrc = 0.
            <lfs_record>-containernumber = to_upper( lv_str2 ).
          ENDIF.
        ENDLOOP.

        SORT lt_records BY materialdocumentyear
                           materialdocument
                           materialdocumentitem
                           serialnumber.
      ENDIF.

      LOOP AT lt_data ASSIGNING <lfs_data>.
        CLEAR: lv_has_error,lv_where.

        READ TABLE lt_records INTO DATA(ls_record) WITH KEY materialdocumentyear = <lfs_data>-material_document_year
                                                            materialdocument     = <lfs_data>-material_document
                                                            materialdocumentitem = <lfs_data>-material_document_item
                                                            serialnumber         = <lfs_data>-serial_number
                                                            BINARY SEARCH.
        IF sy-subrc = 0.
          IF ls_record-isreversed = 'Y'.
            CONTINUE.
          ENDIF.

          IF ls_record-serialnumber IS NOT INITIAL.
            " empty the field
            UPDATE ztmm003 SET received              = '',
                               receipt_date          = '00000000',
                               container_number      = '',
                               purchase_order        = '',
                               purchase_order_item   = '00000',
                               company_code          = '',
                               plant                 = '',
                               storage_location      = '',
                               last_changed_by       = @sy-uname,
                               last_changed_at       = @lv_timestamp,
                               local_last_changed_at = @lv_timestamp
             WHERE shipment_number = @ls_record-shipmentdocument
               AND material        = @ls_record-material
               AND serial_number   = @ls_record-serialnumber.
            IF sy-subrc <> 0.
              lv_has_error = abap_true.
            ENDIF.
          ENDIF.

          IF ls_record-goodsmovementtype = '161'.
            lv_where = |shipment_number     = @ls_record-shipmentdocument AND | &&
                       |container_number    = @ls_record-containernumber  AND | &&
                       |material            = @ls_record-material|.
          ELSE.
            lv_where = |shipment_number     = @ls_record-shipmentdocument AND | &&
                       |container_number    = @ls_record-containernumber  AND | &&
                       |purchase_order      = @ls_record-purchaseorder    AND | &&
                       |purchase_order_item = @ls_record-purchaseorderitem|.
          ENDIF.

          SELECT SINGLE received_quantity FROM ztmm002 WHERE (lv_where) INTO @DATA(lv_receivedquantity).
          IF sy-subrc = 0.
            IF ls_record-serialnumber IS NOT INITIAL.
              DATA(lv_quantity) = lv_receivedquantity - 1.
            ELSE.
              lv_quantity = lv_receivedquantity - ls_record-quantityinentryunit.
            ENDIF.

            UPDATE ztmm002 SET received_quantity      = @lv_quantity,
                               material_document      = @ls_record-materialdocument,
                               material_document_item = @ls_record-materialdocumentitem,
                               last_changed_by        = @sy-uname,
                               last_changed_at        = @lv_timestamp,
                               local_last_changed_at  = @lv_timestamp
             WHERE (lv_where).
            IF sy-subrc <> 0.
              lv_has_error = abap_true.
            ENDIF.
          ENDIF.

          TRY.
              DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static(  ).

              GET TIME STAMP FIELD lv_timestamp.

              INSERT INTO ztmm005 VALUES @( VALUE #( uuid                   = lv_uuid
                                                     material_document_year = ls_record-materialdocumentyear
                                                     material_document      = ls_record-materialdocument
                                                     material_document_item = ls_record-materialdocumentitem
                                                     serial_number          = ls_record-serialnumber
                                                     created_by             = sy-uname
                                                     created_at             = lv_timestamp
                                                     last_changed_by        = sy-uname
                                                     last_changed_at        = lv_timestamp
                                                     local_last_changed_at  = lv_timestamp ) ).
              IF sy-subrc <> 0.
                lv_has_error = abap_true.
              ENDIF.
            CATCH cx_root.
          ENDTRY.
        ENDIF.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zr_smm011 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zr_smm011 IMPLEMENTATION.

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
