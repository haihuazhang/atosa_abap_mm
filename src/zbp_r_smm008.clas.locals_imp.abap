CLASS lhc_ZR_SMM008 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zr_smm008 RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zr_smm008.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zr_smm008.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zr_smm008.

    METHODS read FOR READ
      IMPORTING keys FOR READ zr_smm008 RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zr_smm008.

    METHODS z_creatematerialdocument FOR MODIFY
      IMPORTING keys FOR ACTION zr_smm008~z_creatematerialdocument.

    METHODS z_documentinplant FOR MODIFY
      IMPORTING keys FOR ACTION zr_smm008~z_documentinplant.

*&---跨工厂303 发料
    METHODS z_documentcrossplant FOR MODIFY
      IMPORTING keys FOR ACTION zr_smm008~z_documentcrossplant.

*&---跨工厂305 收货
    METHODS z_documentcrossplantR FOR MODIFY
      IMPORTING keys FOR ACTION zr_smm008~z_documentcrossplantR.

*&---获取物料信息
    METHODS z_MatlStkInAcctMod FOR MODIFY
      IMPORTING keys   FOR ACTION zr_smm008~z_MatlStkInAcctMod
      RESULT    result.

*&---获取序列号信息
    METHODS z_getMatlStkSerial FOR MODIFY
      IMPORTING keys   FOR ACTION zr_smm008~z_getMatlStkSerial
      RESULT    result.

*&---获取预留行信息
    METHODS z_getReservationItem FOR MODIFY
      IMPORTING keys   FOR ACTION zr_smm008~z_getReservationItem
      RESULT    result.

*&---获取物料凭证行信息
    METHODS z_getMatlDocItem FOR MODIFY
      IMPORTING keys   FOR ACTION zr_smm008~z_getMatlDocItem
      RESULT    result.

*&---获取物料凭证行序列号信息
    METHODS z_GetMatDocSerialNumber FOR MODIFY
      IMPORTING keys   FOR ACTION zr_smm008~z_GetMatDocSerialNumber
      RESULT    result.
ENDCLASS.

CLASS lhc_ZR_SMM008 IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

*&---================获取物料凭证行序列号信息
  METHOD z_GetMatDocSerialNumber.
*&---=============================使用API 步骤01
*& 1. api.sap.com 查找对应的API；
*& 2. Overview 中确定Communication Scenario 编号；
*& 3. API Reference 中确定对应的实体路径；
*& 4. 此处为A_MaterialSerialNumber
*& 5. 100 中功能磁贴Communication Arrangements，定义对应的YY1_场景编号,此处为YY1_SAP_COM_0164
*& 6. POSTMAN SELF 账号按API Reference 调用测试，成功后BAS 开发CDS behavior Definitions；
*& 7. action 实现，为本部分接下来内容；
*&---=============================使用API 步骤01
*&---=========1.API 类使用变量
*&---定义场景使用变量
    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
*&---Find CA by Scenario ID
    lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
*&---创建实例
    DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
    lo_factory->query_ca(
            EXPORTING
              is_query           = VALUE #( cscn_id_range = lr_cscn )
            IMPORTING
              et_com_arrangement = DATA(lt_ca) ).

    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.

*&---take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
*&---get destination based on Communication Arrangement and the service ID
    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
                    comm_scenario  = 'YY1_API'
                    service_id     = 'YY1_API_REST'
                    comm_system_id = lo_ca->get_comm_system_id( ) ).
      CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
*              out->write( lx_http_dest_provider_error->get_text( ) ).
        EXIT.
    ENDTRY.

*&---获取行为中key 值
    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

*&---获取行为中数据，JSON -> data【此处为发布OData 输入参数】
    xco_cp_json=>data->from_string( key-%param-jsondata )->apply( VALUE #(
      ( xco_cp_json=>transformation->pascal_case_to_underscore )
      ( xco_cp_json=>transformation->boolean_to_abap_bool )
    ) )->write_to( REF #( zbp_r_smm008=>gs_getMatDocSNIn ) ).
*&---数据格式为结构数据
    DATA(ls_data) = zbp_r_smm008=>gs_getMatDocSNIn.

*&---接口HTTP 链接调用
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).

        " DATA(lv_uri_path) = |/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentItem?$filter=MaterialDocument eq '{ ls_data-Material_Document }' and InventoryStockType eq '01' |.
        DATA(lv_srv) = '/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentItem(MaterialDocumentYear='.
        DATA(lv_uri_path) = | { lv_srv }'{ ls_data-Material_Document_Year }',MaterialDocument='{ ls_data-Material_Document }',MaterialDocumentItem='{ ls_data-Material_Document_Item }')/to_SerialNumbers |.

        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
        lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

        lo_http_client->set_csrf_token(  ).
*&---执行http get 方法
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).
*&---获取http reponse 数据
        DATA(lv_response) = lo_response->get_text(  ).
*&---确定http 状态
        DATA(status) = lo_response->get_status( ).
      CATCH cx_web_http_client_error INTO DATA(lX_WEB_HTTP_CLIENT_ERROR).
        RETURN.
    ENDTRY.
*&---调用成功处理
    IF status-code = 200.
*&---按API 返回值定义返回结构，返回结构->d->results【按API 方式定义使用参数】
      TYPES : BEGIN OF ts_d,
                results TYPE STANDARD TABLE OF zr_smm008_matdocsn WITH DEFAULT KEY,
              END OF ts_d,
              BEGIN OF ts_result,
                d TYPE ts_d,
              END OF ts_result.
      DATA : ls_result TYPE ts_result.

      /ui2/cl_json=>deserialize(
          EXPORTING
              json = lv_response
          CHANGING
              data = ls_result
       ).
      IF ls_result-d-results IS NOT INITIAL.
        DATA: ls_result_action LIKE LINE OF result.
        SORT ls_result-d-results  BY MaterialDocumentYear MaterialDocument MaterialDocumentItem.
        LOOP AT ls_result-d-results INTO DATA(ls_result_data).
          ls_result_action-%cid   = keys[ 1 ]-%cid.
          ls_result_action-%param = VALUE #(
            MaterialDocumentYear         = ls_result_data-MaterialDocumentYear
            MaterialDocument             = ls_result_data-MaterialDocument
            MaterialDocumentItem         = ls_result_data-MaterialDocumentItem
            Material                     = ls_result_data-Material
            SerialNumber                 = ls_result_data-SerialNumber
          ).
          APPEND ls_result_action TO result.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.
