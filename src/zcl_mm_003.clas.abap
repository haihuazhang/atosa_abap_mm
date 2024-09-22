CLASS zcl_mm_003 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
*&---RAP 查询提供者接口
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
*&---获取物料库龄方法
    METHODS get_stockAging IMPORTING io_request  TYPE REF TO if_rap_query_request
                                     io_response TYPE REF TO if_rap_query_response
                           RAISING   cx_rap_query_prov_not_impl
                                     cx_rap_query_provider.
ENDCLASS.



CLASS ZCL_MM_003 IMPLEMENTATION.


  METHOD get_stockAging.
*&---====================1.按照CDS UI 视图组织数据
*&---1.RAP 选择条件，获取对应物料数据；
*&---2.获取数据后判断序列号，若有则取序列号库存及对应的最新凭证，若无则取物料库存及对应的最新凭证；
*&---获取物料库龄方法

    TRY.
*&---定义RAP 查询过滤表数据
        TYPES:BEGIN OF ty_itab,
                plant              TYPE I_ProductPlantBasic-Plant,
                StorageLocation    TYPE I_ProductStorageLocationBasic-StorageLocation,
                ProductType        TYPE i_product-ProductType,
                InventoryStockType TYPE I_MaterialStock_2-InventoryStockType,
                productgroup       TYPE i_product-ProductGroup,
                baseunit           TYPE I_ProductPlantBasic-BaseUnit,
                AuthorizationGroup TYPE I_Product-AuthorizationGroup,
                product            TYPE I_ProductPlantBasic-Product,
                SerialNumber       TYPE I_Equipment-SerialNumber,
              END OF ty_itab.

        DATA:gt_itab TYPE TABLE OF ty_itab,
             gs_itab TYPE ty_itab.

        TYPES:BEGIN OF ty_api_result,
                product            TYPE I_ProductPlantBasic-Product,
                plant              TYPE I_ProductPlantBasic-Plant,
                storagelocation    TYPE I_ProductStorageLocationBasic-StorageLocation,
                quantity           TYPE zr_smm010-Quantity,
                InventoryStockType TYPE zr_smm010-InventoryStockType,
                SerialNumber       TYPE zr_smm010-SerialNumber,
              END OF ty_api_result.

        DATA:gt_api_result TYPE TABLE OF ty_api_result,
             gs_api_result TYPE ty_api_result.
*&---定义变量
        DATA:lr_plant       TYPE RANGE OF werks_d,  " 工厂
             lr_material    TYPE RANGE OF matnr,    " 物料
             lr_producttype TYPE RANGE OF werks_d,  " 物料类型
             lr_serialn     TYPE RANGE OF zzesd006. " 序列号
        DATA: lt_results TYPE TABLE OF zr_smm010,
              ls_results TYPE zr_smm010.
        DATA(lo_filter)  = io_request->get_filter(  ).     " CDS VIEW ENTITY 选择屏幕过滤器
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).   " ABAP range

*&---过滤器处理
        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'MATERIAL'.
              lr_material    = CORRESPONDING #( ls_filter-range ).
            WHEN 'PLANT'.
              lr_plant       = CORRESPONDING #( ls_filter-range ).
            WHEN 'SERIALlNUMBER'.
              lr_serialn     = CORRESPONDING #( ls_filter-range ).
            WHEN 'PRODUCTTYPE'.
              lr_PRODUCTTYPE = CORRESPONDING #( ls_filter-range ).
          ENDCASE.
        ENDLOOP.
*&---获取RAP 查询条件数据
        IF lr_serialn IS INITIAL.
*&---无序列号查询
          SELECT a~plant  ,                                     " 工厂
                 b~StorageLocation,                             " 库存地点
                 a~\_Product-ProductType,                       " 物料类型
                 a~\_Product-productgroup,                      " 物料组
                 a~BaseUnit,                                    " 物料基本单位
                 a~product,                                     " 物料
                 c~AuthorizationGroup                           " 权限组
            FROM I_ProductPlantBasic AS a
            JOIN I_ProductStorageLocationBasic AS b ON a~plant  = b~Plant
                                                   AND a~Product = b~Product
            JOIN I_Product as c ON a~Product = c~Product

           WHERE a~plant                 IN @lr_plant
             AND a~\_Product-ProductType IN @lr_PRODUCTTYPE
             AND a~product               IN @lr_material
             AND StorageLocation = 'AREG'
            INTO CORRESPONDING FIELDS OF TABLE @gt_itab.
        ELSE.
*&---有序列号查询
          SELECT plant,                                       " 工厂
                 StorageLocation,                             " 库存地点
                 b~producttype,                               " 物料类型
                 b~productgroup,                              " 物料组
                 b~BaseUnit,                                  " 物料基本单位
                 b~AuthorizationGroup,                        " 权限组
                 Material AS product,                         " 物料
                 SerialNumber                                 " 序列号
            FROM I_Equipment AS a
            JOIN I_Product   AS b ON a~Material = b~Product
           WHERE plant        IN @lr_plant
             AND ProductType  IN @lr_PRODUCTTYPE
             AND Material     IN @lr_material
             AND SerialNumber IN @lr_serialn
            INTO CORRESPONDING FIELDS OF TABLE @gt_itab.
        ENDIF.
