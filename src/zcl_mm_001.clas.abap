CLASS zcl_mm_001 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MM_001 IMPLEMENTATION.


  METHOD if_rap_query_provider~select.

    DATA: ls_data TYPE zr_smm009,
          lt_data TYPE TABLE OF zr_smm009.

    DATA: lr_companycode            TYPE RANGE OF i_purchaseorderapi01-companycode,
          lr_purchasingorganization TYPE RANGE OF i_purchaseorderapi01-purchasingorganization,
          lr_purchaseorder          TYPE RANGE OF i_purchaseorderapi01-purchaseorder,
          lr_plant                  TYPE RANGE OF i_purchaseorderitemapi01-plant,
          lr_supplier               TYPE RANGE OF i_purchaseorderapi01-supplier,
          lr_createdby              TYPE RANGE OF i_purchaseorderapi01-createdbyuser.

    TRY.
        DATA(lo_filter) = io_request->get_filter(  ).
        DATA(lt_filters) = lo_filter->get_as_ranges(  ).

        LOOP AT lt_filters INTO DATA(ls_filter).
          TRANSLATE ls_filter-name TO UPPER CASE.
          CASE ls_filter-name.
            WHEN 'COMPANYCODE'.
              MOVE-CORRESPONDING ls_filter-range TO lr_companycode.
            WHEN 'PURCHASINGORGANIZATION'.
              MOVE-CORRESPONDING ls_filter-range TO lr_purchasingorganization.
            WHEN 'PURCHASEORDER'.
              MOVE-CORRESPONDING ls_filter-range TO lr_purchaseorder.
            WHEN 'PLANT'.
              MOVE-CORRESPONDING ls_filter-range TO lr_plant.
            WHEN 'SUPPLIER'.
              MOVE-CORRESPONDING ls_filter-range TO lr_supplier.
            WHEN 'CREATEDBY'.
              MOVE-CORRESPONDING ls_filter-range TO lr_createdby.
          ENDCASE.
        ENDLOOP.

        " Not deleted and received
        SELECT DISTINCT
               'I'  AS sign,
               'EQ' AS option,
               purchaseorder AS low,
               purchaseorder AS hign
          FROM i_purchaseorderitemapi01
         WHERE plant IN @lr_plant
           AND iscompletelydelivered IS NOT INITIAL
           AND purchasingdocumentdeletioncode IS INITIAL
          INTO TABLE @DATA(lt_include).
        SORT lt_include BY low.

        SELECT DISTINCT
               purchaseorder
          FROM i_purchaseorderitemapi01
         WHERE plant IN @lr_plant
           AND iscompletelydelivered IS INITIAL
           AND purchasingdocumentdeletioncode IS INITIAL
           AND invoiceisexpected IS NOT INITIAL
          INTO TABLE @DATA(lt_exclude).
        SORT lt_exclude BY purchaseorder.

        LOOP AT lt_include INTO DATA(ls_include).
          IF line_exists( lt_exclude[ purchaseorder = ls_include-low ] ).
            DELETE lt_include.
          ENDIF.
        ENDLOOP.

        IF lt_include IS NOT INITIAL.
          " PO Item - Not deleted and received
          SELECT purchaseorder,
                 correspncexternalreference AS shipmentnumber,
                 supplier,
                 purchasingorganization,
                 purchasinggroup,
                 companycode,
                 createdbyuser,
                 creationdate
            FROM i_purchaseorderapi01