*&---================获取物料凭证行信息
  METHOD z_getMatlDocItem.
*&---=============================使用API 步骤01
*& 1. api.sap.com 查找对应的API；
*& 2. Overview 中确定Communication Scenario 编号；
*& 3. API Reference 中确定对应的实体路径；
*& 4. 此处为A_MaterialSerialNumber
*& 5. 100 中功能磁贴Communication Arrangements，定义对应的YY1_场景编号,此处为YY1_SAP_COM_0164
*& 6. POSTMAN SELF 账号按API Reference 调用测试，成功后BAS 开发CDS behavior Definitions；
*& 7. action 实现，为本部分接下来内容；
*&---=============================使用API 步骤01
*&---=========1.API 类使用变量
*&---定义场景使用变量
    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
*&---Find CA by Scenario ID
    lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
*&---创建实例
    DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
    lo_factory->query_ca(
            EXPORTING
              is_query           = VALUE #( cscn_id_range = lr_cscn )
            IMPORTING
              et_com_arrangement = DATA(lt_ca) ).

    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.

*&---take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
*&---get destination based on Communication Arrangement and the service ID
    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
                    comm_scenario  = 'YY1_API'
                    service_id     = 'YY1_API_REST'
                    comm_system_id = lo_ca->get_comm_system_id( ) ).
      CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
*              out->write( lx_http_dest_provider_error->get_text( ) ).
        EXIT.
    ENDTRY.

*&---获取行为中key 值
    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

*&---获取行为中数据，JSON -> data【此处为发布OData 输入参数】
    xco_cp_json=>data->from_string( key-%param-jsondata )->apply( VALUE #(
      ( xco_cp_json=>transformation->pascal_case_to_underscore )
      ( xco_cp_json=>transformation->boolean_to_abap_bool )
    ) )->write_to( REF #( zbp_r_smm008=>ty_getMatlDocItemIn ) ).
*&---数据格式为结构数据
    DATA(ls_data) = zbp_r_smm008=>ty_getMatlDocItemIn.

*&---接口HTTP 链接调用
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).

        DATA(lv_uri_path) = |/API_MATERIAL_DOCUMENT_SRV/A_MaterialDocumentItem?$filter=MaterialDocument eq '{ ls_data-Material_Document }' and InventoryStockType eq '01' |.

        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
        lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

        lo_http_client->set_csrf_token(  ).
*&---执行http get 方法
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).
*&---获取http reponse 数据
        DATA(lv_response) = lo_response->get_text(  ).
*&---确定http 状态
        DATA(status) = lo_response->get_status( ).
      CATCH cx_web_http_client_error INTO DATA(lX_WEB_HTTP_CLIENT_ERROR).
        RETURN.
    ENDTRY.
*&---调用成功处理
    IF status-code = 200.
*&---按API 返回值定义返回结构，返回结构->d->results【按API 方式定义使用参数】
      TYPES : BEGIN OF ts_results,
                Reservation                    TYPE c LENGTH 30,
                ReservationItem                TYPE c LENGTH 30,
                Product                        TYPE c LENGTH 18,
                ResvnItmRequiredQtyInBaseUnit  TYPE c LENGTH 30,
                ResvnItmWithdrawnQtyInBaseUnit TYPE c LENGTH 30,
                BaseUnit                       TYPE meins,
                Plant                          TYPE werks_d,
                StorageLocation                TYPE c LENGTH 4,
                GoodsMovementType              TYPE c LENGTH 3,
              END OF ts_results,
              BEGIN OF ts_d,
                results TYPE STANDARD TABLE OF zr_smm008_matdoc WITH DEFAULT KEY,
              END OF ts_d,
              BEGIN OF ts_result,
                d TYPE ts_d,
              END OF ts_result.
      DATA : ls_result TYPE ts_result.

      /ui2/cl_json=>deserialize(
          EXPORTING
              json = lv_response
          CHANGING
              data = ls_result
       ).
      IF ls_result-d-results IS NOT INITIAL.
        SELECT unitofmeasure,
               unitofmeasure_e
          FROM i_unitofmeasure
           FOR ALL ENTRIES IN @ls_result-d-results
         WHERE unitofmeasure_e = @ls_result-d-results-MaterialBaseUnit
          INTO TABLE @DATA(lt_unit).
        SORT lt_unit BY unitofmeasure_e.
        DATA: ls_result_action LIKE LINE OF result.
        SORT ls_result-d-results  BY MaterialDocumentYear MaterialDocument MaterialDocumentItem.
        LOOP AT ls_result-d-results INTO DATA(ls_result_data).
          READ TABLE lt_unit INTO DATA(ls_unit) WITH KEY unitofmeasure_e = ls_result_data-MaterialBaseUnit BINARY SEARCH.
          ls_result_action-%cid   = keys[ 1 ]-%cid.
          ls_result_action-%param = VALUE #(
            MaterialDocumentYear         = ls_result_data-MaterialDocumentYear
            MaterialDocument             = ls_result_data-MaterialDocument
            MaterialDocumentItem         = ls_result_data-MaterialDocumentItem
            Material                     = ls_result_data-Material
            Plant                        = ls_result_data-Plant
            StorageLocation              = ls_result_data-StorageLocation
            IssuingOrReceivingPlant      = ls_result_data-IssuingOrReceivingPlant
            IssuingOrReceivingStorageLoc = ls_result_data-IssuingOrReceivingStorageLoc
            QuantityInBaseUnit           = ls_result_data-QuantityInBaseUnit
            MaterialBaseUnit             = ls_unit-unitofmeasure
          ).
          APPEND ls_result_action TO result.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDMETHOD.
*&---================获取序列号库存信息
  METHOD z_getReservationItem.