*&---获取物料描述
        SELECT a~Product,
               ProductName
          FROM @gt_itab AS a
          JOIN I_ProductText AS b ON a~product = b~Product
         WHERE language = @sy-langu
          INTO TABLE @DATA(lt_ProductText).
        SORT lt_ProductText BY product.

*&---===============API 请求【communication arragement 设置完成】
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

*&---获取API 数据
          TRY.
              " 定义http odata 请求
              DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
              " 获取请求类
              DATA(lo_request) = lo_http_client->get_http_request(   ).

              lo_http_client->enable_path_prefix( ).
              " API 查询uri API + FILTER + EXPEND
              DATA(lv_uri_path) = |/API_MATERIAL_STOCK_SRV/A_MatlStkInAcctMod?$expand=to_MaterialSerialNumber|.
              " 设置请求路径
              lo_request->set_uri_path( EXPORTING i_uri_path = lv_uri_path ).
              " 设置请求类型，json 格式
              lo_request->set_header_field( i_name = 'Accept' i_value = 'application/json').
              lo_request->set_header_field( i_name = 'If-Match' i_value = '*' ).
              " 设置 token
              lo_http_client->set_csrf_token(  ).
              " API 方法，get http odata 数据
              DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).
              " API 返回文本值
              DATA(lv_response) = lo_response->get_text(  ).
              " API 返回状态
              DATA(status) = lo_response->get_status( ).
            CATCH cx_web_http_client_error INTO DATA(lX_WEB_HTTP_CLIENT_ERROR).
              RETURN.
          ENDTRY.
          " get 200 正确数据获取
          IF status-code = 200.
            " 返回数据json 数据类型定义
            DATA lo_result TYPE REF TO data.
            TYPES : BEGIN OF ty_serial,
                      SerialNumber TYPE I_SerialNumberMaterialDoc_2-SerialNumber,
                    END OF ty_serial,
                    BEGIN OF ty_res,
                      results TYPE STANDARD TABLE OF ty_serial WITH DEFAULT KEY,
                    END OF ty_res,
                    BEGIN OF ts_results,
                      Plant                        TYPE werks_d,
                      StorageLocation              TYPE zzemm006,
                      Material                     TYPE zzemm009,
                      InventoryStockType           TYPE I_MaterialStock_2-InventoryStockType,
                      MatlWrhsStkQtyInMatlBaseUnit TYPE menge_d,
                      MaterialBaseUnit             TYPE meins,
                      to_MaterialSerialNumber      TYPE ty_res,
                    END OF ts_results,
                    BEGIN OF ts_d,
                      results TYPE STANDARD TABLE OF ts_results WITH DEFAULT KEY,
                    END OF ts_d,
                    BEGIN OF ts_result,
                      d TYPE ts_d,
                    END OF ts_result.
            DATA : ls_result TYPE ts_result.

            " JSON --> ABAP 结构类型
            /ui2/cl_json=>deserialize(
                EXPORTING
                    json = lv_response
                CHANGING
                    data = ls_result
             ).
            " 返回值处理
            IF ls_result-d-results IS NOT INITIAL.
              DATA:lv_serial TYPE I_Equipment-SerialNumber.
              LOOP AT ls_result-d-results INTO DATA(ls_item).
                gs_api_result-product = ls_item-material.
                gs_api_result-plant = ls_item-plant.
                gs_api_result-storagelocation = ls_item-storagelocation.
                gs_api_result-Quantity = ls_item-matlwrhsstkqtyinmatlbaseunit.
                gs_api_result-InventoryStockType = ls_item-InventoryStockType.
                IF ls_item-to_materialserialnumber-results IS INITIAL.
                  APPEND gs_api_result TO gt_api_result.
                ELSE.
                  DELETE ls_item-to_materialserialnumber-results WHERE serialnumber NOT IN lr_serialn.
                  LOOP AT ls_item-to_materialserialnumber-results INTO DATA(ls_ser).
                    gs_api_result-Quantity = 1.
                    lv_serial = |{ ls_ser-serialnumber ALPHA = IN }|.
                    gs_api_result-SerialNumber = lv_serial .
                    APPEND gs_api_result TO gt_api_result.
                  ENDLOOP.
                ENDIF.
                CLEAR gs_api_result.
              ENDLOOP.
            ENDIF.
          ENDIF.

          SORT gt_api_result BY product plant storagelocation.

