CLASS lsc_zr_tmm002 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_zr_tmm002 IMPLEMENTATION.
  METHOD save_modified.
    IF create-zr_tmm002 IS NOT INITIAL.
      INSERT ztmm002 FROM TABLE @create-zr_tmm002 MAPPING FROM ENTITY.
    ENDIF.

    IF update IS NOT INITIAL.
      UPDATE ztmm002 FROM TABLE @update-zr_tmm002
      INDICATORS SET STRUCTURE %control MAPPING FROM ENTITY.
    ENDIF.

    IF delete IS NOT INITIAL.
      LOOP AT delete-zr_tmm002 INTO DATA(ls_delete).
        DELETE FROM ztmm002 WHERE shipment_number     = @ls_delete-shipmentnumber
                              AND container_number    = @ls_delete-containernumber
                              AND purchase_order      = @ls_delete-purchaseorder
                              AND purchase_order_item = @ls_delete-purchaseorderitem.
      ENDLOOP.
    ENDIF.

    " For action ( create material document )
    IF zbp_r_tmm002=>gs_mapped_material_document IS NOT INITIAL.

      DATA:
        BEGIN OF ls_final_key,
          cid                  TYPE abp_behv_cid,
          materialdocument     TYPE mblnr,
          materialdocumentitem TYPE mblpo,
        END OF ls_final_key,
        lt_final_key LIKE TABLE OF ls_final_key.

      DATA lt_mm001 TYPE TABLE OF ztmm001.

      DATA lv_timestamp TYPE tzntstmpl.
      GET TIME STAMP FIELD lv_timestamp.

      " Update received flag and binding container number
      LOOP AT zbp_r_tmm002=>gt_serial_numbers INTO DATA(ls_serial_number).
        UPDATE ztmm003 SET received              = @abap_true,
                           receipt_date          = @ls_serial_number-receipt_date,
                           container_number      = @zbp_r_tmm002=>gs_data-container_number,
                           purchase_order        = @ls_serial_number-purchase_order,
                           purchase_order_item   = @ls_serial_number-purchase_order_item,
                           plant                 = @ls_serial_number-plant,
                           storage_location      = @ls_serial_number-storage_location,
                           last_changed_by       = @sy-uname,
                           last_changed_at       = @lv_timestamp,
                           local_last_changed_at = @lv_timestamp
                     WHERE shipment_number       = @zbp_r_tmm002=>gs_data-shipment_number
                       AND material              = @ls_serial_number-material
                       AND old_serial_number     = @ls_serial_number-old_serial_number
                       AND serial_number         = @ls_serial_number-serial_number.

        " ZTMM001
        APPEND INITIAL LINE TO lt_mm001 ASSIGNING FIELD-SYMBOL(<ls_mm001>).
        TRY.
            <ls_mm001>-uuid = cl_system_uuid=>create_uuid_x16_static(  ).
          CATCH cx_uuid_error.
        ENDTRY.
        <ls_mm001>-product          = ls_serial_number-material.
        <ls_mm001>-zserialnumber    = ls_serial_number-serial_number.
        <ls_mm001>-zoldserialnumber = ls_serial_number-old_serial_number.
        <ls_mm001>-created_by       = sy-uname.
        <ls_mm001>-created_at       = lv_timestamp.
        <ls_mm001>-last_changed_by  = sy-uname.
        <ls_mm001>-last_changed_at  = lv_timestamp.
        <ls_mm001>-local_last_changed_at  = lv_timestamp.
      ENDLOOP.

      " Update Table ZTM001
      MODIFY ztmm001 FROM TABLE @lt_mm001.

      LOOP AT zbp_r_tmm002=>gs_mapped_material_document-materialdocumentitem ASSIGNING FIELD-SYMBOL(<keys_item>).
        " Convert and get material document number
        CONVERT KEY OF i_materialdocumentitemtp FROM <keys_item>-%pid TO <keys_item>-%key.

        lt_final_key = VALUE #( BASE lt_final_key ( cid = <keys_item>-%cid
                                                    materialdocument = <keys_item>-materialdocument
                                                    materialdocumentitem = <keys_item>-materialdocumentitem ) ).
      ENDLOOP.
      SORT lt_final_key BY cid.

      LOOP AT zbp_r_tmm002=>gt_material_document_items INTO DATA(ls_material_document_item).
        DATA(lv_cid) = ls_material_document_item-%target[ 1 ]-%cid.
        DATA(lv_purchaseorder) = ls_material_document_item-%target[ 1 ]-purchaseorder.
        DATA(lv_purchaseorderitem) = ls_material_document_item-%target[ 1 ]-purchaseorderitem.
        DATA(lv_quantity) = ls_material_document_item-%target[ 1 ]-quantityinentryunit.

        " Read the historical received quantity
        SELECT SINGLE received_quantity
          FROM ztmm002
         WHERE shipment_number     = @zbp_r_tmm002=>gs_data-shipment_number
           AND container_number    = @zbp_r_tmm002=>gs_data-container_number
           AND purchase_order      = @lv_purchaseorder
           AND purchase_order_item = @lv_purchaseorderitem
          INTO @DATA(lv_receivedquantity).

        lv_receivedquantity += lv_quantity.

        READ TABLE lt_final_key INTO ls_final_key WITH KEY cid = lv_cid BINARY SEARCH.
        IF sy-subrc = 0.
          " Write back the receipt quantity and material document
          UPDATE ztmm002 SET received_quantity      = @lv_receivedquantity,
                             material_document      = @ls_final_key-materialdocument,
                             material_document_item = @ls_final_key-materialdocumentitem,
                             last_changed_by        = @sy-uname,
                             last_changed_at        = @lv_timestamp,
                             local_last_changed_at  = @lv_timestamp
                       WHERE shipment_number        = @zbp_r_tmm002=>gs_data-shipment_number
                         AND container_number       = @zbp_r_tmm002=>gs_data-container_number
                         AND purchase_order         = @lv_purchaseorder
                         AND purchase_order_item    = @lv_purchaseorderitem.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_zr_tmm002 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zr_tmm002
        RESULT result,

      "! Create Material Document
      creatematerialdocument FOR MODIFY
        IMPORTING keys FOR ACTION zr_tmm002~creatematerialdocument,
      precheck_delete FOR PRECHECK
        IMPORTING keys FOR DELETE zr_tmm002.