*&---=============================使用API 步骤01
*& 1. api.sap.com 查找对应的API；
*& 2. Overview 中确定Communication Scenario 编号；
*& 3. API Reference 中确定对应的实体路径；
*& 4. 此处为A_MaterialSerialNumber
*& 5. 100 中功能磁贴Communication Arrangements，定义对应的YY1_场景编号,此处为YY1_SAP_COM_0164
*& 6. POSTMAN SELF 账号按API Reference 调用测试，成功后BAS 开发CDS behavior Definitions；
*& 7. action 实现，为本部分接下来内容；
*&---=============================使用API 步骤01
*&---=========1.API 类使用变量
*&---定义场景使用变量
    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
*&---Find CA by Scenario ID
    lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
*&---创建实例
    DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
    lo_factory->query_ca(
            EXPORTING
              is_query           = VALUE #( cscn_id_range = lr_cscn )
            IMPORTING
              et_com_arrangement = DATA(lt_ca) ).

    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.

*&---take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
*&---get destination based on Communication Arrangement and the service ID
    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
                    comm_scenario  = 'YY1_API'
                    service_id     = 'YY1_API_REST'
                    comm_system_id = lo_ca->get_comm_system_id( ) ).
      CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
*              out->write( lx_http_dest_provider_error->get_text( ) ).
        EXIT.
    ENDTRY.

*&---获取行为中key 值
    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

*&---获取行为中数据，JSON -> data【此处为发布OData 输入参数】
    xco_cp_json=>data->from_string( key-%param-jsondata )->apply( VALUE #(
      ( xco_cp_json=>transformation->pascal_case_to_underscore )
      ( xco_cp_json=>transformation->boolean_to_abap_bool )
    ) )->write_to( REF #( zbp_r_smm008=>ty_getReservationItemIn ) ).
*&---数据格式为结构数据
    DATA(ls_data) = zbp_r_smm008=>ty_getReservationItemIn.

*&---接口HTTP 链接调用
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).

        DATA(lv_uri_path) = |/API_RESERVATION_DOCUMENT_SRV/A_ReservationDocumentHeader('{ ls_data-Reversion_No }')/to_ReservationDocumentItem|.

        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
        lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

        lo_http_client->set_csrf_token(  ).
*&---执行http get 方法
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).
*&---获取http reponse 数据
        DATA(lv_response) = lo_response->get_text(  ).
*&---确定http 状态
        DATA(status) = lo_response->get_status( ).
      CATCH cx_web_http_client_error INTO DATA(lX_WEB_HTTP_CLIENT_ERROR).
        RETURN.
    ENDTRY.
*&---调用成功处理
    IF status-code = 200.
*&---按API 返回值定义返回结构，返回结构->d->results【按API 方式定义使用参数】
      TYPES : BEGIN OF ts_results,
                Reservation                    TYPE c LENGTH 30,
                ReservationItem                TYPE  c LENGTH 30,
                Product                        TYPE matnr,
                ResvnItmRequiredQtyInBaseUnit  TYPE c LENGTH 30,
                ResvnItmWithdrawnQtyInBaseUnit TYPE c LENGTH 30,
                BaseUnit                       TYPE meins,
                Plant                          TYPE werks_d,
                StorageLocation                TYPE c LENGTH 4,
                GoodsMovementType              TYPE c LENGTH 3,
              END OF ts_results,
              BEGIN OF ts_d,
                results TYPE STANDARD TABLE OF ts_results WITH DEFAULT KEY,
              END OF ts_d,
              BEGIN OF ts_result,
                d TYPE ts_d,
              END OF ts_result.
      DATA : ls_result TYPE ts_result.

      /ui2/cl_json=>deserialize(
          EXPORTING
              json = lv_response
          CHANGING
              data = ls_result
       ).
      IF ls_result-d-results IS NOT INITIAL.
        SELECT unitofmeasure,
               unitofmeasure_e
          FROM i_unitofmeasure
           FOR ALL ENTRIES IN @ls_result-d-results
         WHERE unitofmeasure_e = @ls_result-d-results-BaseUnit
          INTO TABLE @DATA(lt_unit).
        SORT lt_unit BY unitofmeasure_e.
        DATA: ls_result_action LIKE LINE OF result.
        LOOP AT ls_result-d-results INTO DATA(ls_result_data).
          READ TABLE lt_unit INTO DATA(ls_unit) WITH KEY unitofmeasure_e = ls_result_data-BaseUnit BINARY SEARCH.
          ls_result_action-%cid   = keys[ 1 ]-%cid.
          ls_result_action-%param = VALUE #(
          Reservation                   = ls_result_data-Reservation
          ReservationItem               =  ls_result_data-ReservationItem
          Product                       = ls_result_data-Product
          ResvnItmRequiredQtyInBaseUnit =  ls_result_data-ResvnItmRequiredQtyInBaseUnit
          BaseUnit                      =  ls_unit-unitofmeasure
          Plant                         =  ls_result_data-Plant
          StorageLocation               =  ls_result_data-StorageLocation
          GoodsMovementType             =  ls_result_data-GoodsMovementType
          ).
          APPEND ls_result_action TO result.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDMETHOD.

*&---================获取序列号库存信息
  METHOD z_getMatlStkSerial.
*&---=============================使用API 步骤01
*& 1. api.sap.com 查找对应的API；
*& 2. Overview 中确定Communication Scenario 编号；
*& 3. API Reference 中确定对应的实体路径；
*& 4. 此处为A_MaterialSerialNumber
*& 5. 100 中功能磁贴Communication Arrangements，定义对应的YY1_场景编号,此处为YY1_SAP_COM_0164
*& 6. POSTMAN SELF 账号按API Reference 调用测试，成功后BAS 开发CDS behavior Definitions；
*& 7. action 实现，为本部分接下来内容；
*&---=============================使用API 步骤01
*&---=========1.API 类使用变量
*&---定义场景使用变量
    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
*&---Find CA by Scenario ID
    lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'YY1_API' ) ).