*           WHERE purchaseorder NOT IN ( SELECT purchaseorder
*                                          FROM i_purchaseorderitemapi01
*                                         WHERE plant IN @lr_plant
*                                           AND iscompletelydelivered IS INITIAL
*                                           AND purchasingdocumentdeletioncode IS NOT INITIAL
*                                           AND invoiceisexpected IS INITIAL )
           WHERE purchaseorder IN @lt_include
             AND companycode IN @lr_companycode
             AND purchasingorganization IN @lr_purchasingorganization
             AND purchaseorder IN @lr_purchaseorder
             AND supplier IN @lr_supplier
             AND createdbyuser IN @lr_createdby
           ORDER BY purchaseorder
            INTO TABLE @DATA(lt_purchaseorder).
        ENDIF.

        IF lt_purchaseorder IS NOT INITIAL.
          SELECT DISTINCT
                 purchaseorder,
                 plant,
                 material,
                 _product~authorizationgroup
            FROM i_purchaseorderitemapi01
            LEFT JOIN i_product AS _product ON _product~product = i_purchaseorderitemapi01~material
             FOR ALL ENTRIES IN @lt_purchaseorder
           WHERE purchaseorder = @lt_purchaseorder-purchaseorder
             AND purchasingdocumentdeletioncode IS INITIAL
           INTO TABLE @DATA(lt_purchaseorderitem). "#EC CI_NO_TRANSFORM
          SORT lt_purchaseorderitem BY purchaseorder.

          " Authorization Check
          LOOP AT lt_purchaseorderitem INTO DATA(ls_purchaseorderitem).
            AUTHORITY-CHECK OBJECT 'M_MATE_WRK'
            ID 'WERKS' FIELD ls_purchaseorderitem-plant
            ID 'ACTVT' FIELD '03'.
            IF sy-subrc <> 0.
              DELETE lt_purchaseorder WHERE purchaseorder = ls_purchaseorderitem-purchaseorder.
            ELSE.
              AUTHORITY-CHECK OBJECT 'M_MATE_MAT'
              ID 'BEGRU' FIELD ls_purchaseorderitem-authorizationgroup
              ID 'ACTVT' FIELD '03'.
              IF sy-subrc <> 0.
                DELETE lt_purchaseorder WHERE purchaseorder = ls_purchaseorderitem-purchaseorder.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.

        IF lt_purchaseorder IS NOT INITIAL.
          SELECT DISTINCT
                 purchaseorder,
                 conditiontype,
                 supplier AS conditiontypesupplier
            FROM i_purordhistdeliverycostapi01
             FOR ALL ENTRIES IN @lt_purchaseorder
           WHERE purchaseorder = @lt_purchaseorder-purchaseorder
             AND purchasinghistorydocumenttype = '1'
            INTO TABLE @DATA(lt_deliverycost1).    "#EC CI_NO_TRANSFORM
          SORT lt_deliverycost1 BY purchaseorder conditiontype.

          SELECT purchaseorder,
                 conditiontype,
                 debitcreditcode,
                 quantity
            FROM i_purordhistdeliverycostapi01
             FOR ALL ENTRIES IN @lt_purchaseorder
           WHERE purchaseorder = @lt_purchaseorder-purchaseorder
             AND purchasinghistorydocumenttype = '2'
            INTO TABLE @DATA(lt_deliverycost2).    "#EC CI_NO_TRANSFORM

          SELECT a~purchaseorder,
                 a~conditiontype,
                 SUM( CASE WHEN a~debitcreditcode = 'S' THEN a~quantity ELSE 0 END ) AS quantity_s,
                 SUM( CASE WHEN a~debitcreditcode = 'H' THEN a~quantity ELSE 0 END ) AS quantity_h
            FROM @lt_deliverycost2 AS a
           GROUP BY a~purchaseorder,
                    a~conditiontype
            INTO TABLE @DATA(lt_deliverycost2_sum).
          SORT lt_deliverycost2_sum BY purchaseorder conditiontype.

          SELECT purchaseorder,
                 purchaseorderitem,
                 accountassignmentnumber,
                 purchasinghistorydocumenttype,
                 purchasinghistorydocumentyear,
                 purchasinghistorydocument,
                 purchasinghistorydocumentitem,
                 iscompletelydelivered,
                 postingdate,
                 debitcreditcode,
                 quantity
            FROM i_purchaseorderhistoryapi01
             FOR ALL ENTRIES IN @lt_purchaseorder
           WHERE purchaseorder = @lt_purchaseorder-purchaseorder
             AND purchasinghistorydocumenttype IN ( '1','2' )
            INTO TABLE @DATA(lt_po_history).       "#EC CI_NO_TRANSFORM
          SORT lt_po_history BY purchaseorder ASCENDING
                                purchasinghistorydocumenttype ASCENDING
                                postingdate   DESCENDING.

          SELECT a~purchaseorder,
                 SUM( CASE WHEN a~debitcreditcode = 'S' THEN a~quantity ELSE 0 END ) AS quantity_s,
                 SUM( CASE WHEN a~debitcreditcode = 'H' THEN a~quantity ELSE 0 END ) AS quantity_h
            FROM @lt_po_history AS a
           WHERE purchasinghistorydocumenttype = '2'
           GROUP BY a~purchaseorder
            INTO TABLE @DATA(lt_po_history_sum).
          SORT lt_po_history_sum BY purchaseorder.

          DATA(lv_language) = cl_abap_context_info=>get_user_language_abap_format( ).

          SELECT conditiontype,
                 conditiontypename
            FROM i_conditiontypetext
           WHERE language = @lv_language
             AND conditionusage = 'A'
             AND conditionapplication = 'M'
            INTO TABLE @DATA(lt_conditiontypetext).
          SORT lt_conditiontypetext BY conditiontype.

          LOOP AT lt_purchaseorder INTO DATA(ls_purchaseorder).

            READ TABLE lt_purchaseorderitem INTO ls_purchaseorderitem WITH KEY purchaseorder = ls_purchaseorder-purchaseorder
                                                                               BINARY SEARCH.
            IF sy-subrc = 0.
              DATA(lv_plant) = ls_purchaseorderitem-plant.
            ELSE.
              CONTINUE.
            ENDIF.

            " Posting Date
            READ TABLE lt_po_history INTO DATA(ls_po_history) WITH KEY purchaseorder = ls_purchaseorder-purchaseorder
                                                                       purchasinghistorydocumenttype = '1'
                                                                       iscompletelydelivered = abap_true.
            IF sy-subrc = 0.
              DATA(lv_lastedreceiveddate) = ls_po_history-postingdate.
            ELSE.
              CLEAR lv_lastedreceiveddate.
            ENDIF.

            " Posting Date
            READ TABLE lt_po_history_sum INTO DATA(ls_po_history_sum) WITH KEY purchaseorder = ls_purchaseorder-purchaseorder
                                                                               BINARY SEARCH.
            IF sy-subrc = 0 AND ls_po_history_sum-quantity_s <> ls_po_history_sum-quantity_h..
              DATA(lv_invoiced) = abap_true.
            ELSE.
              CLEAR lv_invoiced.
            ENDIF.

            LOOP AT lt_deliverycost1 INTO DATA(ls_deliverycost1) WHERE purchaseorder = ls_purchaseorder-purchaseorder.
              CLEAR ls_data.
              MOVE-CORRESPONDING ls_purchaseorder TO ls_data.
              ls_data-createdby = ls_purchaseorder-createdbyuser.
              ls_data-createdon = ls_purchaseorder-creationdate.
              ls_data-conditiontype = ls_deliverycost1-conditiontype.
              ls_data-conditiontypesupplier = ls_deliverycost1-conditiontypesupplier.
              ls_data-plant = lv_plant.
              ls_data-lastedreceiveddate = lv_lastedreceiveddate.
              ls_data-invoiced = lv_invoiced.

              " Delivery Cost Invoiced
              READ TABLE lt_deliverycost2_sum INTO DATA(ls_deliverycost2_sum) WITH KEY purchaseorder = ls_deliverycost1-purchaseorder
                                                                                       conditiontype = ls_deliverycost1-conditiontype
                                                                                       BINARY SEARCH.
              IF sy-subrc = 0 AND ls_deliverycost2_sum-quantity_s <> ls_deliverycost2_sum-quantity_h.
                ls_data-deliverycostinvoiced = abap_true.
              ENDIF.

              READ TABLE lt_conditiontypetext INTO DATA(ls_conditiontypetext) WITH KEY conditiontype = ls_deliverycost1-conditiontype
                                                                                       BINARY SEARCH.
              IF sy-subrc = 0.
                ls_data-conditiontypename = ls_conditiontypetext-conditiontypename.
              ENDIF.

              APPEND ls_data TO lt_data.
            ENDLOOP.

            IF sy-subrc <> 0.
              CLEAR ls_data.
              MOVE-CORRESPONDING ls_purchaseorder TO ls_data.
              ls_data-createdby = ls_purchaseorder-createdbyuser.
              ls_data-createdon = ls_purchaseorder-creationdate.
              ls_data-plant     = lv_plant.
              ls_data-lastedreceiveddate = lv_lastedreceiveddate.
              ls_data-invoiced  = lv_invoiced.
              APPEND ls_data TO lt_data.
            ENDIF.

          ENDLOOP.
        ENDIF.

        IF lr_plant IS NOT INITIAL.
          DELETE lt_data WHERE plant NOT IN lr_plant[].
        ENDIF.

        zzcl_odata_utils=>filtering( EXPORTING io_filter = io_request->get_filter(  )
                                     CHANGING  ct_data = lt_data ).

        IF io_request->is_total_numb_of_rec_requested(  ) .
          io_response->set_total_number_of_records( lines( lt_data ) ).
        ENDIF.

        zzcl_odata_utils=>orderby( EXPORTING it_order = io_request->get_sort_elements( )
                                   CHANGING  ct_data = lt_data ).

        zzcl_odata_utils=>paging( EXPORTING io_paging = io_request->get_paging(  )
                                  CHANGING  ct_data = lt_data ).

        io_response->set_data( lt_data ).

      CATCH cx_root.
        " Do Nothing
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