ENDCLASS.

CLASS lhc_zr_tmm002 IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD creatematerialdocument.
**---------------------------------------------------------------------*
** Method Description: Receive goods and create material document（101）
**
** Change records:                                                     *
**   Date         Developer           ReqNo            Descriptions    *
**===========  ================  ===============  =====================*
** 2023-11-01   XinleiXu（HAND）    X7UK900099      Initial Development
**---------------------------------------------------------------------*

    DATA: lt_material_document_headers TYPE TABLE FOR CREATE i_materialdocumenttp,
          ls_material_document_header  TYPE STRUCTURE FOR CREATE i_materialdocumenttp,
          lt_material_document_items   TYPE TABLE FOR CREATE i_materialdocumenttp\_materialdocumentitem,
          ls_material_document_item    TYPE STRUCTURE FOR CREATE i_materialdocumenttp\_materialdocumentitem,
          lt_material_document_sns     TYPE TABLE FOR CREATE i_materialdocumentitemtp\_serialnumber,
          ls_material_document_sn      TYPE STRUCTURE FOR CREATE i_materialdocumentitemtp\_serialnumber.

    DATA n TYPE i.
    DATA i TYPE i.

    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " JSON -> data
    xco_cp_json=>data->from_string( key-%param-jsondata )->apply( VALUE #(
      ( xco_cp_json=>transformation->pascal_case_to_underscore )
      ( xco_cp_json=>transformation->boolean_to_abap_bool )
    ) )->write_to( REF #( zbp_r_tmm002=>gs_data ) ).

    DATA(ls_data) = zbp_r_tmm002=>gs_data.

    " Get date
    TRY.
        DATA(lv_time_zone) = cl_abap_context_info=>get_user_time_zone( sy-uname ).
        GET TIME STAMP FIELD DATA(lv_timestamp).
        CONVERT TIME STAMP lv_timestamp TIME ZONE lv_time_zone INTO DATE DATA(lv_date).
      CATCH cx_abap_context_info_error.
        lv_date = cl_abap_context_info=>get_system_date( ).
    ENDTRY.

    " material document header
    DATA(lv_headertext) = |{ ls_data-shipment_number }-{ ls_data-container_number }|.
    ls_material_document_header = VALUE #( %cid = 'My%CID_1'
                                           goodsmovementcode = '01'
                                           postingdate = lv_date
                                           documentdate = lv_date
                                           materialdocumentheadertext = lv_headertext ).
    APPEND ls_material_document_header TO lt_material_document_headers.

    " Unit
    IF ls_data-items IS NOT INITIAL.
      SELECT unitofmeasure,
             unitofmeasure_e
        FROM i_unitofmeasure
         FOR ALL ENTRIES IN @ls_data-items
       WHERE unitofmeasure_e = @ls_data-items-entry_unit
        INTO TABLE @DATA(lt_unit).
      SORT lt_unit BY unitofmeasure_e.

      " material document item
      SORT ls_data-items BY purchase_order_item.
      LOOP AT ls_data-items INTO DATA(ls_item).
        n += 1.

        READ TABLE lt_unit INTO DATA(ls_unit) WITH KEY unitofmeasure_e = ls_item-entry_unit BINARY SEARCH.

        ls_material_document_item = VALUE #(
                 %cid_ref = 'My%CID_1'
                 %target  = VALUE #( ( %cid = |My%ItemCID_{ n }|
                                       goodsmovementtype = '101'
                                       material = ls_item-material
                                       plant = ls_item-plant
                                       storagelocation = ls_item-storage_location
                                       quantityinentryunit = ls_item-quantity_in_entry_unit
                                       entryunit = ls_unit-unitofmeasure
                                       goodsmovementrefdoctype = 'B'
                                       purchaseorder = ls_item-purchase_order
                                       purchaseorderitem = ls_item-purchase_order_item
                                       serialnumbersarecreatedautomly = abap_false ) ) ).
        APPEND ls_material_document_item TO lt_material_document_items.

        " material document serial number
        SORT ls_item-serial_numbers BY serial_number.
        LOOP AT ls_item-serial_numbers INTO DATA(ls_serialnumber).
          i += 1.

          ls_material_document_sn = VALUE #( %cid_ref = |My%ItemCID_{ n }|
                                             %target  = VALUE #( ( %cid = |My%SerialCID_{ i }|
                                                                   serialnumber = ls_serialnumber-serial_number ) ) ) .

          zbp_r_tmm002=>gt_serial_numbers =
          VALUE #( BASE zbp_r_tmm002=>gt_serial_numbers ( purchase_order      = ls_serialnumber-purchase_order
                                                          purchase_order_item = ls_serialnumber-purchase_order_item
                                                          material            = ls_serialnumber-material
                                                          old_serial_number   = ls_serialnumber-old_serial_number
                                                          serial_number       = ls_serialnumber-serial_number
                                                          receipt_date        = lv_date
                                                          plant               = ls_item-plant
                                                          storage_location    = ls_item-storage_location ) ).

          APPEND ls_material_document_sn TO lt_material_document_sns.
          CLEAR ls_serialnumber.
        ENDLOOP.
        CLEAR ls_item.
      ENDLOOP.
    ENDIF.

    " Create Material Document（Call Business Object Interfaces）
    MODIFY ENTITIES OF i_materialdocumenttp
    ENTITY materialdocument
       CREATE FIELDS ( goodsmovementcode
                       postingdate
                       documentdate
                       materialdocumentheadertext ) WITH lt_material_document_headers
       CREATE BY \_materialdocumentitem
              FIELDS ( goodsmovementtype
                       material
                       plant
                       storagelocation
                       quantityinentryunit
                       entryunit
                       goodsmovementrefdoctype
                       purchaseorder
                       purchaseorderitem
                       serialnumbersarecreatedautomly ) WITH lt_material_document_items
    ENTITY materialdocumentitem
       CREATE BY \_serialnumber
              FIELDS ( serialnumber ) WITH lt_material_document_sns
     MAPPED DATA(ls_create_mapped)
     FAILED DATA(ls_create_failed)
     REPORTED DATA(ls_create_reported).

    IF ls_create_failed IS INITIAL.
      " Stored in the global variable
      zbp_r_tmm002=>gs_mapped_material_document = ls_create_mapped.
      zbp_r_tmm002=>gt_material_document_items = lt_material_document_items.
    ENDIF.
  ENDMETHOD.


  METHOD precheck_delete.

    READ ENTITIES OF zr_tmm002 IN LOCAL MODE
    ENTITY zr_tmm002
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data)
    FAILED DATA(ls_failed)
    REPORTED DATA(ls_reported).

    LOOP AT lt_data INTO DATA(ls_data).
      IF ls_data-materialdocument IS NOT INITIAL.
        INSERT VALUE #( shipmentnumber    = ls_data-shipmentnumber
                        containernumber   = ls_data-containernumber
                        purchaseorder     = ls_data-purchaseorder
                        purchaseorderitem = ls_data-purchaseorderitem ) INTO TABLE failed-zr_tmm002.

        DATA(lv_text) = |{ ls_data-containernumber }{ '(' }{ ls_data-purchaseorder }{ '-' }{ ls_data-purchaseorderitem }{ ') was received.' }|.

        INSERT VALUE #( shipmentnumber    = ls_data-shipmentnumber
                        containernumber   = ls_data-containernumber
                        purchaseorder     = ls_data-purchaseorder
                        purchaseorderitem = ls_data-purchaseorderitem
                        %msg              = new_message_with_text( text = lv_text )
                      ) INTO TABLE reported-zr_tmm002.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