*&---创建实例
    DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
    lo_factory->query_ca(
            EXPORTING
              is_query           = VALUE #( cscn_id_range = lr_cscn )
            IMPORTING
              et_com_arrangement = DATA(lt_ca) ).

    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.

*&---take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.
*&---get destination based on Communication Arrangement and the service ID
    TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
                    comm_scenario  = 'YY1_API'
                    service_id     = 'YY1_API_REST'
                    comm_system_id = lo_ca->get_comm_system_id( ) ).
      CATCH cx_http_dest_provider_error INTO DATA(lx_http_dest_provider_error).
*              out->write( lx_http_dest_provider_error->get_text( ) ).
        EXIT.
    ENDTRY.

*&---获取行为中key 值
    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

*&---获取行为中数据，JSON -> data【此处为发布OData 输入参数】
    xco_cp_json=>data->from_string( key-%param-jsondata )->apply( VALUE #(
      ( xco_cp_json=>transformation->pascal_case_to_underscore )
      ( xco_cp_json=>transformation->boolean_to_abap_bool )
    ) )->write_to( REF #( zbp_r_smm008=>ty_getMatlStkSerialIn ) ).
*&---数据格式为结构数据
    DATA(ls_data) = zbp_r_smm008=>ty_getMatlStkSerialIn.

*&---接口HTTP 链接调用
    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
        DATA(lo_request) = lo_http_client->get_http_request(   ).
        lo_http_client->enable_path_prefix( ).

        DATA(lv_uri_path) = |/API_MATERIAL_STOCK_SRV/A_MaterialSerialNumber?$filter=SerialNumber eq '{ ls_data-Serial_Number }'|.

        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
        lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

        lo_http_client->set_csrf_token(  ).
*&---执行http get 方法
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).
*&---获取http reponse 数据
        DATA(lv_response) = lo_response->get_text(  ).
*&---确定http 状态
        DATA(status) = lo_response->get_status( ).
      CATCH cx_web_http_client_error INTO DATA(lX_WEB_HTTP_CLIENT_ERROR).
        RETURN.
    ENDTRY.
*&---调用成功处理
    IF status-code = 200.
*&---按API 返回值定义返回结构，返回结构->d->results【按API 方式定义使用参数】
      TYPES : BEGIN OF ts_results,
                Plant                        TYPE werks_d,
                StorageLocation              TYPE zzemm006,
                Material                     TYPE matnr,
                SerialNumber                 TYPE zzemm008,
                InventoryStockType           TYPE c LENGTH 2,
                MatlWrhsStkQtyInMatlBaseUnit TYPE menge_d,
                MaterialBaseUnit             TYPE meins,
              END OF ts_results,
              BEGIN OF ts_d,
                results TYPE STANDARD TABLE OF ts_results WITH DEFAULT KEY,
              END OF ts_d,
              BEGIN OF ts_result,
                d TYPE ts_d,
              END OF ts_result.
      DATA : ls_result TYPE ts_result.

      /ui2/cl_json=>deserialize(
          EXPORTING
              json = lv_response
          CHANGING
              data = ls_result
       ).
      IF ls_result-d-results IS NOT INITIAL.
*        SELECT unitofmeasure,
*               unitofmeasure_e
*          FROM i_unitofmeasure
*           FOR ALL ENTRIES IN @ls_result-d-results
*         WHERE unitofmeasure_e = @ls_result-d-results-MaterialBaseUnit
*          INTO TABLE @DATA(lt_unit).
        SELECT product,
               baseunit AS unitofmeasure
          FROM i_product
          FOR ALL ENTRIES IN @ls_result-d-results
        WHERE product = @ls_result-d-results-Material
         INTO TABLE @DATA(lt_unit).
        SORT lt_unit BY product.
        DATA: ls_result_action LIKE LINE OF result.
        LOOP AT ls_result-d-results INTO DATA(ls_result_data).
          READ TABLE lt_unit INTO DATA(ls_unit) WITH KEY product = ls_result_data-Material BINARY SEARCH.
          ls_result_action-%cid = keys[ 1 ]-%cid.
          ls_result_action-%param = VALUE #(
          plant = ls_result_data-plant
          StorageLocation =  ls_result_data-StorageLocation
          SerialNumber = ls_result_data-SerialNumber
          Material =  ls_result_data-Material
          InventoryStockType = ls_result_data-InventoryStockType
          MaterialBaseUnit =  ls_unit-unitofmeasure
          ).
          APPEND ls_result_action TO result.
        ENDLOOP.
      ENDIF.
    ENDIF.

  ENDMETHOD.