*&---获取API 库存信息
        LOOP AT gt_itab INTO gs_itab.
          AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
          ID 'ACTVT' FIELD '03'
          ID 'WERKS' FIELD gs_itab-plant.
          IF sy-subrc <> 0.
            CONTINUE.
          ELSE.
            AUTHORITY-CHECK OBJECT 'M_MATE_MAT'
            ID 'ACTVT' FIELD '03'
            ID 'BEGRU' FIELD gs_itab-authorizationgroup.
            IF sy-subrc <> 0.
                CONTINUE.
            ENDIF.
          ENDIF.

          ls_results-producttype   = gs_itab-producttype.
          ls_results-plant         = gs_itab-plant.
          ls_results-Storage       = gs_itab-storagelocation.
          ls_results-Material      = gs_itab-product.
          ls_results-MaterialGroup = gs_itab-productgroup.
          ls_results-baseofunit    = gs_itab-baseunit.
          ls_results-SerialNumber  = gs_itab-serialnumber.
          READ TABLE lt_producttext INTO DATA(ls_producttext) WITH KEY product = gs_itab-product BINARY SEARCH.
          IF sy-subrc = 0.
            ls_results-Description = ls_producttext-ProductName.
          ENDIF.

          READ TABLE gt_api_result ASSIGNING FIELD-SYMBOL(<fs_api_result>) WITH KEY product = gs_itab-product
            plant = gs_itab-plant
            storagelocation = gs_itab-storagelocation BINARY SEARCH.
          IF sy-subrc = 0.
            DATA(lv_index) = sy-tabix.
            LOOP AT gt_api_result INTO gs_api_result FROM lv_index.
                IF gs_api_result-product <> gs_itab-product
                OR gs_api_result-plant <> gs_itab-plant
                OR gs_api_result-storagelocation <> gs_itab-storagelocation.
                    EXIT.
                ENDIF.

                ls_results-Quantity = gs_api_result-quantity.
                ls_results-InventoryStockType = gs_api_result-inventorystocktype.
                ls_results-SerialNumber = gs_api_result-serialnumber.

                APPEND ls_results TO lt_results.
                CLEAR gs_api_result.
            ENDLOOP.
          ENDIF.
          CLEAR: gs_itab, ls_results.
        ENDLOOP.
*&---获取凭证信息【物料凭证最新凭证】
        SELECT a~Plant,
               b~StorageLocation,
               a~Material,
               c~SerialNumber,
               MAX( PostingDate ) AS PostingDate
          FROM @lt_results AS a
          JOIN I_MaterialDocumentItem_2 AS b ON a~Material = b~Material
                                            AND a~plant    = b~plant
                                            AND a~Storage  = b~StorageLocation
     LEFT JOIN I_SerialNumberMaterialDoc_2 AS c ON b~MaterialDocumentYear = c~MaterialDocumentYear
                                               AND b~MaterialDocument     = c~MaterialDocument
                                               AND b~MaterialDocumentItem = c~MaterialDocumentItem
         WHERE GoodsMovementType IN ('101','501','657' )
         GROUP BY a~Plant, b~StorageLocation,a~Material,  c~SerialNumber
          INTO TABLE @DATA(lt_doc).
        SORT lt_doc BY plant StorageLocation material   SerialNumber.
        DELETE lt_results WHERE Quantity = 0.
        LOOP AT lt_results ASSIGNING FIELD-SYMBOL(<lfs_result>).
          " 物料凭证过账日期
          READ TABLE lt_doc INTO DATA(ls_doc) WITH KEY plant           = <lfs_result>-plant
                                                       StorageLocation = <lfs_result>-Storage
                                                       Material        = <lfs_result>-Material
                                                       SerialNumber    = <lfs_result>-SerialNumber
                                                       BINARY SEARCH.
          IF sy-subrc = 0.
            <lfs_result>-AgingYear  = ls_doc-postingdate+0(4). " year
            <lfs_result>-AgingMonth = ls_doc-postingdate+4(2). " Month
            <lfs_result>-AgingDate  = ls_doc-postingdate.      " Date
          ENDIF.
        ENDLOOP.
        SORT lt_results BY plant Storage material SerialNumber.

*&---====================2.数据获取后，select 排序/过滤/分页/返回设置
*&---设置过滤器
        zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  ) CHANGING ct_data = lt_results ).
*&---设置记录总数
        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_results ) ).
        ENDIF.
*&---设置排序
        zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )  CHANGING ct_data = lt_results ).
*&---设置按页查询
        zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  ) CHANGING ct_data = lt_results ).
*&---返回数据
        io_response->set_data( lt_results ).

      CATCH cx_rap_query_filter_no_range.
    ENDTRY.
  ENDMETHOD.


  METHOD if_rap_query_provider~select.
*&---RAP 接口查询，选择处理
    TRY.
        CASE io_request->get_entity_id( ).
          WHEN 'ZR_SMM010'.
            get_stockAging( io_request = io_request io_response = io_response ).
        ENDCASE.
      CATCH cx_rap_query_provider INTO DATA(lx_query).
      CATCH cx_sy_no_handler INTO DATA(lx_synohandler).
      CATCH cx_sy_open_sql_db.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
