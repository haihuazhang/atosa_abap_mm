CLASS zzcl_mm_utils DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS CheckSerialNumberByMaterial
      IMPORTING Material         TYPE Matnr
                SerialNumber     TYPE zzemm008
                Plant            TYPE werks_d
                StorageLocation  TYPE zzesd003
      RETURNING VALUE(rv_result) TYPE abap_boolean.
*    CLASS-METHODS Check
    CLASS-METHODS checkStockWithoutSN
      IMPORTING Material         TYPE Matnr
                Plant            TYPE werks_d
                storageLocation  TYPE zzesd003
                Quantity         TYPE menge_d
                unit             TYPE meins
      RETURNING VALUE(rv_result) TYPE abap_boolean.
  PROTECTED SECTION.
  PRIVATE SECTION.

*  CLASS-DATA BEGIN OF


ENDCLASS.



CLASS ZZCL_MM_UTILS IMPLEMENTATION.


  METHOD checkserialnumberbymaterial.
    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
    DATA: lv_plant   TYPE werks_d,
          lv_storage TYPE zzesd003.

    " Find CA by Scenario ID
    lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
    DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
    lo_factory->query_ca(
            EXPORTING
              is_query           = VALUE #( cscn_id_range = lr_cscn )
            IMPORTING
              et_com_arrangement = DATA(lt_ca) ).

    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.

    " take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
    " get destination based on Communication Arrangement and the service ID
    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
                    comm_scenario  = 'YY1_API'
                    service_id     = 'YY1_API_REST'
                    comm_system_id = lo_ca->get_comm_system_id( ) ).

      CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
*              out->write( lx_http_dest_provider_error->get_text( ) ).
        EXIT.
    ENDTRY.

    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

        DATA(lo_request) = lo_http_client->get_http_request(   ).

        lo_http_client->enable_path_prefix( ).

        DATA(lv_uri_path) = |/API_MATERIAL_STOCK_SRV/A_MaterialSerialNumber(Material='{ material }',SerialNumber='{ serialnumber }')|.

        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').

        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).

        DATA(lv_response) = lo_response->get_text(  ).
        DATA(status) = lo_response->get_status( ).
      CATCH cx_web_http_client_error INTO DATA(lX_WEB_HTTP_CLIENT_ERROR).
        RETURN.
    ENDTRY.

    IF status-code = 200.
      DATA lo_result TYPE REF TO data.
      /ui2/cl_json=>deserialize(
          EXPORTING
              json = lv_response
          CHANGING
              data = lo_result
       ).
      ASSIGN COMPONENT 'd' OF STRUCTURE lo_result->* TO FIELD-SYMBOL(<fo_result>).
      IF sy-subrc = 0.
        ASSIGN COMPONENT 'Plant' OF STRUCTURE <fo_result>->* TO FIELD-SYMBOL(<fs_plant>).
        IF sy-subrc = 0.
          lv_plant = <fs_plant>->*.
        ENDIF.
        ASSIGN COMPONENT 'StorageLocation' OF STRUCTURE <fo_result>->* TO FIELD-SYMBOL(<fs_storage>).
        IF sy-subrc = 0.
          lv_storage = <fs_storage>->*.
        ENDIF.
      ENDIF.


      IF lv_plant = plant AND lv_storage = storagelocation.
        rv_result = abap_true.
      ELSE.
        rv_result = abap_false.
      ENDIF.
*      rv_result = abap_true.
    ELSE.
      rv_result = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD checkstockwithoutsn.
    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
    DATA: lv_plant   TYPE werks_d,
          lv_storage TYPE zzesd003.

    " Find CA by Scenario ID
    lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
    DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
    lo_factory->query_ca(
            EXPORTING
              is_query           = VALUE #( cscn_id_range = lr_cscn )
            IMPORTING
              et_com_arrangement = DATA(lt_ca) ).

    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.

    " take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
    " get destination based on Communication Arrangement and the service ID
    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
                    comm_scenario  = 'YY1_API'
                    service_id     = 'YY1_API_REST'
                    comm_system_id = lo_ca->get_comm_system_id( ) ).

      CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
*              out->write( lx_http_dest_provider_error->get_text( ) ).
        EXIT.
    ENDTRY.

    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

        DATA(lo_request) = lo_http_client->get_http_request(   ).

        lo_http_client->enable_path_prefix( ).

        DATA(lv_uri_path) = |/API_MATERIAL_STOCK_SRV/A_MatlStkInAcctMod?$filter=Material eq '{ material }' and Plant eq '{ plant }' and StorageLocation eq '{ storagelocation }' and InventoryStockType eq '01'|.

        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').


        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).

        DATA(lv_response) = lo_response->get_text(  ).
        DATA(status) = lo_response->get_status( ).
      CATCH cx_web_http_client_error INTO DATA(lX_WEB_HTTP_CLIENT_ERROR).
        RETURN.
    ENDTRY.

    IF status-code = 200.
      DATA lo_result TYPE REF TO data.
      /ui2/cl_json=>deserialize(
          EXPORTING
              json = lv_response
          CHANGING
              data = lo_result
       ).
      ASSIGN COMPONENT 'd' OF STRUCTURE lo_result->* TO FIELD-SYMBOL(<fo_result>).
      IF sy-subrc = 0.
        FIELD-SYMBOLS <ft_result> TYPE ANY  .
        ASSIGN COMPONENT 'results' OF STRUCTURE <fo_result>->* TO <ft_result>.
*        ASSIGN <fo_result>->* TO <ft_result>.
        IF lines( <ft_result>->* ) > 0 .
*          READ TABLE <ft_result> ASSIGNING FIELD-SYMBOL(<fs_stock_line>) INDEX 1.
          LOOP AT <ft_result>->* ASSIGNING FIELD-SYMBOL(<fs_stock_line>).
*          IF sy-subrc = 0.
            ASSIGN COMPONENT 'MatlWrhsStkQtyInMatlBaseUnit' OF STRUCTURE <fs_stock_line>->* TO FIELD-SYMBOL(<fv_stock>).
            IF sy-subrc = 0.
              IF <fv_stock> > quantity.
                rv_result = abap_true.
              ELSE.
                rv_result = abap_false.
              ENDIF.
            ENDIF.
*          ENDIF.
          ENDLOOP.
        ELSE.
          rv_result = abap_false.
        ENDIF.

      ENDIF.


      IF lv_plant = plant AND lv_storage = storagelocation.
        rv_result = abap_true.
      ELSE.
        rv_result = abap_false.
      ENDIF.
    ELSE.
      rv_result = abap_false.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