*&---获取物料库存信息
  METHOD z_MatlStkInAcctMod.

    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.

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

    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " JSON -> data
    xco_cp_json=>data->from_string( key-%param-jsondata )->apply( VALUE #(
      ( xco_cp_json=>transformation->pascal_case_to_underscore )
      ( xco_cp_json=>transformation->boolean_to_abap_bool )
    ) )->write_to( REF #( zbp_r_smm008=>gs_MatlStk ) ).

    DATA(ls_data) = zbp_r_smm008=>gs_MatlStk.

    TRY.
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

        DATA(lo_request) = lo_http_client->get_http_request(   ).

        lo_http_client->enable_path_prefix( ).

        "  DATA(lv_uri_path) = |/API_MATERIAL_STOCK_SRV/A_MatlStkInAcctMod?$filter=Plant eq '{ ls_data-Plant }'and StorageLocation eq '{ ls_data-Storage }'and Material eq '{ ls_data-Material }')|.



        DATA(lv_uri_path) = |/API_MATERIAL_STOCK_SRV/A_MatlStkInAcctMod?$filter=Material eq '{ ls_data-Material }' and Plant eq '{ ls_data-Plant }' and StorageLocation eq '{ ls_data-Storage }'|.

        lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
        lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
        lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).

        lo_http_client->set_csrf_token(  ).

        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).

        DATA(lv_response) = lo_response->get_text(  ).
        DATA(status) = lo_response->get_status( ).
      CATCH cx_web_http_client_error INTO DATA(lX_WEB_HTTP_CLIENT_ERROR).
        RETURN.
    ENDTRY.
    IF status-code = 200.
      DATA lo_result TYPE REF TO data.
      TYPES : BEGIN OF ts_results,
                Plant                        TYPE werks_d,
                StorageLocation              TYPE zzemm006,
                Material                     TYPE zzemm009,
                InventoryStockType           TYPE c LENGTH 2,
                MatlWrhsStkQtyInMatlBaseUnit TYPE menge_d,
                MaterialBaseUnit             TYPE meins,
              END OF ts_results,
              BEGIN OF ts_d,
                results TYPE STANDARD TABLE OF ts_results WITH DEFAULT KEY,
              END OF ts_d,
              BEGIN OF ts_result,
                d TYPE ts_d,
              END OF ts_result.
      DATA : ls_result TYPE ts_result.


      /ui2/cl_json=>deserialize(
          EXPORTING
              json = lv_response
          CHANGING
*              data = lo_result
              data = ls_result
       ).
      IF ls_result-d-results IS NOT INITIAL.
        SELECT unitofmeasure,
               unitofmeasure_e
          FROM i_unitofmeasure
           FOR ALL ENTRIES IN @ls_result-d-results
         WHERE unitofmeasure_e = @ls_result-d-results-MaterialBaseUnit
          INTO TABLE @DATA(lt_unit).
        SORT lt_unit BY unitofmeasure_e.
        DATA: ls_result_action LIKE LINE OF result.
        LOOP AT ls_result-d-results INTO DATA(ls_result_data).
          IF ls_result_data-storagelocation <> 'AINS'
            AND ls_result_data-inventorystocktype = '07'.
            CONTINUE.
          ENDIF.
          READ TABLE lt_unit INTO DATA(ls_unit) WITH KEY unitofmeasure_e = ls_result_data-MaterialBaseUnit BINARY SEARCH.
          ls_result_action-%cid = keys[ 1 ]-%cid.
          ls_result_action-%param = VALUE #(
          plant = ls_result_data-plant
          StorageLocation =  ls_result_data-StorageLocation
          Material =  ls_result_data-Material
          InventoryStockType = ls_result_data-InventoryStockType
          MatlWrhsStkQtyInMatlBaseUnit =  ls_result_data-MatlWrhsStkQtyInMatlBaseUnit
          MaterialBaseUnit =  ls_unit-unitofmeasure
          ).
          APPEND ls_result_action TO result.
        ENDLOOP.
      ENDIF.
*      LOOP AT lo_result->*-d->*-results->* INTO DATA(ls_dresult) .
*      ENDLOOP.
*      DATA: ls_result_action LIKE LINE OF result.
*      ls_result_action-%cid = keys[ 1 ]-%cid.
*      ls_result_action-%param = VALUE #(
*          Plant = '1700'
*          Material = 'TG11'
**Plant
**  Storage
**  dest_plant
**  Dest_Storage
**  Material
**  Quntity
**  Base_Unit
*       ).
*      APPEND ls_result_action TO result.
*      APPEND ls_result_action TO result.
    ENDIF.

  ENDMETHOD.

*&---创建物料凭证
  METHOD Z_createMaterialDocument.
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
    ) )->write_to( REF #( zbp_r_smm008=>gs_data ) ).

    DATA(ls_data) = zbp_r_smm008=>gs_data.

    " Get date
    TRY.
        DATA(lv_time_zone) = cl_abap_context_info=>get_user_time_zone( sy-uname ).
        GET TIME STAMP FIELD DATA(lv_timestamp).
        CONVERT TIME STAMP lv_timestamp TIME ZONE lv_time_zone INTO DATE DATA(lv_date).
      CATCH cx_abap_context_info_error.
        lv_date = cl_abap_context_info=>get_system_date( ).
    ENDTRY.

    " material document header
    DATA(lv_headertext) = ls_data-Note.
    ls_material_document_header = VALUE #( %cid = 'My%CID_1'
                                           goodsmovementcode = '03'
                                           postingdate       = lv_date
                                           documentdate      = lv_date
                                           materialdocumentheadertext = lv_headertext ).
    APPEND ls_material_document_header TO lt_material_document_headers.

    " Unit
    IF ls_data-items IS NOT INITIAL.
      SELECT unitofmeasure,
             unitofmeasure_e
        FROM i_unitofmeasure
         FOR ALL ENTRIES IN @ls_data-items
       WHERE unitofmeasure_e = @ls_data-items-base_unit
        INTO TABLE @DATA(lt_unit).
      SORT lt_unit BY unitofmeasure_e.

      " material document item
      SORT ls_data-items BY Reversion_No.
      LOOP AT ls_data-items INTO DATA(ls_item).
        n += 1.

        READ TABLE lt_unit INTO DATA(ls_unit) WITH KEY unitofmeasure_e = ls_item-base_unit BINARY SEARCH.

        ls_material_document_item = VALUE #(
                 %cid_ref = 'My%CID_1'
                 %target  = VALUE #( ( %cid = |My%ItemCID_{ n }|
                                       goodsmovementtype = ls_item-movement_type
                                       material = ls_item-material
                                       plant = ls_item-plant
                                       storagelocation = ls_item-Storage
                                       quantityinentryunit = ls_item-Post_Qty
                                       entryunit = ls_unit-unitofmeasure
                                       Reservation = ls_item-Reversion_No
                                       ReservationItem = ls_item-Item ) ) ).
        APPEND ls_material_document_item TO lt_material_document_items.

        " material document serial number
*        SORT ls_item-serial_numbers BY serial_number.
*        LOOP AT ls_item-serial_numbers INTO DATA(ls_serialnumber).
*          i += 1.
*
*          ls_material_document_sn = VALUE #( %cid_ref = |My%ItemCID_{ n }|
*                                             %target  = VALUE #( ( %cid = |My%SerialCID_{ i }|
*                                                                   serialnumber = ls_serialnumber-serial_number ) ) ) .
*
*          zbp_r_tmm002=>gt_serial_numbers =
*          VALUE #( BASE zbp_r_tmm002=>gt_serial_numbers ( purchase_order      = ls_serialnumber-purchase_order
*                                                          purchase_order_item = ls_serialnumber-purchase_order_item
*                                                          material            = ls_serialnumber-material
*                                                          old_serial_number   = ls_serialnumber-old_serial_number
*                                                          serial_number       = ls_serialnumber-serial_number
*                                                          receipt_date        = lv_date ) ).
*
*          APPEND ls_material_document_sn TO lt_material_document_sns.
*          CLEAR ls_serialnumber.
*        ENDLOOP.
*        CLEAR ls_item.
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
                       Reservation
                       ReservationItem ) WITH lt_material_document_items
