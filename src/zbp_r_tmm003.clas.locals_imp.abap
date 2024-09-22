CLASS lhc_zr_tmm003 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zr_tmm003
        RESULT result,

      precheck_create FOR PRECHECK
        IMPORTING entities FOR CREATE zr_tmm003,
      precheck_delete FOR PRECHECK
        IMPORTING keys FOR DELETE zr_tmm003.
ENDCLASS.

CLASS lhc_zr_tmm003 IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD precheck_create.

    DATA lv_text TYPE string.
    DATA(lv_oldserialnumber) = entities[ 1 ]-oldserialnumber.
    DATA(lv_serialnumber) = entities[ 1 ]-serialnumber.

    IF lv_oldserialnumber IS NOT INITIAL AND lv_oldserialnumber <> 'N/A'.
      SELECT SINGLE *
        FROM zr_tmm003
       WHERE oldserialnumber = @lv_oldserialnumber
        INTO @DATA(ls_data1).
    ENDIF.

    SELECT SINGLE *
      FROM zr_tmm003
     WHERE serialnumber = @lv_serialnumber
      INTO @DATA(ls_data2).

    IF ls_data1 IS NOT INITIAL.
      IF ls_data1-received = abap_true.
        lv_text = |The old SN was received in Shipment { ls_data1-shipmentnumber }.|.
      ELSE.
        lv_text = |The old serial number already exists.|.
      ENDIF.
      INSERT VALUE #( shipmentnumber  = entities[ 1 ]-shipmentnumber
                      material        = entities[ 1 ]-material
                      oldserialnumber = entities[ 1 ]-oldserialnumber
                      serialnumber    = entities[ 1 ]-serialnumber ) INTO TABLE failed-zr_tmm003.

      INSERT VALUE #( shipmentnumber  = entities[ 1 ]-shipmentnumber
                      material        = entities[ 1 ]-material
                      oldserialnumber = entities[ 1 ]-oldserialnumber
                      serialnumber    = entities[ 1 ]-serialnumber
                      %msg            = new_message_with_text( text = lv_text )
                    ) INTO TABLE reported-zr_tmm003.
    ENDIF.

    IF ls_data2 IS NOT INITIAL.
      IF ls_data2-received = abap_true.
        lv_text = |The SN was received in Shipment { ls_data2-shipmentnumber }.|.
      ELSE.
        lv_text = |The serial number already exists.|.
      ENDIF.
      INSERT VALUE #( shipmentnumber  = entities[ 1 ]-shipmentnumber
                      material        = entities[ 1 ]-material
                      oldserialnumber = entities[ 1 ]-oldserialnumber
                      serialnumber    = entities[ 1 ]-serialnumber ) INTO TABLE failed-zr_tmm003.

      INSERT VALUE #( shipmentnumber  = entities[ 1 ]-shipmentnumber
                      material        = entities[ 1 ]-material
                      oldserialnumber = entities[ 1 ]-oldserialnumber
                      serialnumber    = entities[ 1 ]-serialnumber
                      %msg            = new_message_with_text( text = lv_text )
                    ) INTO TABLE reported-zr_tmm003.
    ENDIF.
  ENDMETHOD.

  METHOD precheck_delete.

    READ ENTITIES OF zr_tmm003 IN LOCAL MODE
    ENTITY zr_tmm003
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data)
    FAILED DATA(ls_failed)
    REPORTED DATA(ls_reported).

    LOOP AT lt_data INTO DATA(ls_data).
      IF ls_data-received = abap_true.
        INSERT VALUE #( shipmentnumber  = ls_data-shipmentnumber
                        material        = ls_data-material
                        oldserialnumber = ls_data-oldserialnumber
                        serialnumber    = ls_data-serialnumber ) INTO TABLE failed-zr_tmm003.

        DATA(lv_text) = |Serial number { ls_data-serialnumber } was received.|.

        INSERT VALUE #( shipmentnumber  = ls_data-shipmentnumber
                        material        = ls_data-material
                        oldserialnumber = ls_data-oldserialnumber
                        serialnumber    = ls_data-serialnumber
                        %msg            = new_message_with_text( text = lv_text )
                      ) INTO TABLE reported-zr_tmm003.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