*    ENTITY materialdocumentitem
*       CREATE BY \_serialnumber
*              FIELDS ( serialnumber ) WITH lt_material_document_sns
     MAPPED DATA(ls_create_mapped)
     FAILED DATA(ls_create_failed)
     REPORTED DATA(ls_create_reported).

    IF ls_create_failed IS INITIAL.
      " Stored in the global variable
      zbp_r_smm008=>gs_mapped_material_document = ls_create_mapped.
      zbp_r_smm008=>gt_material_document_items = lt_material_document_items.
    ENDIF.

  ENDMETHOD.

  METHOD z_documentinplant.
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
    ) )->write_to( REF #( zbp_r_smm008=>gs_stockinplant ) ).

    DATA(ls_data) = zbp_r_smm008=>gs_stockinplant.

    " Get date
    TRY.
        DATA(lv_time_zone) = cl_abap_context_info=>get_user_time_zone( sy-uname ).
        GET TIME STAMP FIELD DATA(lv_timestamp).
        CONVERT TIME STAMP lv_timestamp TIME ZONE lv_time_zone INTO DATE DATA(lv_date).
      CATCH cx_abap_context_info_error.
        lv_date = cl_abap_context_info=>get_system_date( ).
    ENDTRY.

    " material document header
    DATA(lv_headertext) = ''."ls_data-Note.
    ls_material_document_header = VALUE #( %cid                       = 'My%CID_1'
                                           goodsmovementcode          = '04'
                                           postingdate                = lv_date
                                           documentdate               = lv_date
                                           materialdocumentheadertext = lv_headertext ).
    APPEND ls_material_document_header TO lt_material_document_headers.

    " Unit
    IF ls_data-items IS NOT INITIAL.
      SELECT unitofmeasure,
             unitofmeasure_e
        FROM i_unitofmeasure
         FOR ALL ENTRIES IN @ls_data-items
       WHERE unitofmeasure_e = @ls_data-items-Base_Unit
        INTO TABLE @DATA(lt_unit).
      SORT lt_unit BY unitofmeasure_e.

      " material document item
      SORT ls_data-items BY plant storage Material serial_number.
      DATA:lt_items_matdoc    LIKE ls_data-items,
           lt_items_matdoc_SN LIKE ls_data-items,
           ls_items           LIKE LINE OF ls_data-items,
           ls_items_matdoc    LIKE LINE OF ls_data-items,
           ls_items_matdoc_sn LIKE LINE OF ls_data-items.
      LOOP AT ls_data-items INTO ls_items.
        IF ls_items-serial_number IS INITIAL.
          APPEND ls_items TO lt_items_matdoc.
        ELSE.
          READ TABLE lt_items_matdoc ASSIGNING FIELD-SYMBOL(<lfs_items_matdoc>)  WITH KEY plant    = ls_items-plant
                                                                                          storage  = ls_items-storage
                                                                                          material = ls_items-material.
          IF sy-subrc = 0.
            APPEND ls_items TO lt_items_matdoc_SN.
            <lfs_items_matdoc>-transfer_qty = <lfs_items_matdoc>-transfer_qty + 1.
          ELSE.
            APPEND ls_items TO lt_items_matdoc_SN.
            ls_items-serial_number = ''.
            ls_items-flag          = 'X'.
            APPEND ls_items TO lt_items_matdoc.
          ENDIF.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_items_matdoc INTO DATA(ls_item).
        n += 1.

        READ TABLE lt_unit INTO DATA(ls_unit) WITH KEY unitofmeasure_e = ls_item-Base_Unit BINARY SEARCH.
        DATA:lv_movetype TYPE c LENGTH 3.
        IF ls_item-Inventory_Stock_Type = '01'.
          lv_movetype = '311'.
        ELSEIF ls_item-Inventory_Stock_Type = '02'.
          lv_movetype = '321'.
        ELSEIF ls_item-Inventory_Stock_Type = '07'.
          lv_movetype = '343'.
        ENDIF.
        ls_material_document_item = VALUE #(
                 %cid_ref = 'My%CID_1'
                 %target  = VALUE #( ( %cid = |My%ItemCID_{ n }|
                                       goodsmovementtype = lv_movetype "'311'
                                       material = ls_item-material
                                       plant = ls_item-plant
                                       storagelocation = ls_item-Storage
                                       IssuingOrReceivingPlant = ls_item-plant
                                       IssuingOrReceivingStorageLoc = ls_item-dest_storage
                                       quantityinentryunit = ls_item-transfer_qty
                                       entryunit = ls_unit-unitofmeasure "'ST'  "ls_item-Base_Unit
                                       ) ) ).
        APPEND ls_material_document_item TO lt_material_document_items.

        LOOP AT lt_items_matdoc_SN INTO ls_items_matdoc_sn WHERE plant = ls_item-plant
                                                             AND storage = ls_item-storage
                                                             AND material = ls_item-material.
          i = i + 1.
          ls_material_document_sn = VALUE #( %cid_ref = |My%ItemCID_{ n }|
                                             %target  = VALUE #( ( %cid = |My%SerialCID_{ i }|
                                                              serialnumber = ls_items_matdoc_sn-serial_number ) ) ) .
          APPEND ls_material_document_sn TO lt_material_document_sns.
        ENDLOOP..
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
                       IssuingOrReceivingPlant
                       IssuingOrReceivingStorageLoc
                       quantityinentryunit
                       entryunit
                       goodsmovementrefdoctype
                       ) WITH lt_material_document_items
       ENTITY materialdocumentitem
       CREATE BY \_serialnumber
              FIELDS ( serialnumber ) WITH lt_material_document_sns
     MAPPED DATA(ls_create_mapped)
     FAILED DATA(ls_create_failed)
     REPORTED DATA(ls_create_reported).

    IF ls_create_failed IS INITIAL.
      " Stored in the global variable
      zbp_r_smm008=>gs_mapped_material_document = ls_create_mapped.
      zbp_r_smm008=>gt_material_document_items = lt_material_document_items.
    ENDIF.

  ENDMETHOD.

  METHOD z_documentcrossplant.
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
    ) )->write_to( REF #( zbp_r_smm008=>gs_stockinplant ) ).

    DATA(ls_data) = zbp_r_smm008=>gs_stockinplant.

    " Get date
    TRY.
        DATA(lv_time_zone) = cl_abap_context_info=>get_user_time_zone( sy-uname ).
        GET TIME STAMP FIELD DATA(lv_timestamp).
        CONVERT TIME STAMP lv_timestamp TIME ZONE lv_time_zone INTO DATE DATA(lv_date).
      CATCH cx_abap_context_info_error.
        lv_date = cl_abap_context_info=>get_system_date( ).
    ENDTRY.

    " material document header
    DATA(lv_headertext) = ''."ls_data-Note.
    ls_material_document_header = VALUE #( %cid                       = 'My%CID_1'
                                           goodsmovementcode          = '04'
                                           postingdate                = lv_date
                                           documentdate               = lv_date
                                           materialdocumentheadertext = lv_headertext ).
    APPEND ls_material_document_header TO lt_material_document_headers.

    " Unit
    IF ls_data-items IS NOT INITIAL.
      SELECT unitofmeasure,
             unitofmeasure_e
        FROM i_unitofmeasure
         FOR ALL ENTRIES IN @ls_data-items
       WHERE unitofmeasure_e = @ls_data-items-Base_Unit
        INTO TABLE @DATA(lt_unit).
      SORT lt_unit BY unitofmeasure_e.

      " material document item
      SORT ls_data-items BY plant storage Material serial_number.
      DATA:lt_items_matdoc    LIKE ls_data-items,
           lt_items_matdoc_SN LIKE ls_data-items,
           ls_items           LIKE LINE OF ls_data-items,
           ls_items_matdoc    LIKE LINE OF ls_data-items,
           ls_items_matdoc_sn LIKE LINE OF ls_data-items.
      LOOP AT ls_data-items INTO ls_items.
        IF ls_items-serial_number IS INITIAL.
          APPEND ls_items TO lt_items_matdoc.
        ELSE.
          READ TABLE lt_items_matdoc ASSIGNING FIELD-SYMBOL(<lfs_items_matdoc>)  WITH KEY plant    = ls_items-plant
                                                                                          storage  = ls_items-storage
                                                                                          material = ls_items-material.
          IF sy-subrc = 0.
            APPEND ls_items TO lt_items_matdoc_SN.
            <lfs_items_matdoc>-transfer_qty = <lfs_items_matdoc>-transfer_qty + 1.
          ELSE.
            APPEND ls_items TO lt_items_matdoc_SN.
            ls_items-serial_number = ''.
            ls_items-flag          = 'X'.
            APPEND ls_items TO lt_items_matdoc.
          ENDIF.
        ENDIF.
      ENDLOOP.
      LOOP AT lt_items_matdoc INTO DATA(ls_item).
        n += 1.

        READ TABLE lt_unit INTO DATA(ls_unit) WITH KEY unitofmeasure_e = ls_item-Base_Unit BINARY SEARCH.

        ls_material_document_item = VALUE #(
                 %cid_ref = 'My%CID_1'
                 %target  = VALUE #( ( %cid = |My%ItemCID_{ n }|
                                       goodsmovementtype = '303'
                                       material = ls_item-material
                                       plant = ls_item-plant
                                       storagelocation = ls_item-Storage
                                       IssuingOrReceivingPlant = ls_item-dest_plant
                                       IssuingOrReceivingStorageLoc = ls_item-dest_storage
                                       quantityinentryunit = ls_item-transfer_qty
                                       entryunit = ls_unit-unitofmeasure "'ST'  "ls_item-Base_Unit
                                       ) ) ).
        APPEND ls_material_document_item TO lt_material_document_items.

        LOOP AT lt_items_matdoc_SN INTO ls_items_matdoc_sn WHERE plant = ls_item-plant
                                                             AND storage = ls_item-storage
                                                             AND material = ls_item-material.
          i = i + 1.
          ls_material_document_sn = VALUE #( %cid_ref = |My%ItemCID_{ n }|
                                             %target  = VALUE #( ( %cid = |My%SerialCID_{ i }|
                                                              serialnumber = ls_items_matdoc_sn-serial_number ) ) ) .
          APPEND ls_material_document_sn TO lt_material_document_sns.
        ENDLOOP..
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
                       IssuingOrReceivingPlant
                       IssuingOrReceivingStorageLoc
                       quantityinentryunit
                       entryunit
                       goodsmovementrefdoctype
                       ) WITH lt_material_document_items
       ENTITY materialdocumentitem
       CREATE BY \_serialnumber
              FIELDS ( serialnumber ) WITH lt_material_document_sns
     MAPPED DATA(ls_create_mapped)
     FAILED DATA(ls_create_failed)
     REPORTED DATA(ls_create_reported).

    IF ls_create_failed IS INITIAL.
      " Stored in the global variable
      zbp_r_smm008=>gs_mapped_material_document = ls_create_mapped.
      zbp_r_smm008=>gt_material_document_items = lt_material_document_items.
    ENDIF.

  ENDMETHOD.
*&---================获取序列号库存信息
  METHOD z_documentcrossplantR.
*&---=============================使用API 步骤01
*& 1. api.sap.com 查找对应的API；
*& 2. Overview 中确定Communication Scenario 编号；
*& 3. API Reference 中确定对应的实体路径；
*& 4. 此处为A_MaterialSerialNumber
*& 5. 100 中功能磁贴Communication Arrangements，定义对应的YY1_场景编号,此处为YY1_SAP_COM_0164
*& 6. POSTMAN SELF 账号按API Reference 调用测试，成功后BAS 开发CDS behavior Definitions；
*& 7. action 实现，为本部分接下来内容；
*&---=============================使用API 步骤01
*&---=========1.API 类使用变量
*&---定义场景使用变量
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
    ) )->write_to( REF #( zbp_r_smm008=>gs_stockcrossplantR ) ).

    DATA(ls_data) = zbp_r_smm008=>gs_stockcrossplantR.

    " Get date
    TRY.
        DATA(lv_time_zone) = cl_abap_context_info=>get_user_time_zone( sy-uname ).
        GET TIME STAMP FIELD DATA(lv_timestamp).
        CONVERT TIME STAMP lv_timestamp TIME ZONE lv_time_zone INTO DATE DATA(lv_date).
      CATCH cx_abap_context_info_error.
        lv_date = cl_abap_context_info=>get_system_date( ).
    ENDTRY.

    " material document header
    DATA(lv_headertext) = ''."ls_data-Note.
    ls_material_document_header = VALUE #( %cid                       = 'My%CID_1'
                                           goodsmovementcode          = '04'
                                           postingdate                = lv_date
                                           documentdate               = lv_date
                                           materialdocumentheadertext = lv_headertext ).
    APPEND ls_material_document_header TO lt_material_document_headers.

*&---凭证行处理，若凭证行一致则合并
    IF ls_data-items IS NOT INITIAL.
*&---内部单位转换
      SELECT unitofmeasure,
             unitofmeasure_e
        FROM i_unitofmeasure
         FOR ALL ENTRIES IN @ls_data-items
       WHERE unitofmeasure_e = @ls_data-items-Material_Base_Unit
        INTO TABLE @DATA(lt_unit).
      SORT lt_unit BY unitofmeasure_e.

*&---物料凭证行处理
      SORT ls_data-items BY Material_Document_Year Material_Document Material_Document_Item.
      DATA:lt_items_matdoc    LIKE ls_data-items,
           lt_items_matdoc_SN LIKE ls_data-items,
           ls_items           LIKE LINE OF ls_data-items,
           ls_items_matdoc    LIKE LINE OF ls_data-items,
           ls_items_matdoc_sn LIKE LINE OF ls_data-items.

*&---接受所有数据，只处理Success 确认数据
      LOOP AT ls_data-items INTO ls_items WHERE flag = 'Success'.
*&---若凭证行处理
        READ TABLE lt_items_matdoc ASSIGNING FIELD-SYMBOL(<lfs_items_matdoc>)  WITH KEY Material_Document_Year = ls_items-Material_Document_Year
                                                                                                  Material_Document      = ls_items-Material_Document
                                                                                                  Material_Document_Item = ls_items-Material_Document_Item.
        " 若存在，则合并数量
        IF sy-subrc = 0.
          <lfs_items_matdoc>-transfer_qty = <lfs_items_matdoc>-transfer_qty + ls_items-transfer_qty.
          " 若不存在，则插入新行
        ELSE.
          APPEND ls_items TO lt_items_matdoc.
        ENDIF.
      ENDLOOP.

*&---实体数据处理
      LOOP AT lt_items_matdoc INTO DATA(ls_item).
*&---n,行cid 处理；
        n += 1.
*&---单位转换
        READ TABLE lt_unit INTO DATA(ls_unit) WITH KEY unitofmeasure_e = ls_item-Material_Base_Unit BINARY SEARCH.
*&---实体凭证行填充
        " 若收货库存地点为空则默认AREG
        IF ls_item-Receiving_Storage_Loc IS INITIAL.
          ls_item-Receiving_Storage_Loc = 'AREG'.
        ENDIF.
        ls_material_document_item = VALUE #(
                 %cid_ref = 'My%CID_1'
                 %target  = VALUE #( ( %cid = |My%ItemCID_{ n }|
                                       goodsmovementtype = '305'
                                       material = ls_item-material
                                       plant = ls_item-Receiving_Plant
                                       storagelocation = ls_item-Receiving_Storage_Loc
                                       IssuingOrReceivingPlant = ls_item-plant
                                       IssuingOrReceivingStorageLoc = ls_item-storage_location
                                       quantityinentryunit = ls_item-transfer_qty
                                       entryunit = ls_unit-unitofmeasure
                                       ) ) ).
        APPEND ls_material_document_item TO lt_material_document_items.

*&---实体凭证行下序列号表填充
        LOOP AT ls_item-serial_number_list INTO DATA(ls_snlist) WHERE flag = 'Success'.
*&---i,行cid 处理；
          i = i + 1.
          ls_material_document_sn = VALUE #( %cid_ref = |My%ItemCID_{ n }|
                                             %target  = VALUE #( ( %cid = |My%SerialCID_{ i }|
                                                              serialnumber = ls_snlist-serial_number ) ) ) .
          APPEND ls_material_document_sn TO lt_material_document_sns.
        ENDLOOP..
      ENDLOOP.
    ENDIF.

*&---Create Material Document（Call Business Object Interfaces）
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
                       IssuingOrReceivingPlant
                       IssuingOrReceivingStorageLoc
                       quantityinentryunit
                       entryunit
                       goodsmovementrefdoctype
                       ) WITH lt_material_document_items
       ENTITY materialdocumentitem
       CREATE BY \_serialnumber
              FIELDS ( serialnumber ) WITH lt_material_document_sns
     MAPPED DATA(ls_create_mapped)
     FAILED DATA(ls_create_failed)
     REPORTED DATA(ls_create_reported).

    IF ls_create_failed IS INITIAL.
      " Stored in the global variable
      zbp_r_smm008=>gs_mapped_material_document = ls_create_mapped.
      zbp_r_smm008=>gt_material_document_items = lt_material_document_items.
    ENDIF.

  ENDMETHOD.
ENDCLASS.

CLASS lsc_ZR_SMM008 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_ZR_SMM008 IMPLEMENTATION.

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
