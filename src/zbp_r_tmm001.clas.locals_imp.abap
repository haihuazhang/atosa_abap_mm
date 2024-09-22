CLASS lhc_zr_tmm001 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR zr_tmm001
        RESULT result,
      check FOR VALIDATE ON SAVE
        IMPORTING keys FOR zr_tmm001~check.

    METHODS is_standard_action_granted
      IMPORTING iv_action             TYPE activ_auth
      RETURNING VALUE(action_granted) TYPE abap_bool.
*    METHODS is_update_granted
*      RETURNING VALUE(update_granted) TYPE abap_bool.
*    METHODS is_delete_granted
*      RETURNING VALUE(delete_granted) TYPE abap_bool.
ENDCLASS.

CLASS lhc_zr_tmm001 IMPLEMENTATION.
  METHOD get_global_authorizations.
    " Authorization Check for Create
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      IF is_standard_action_granted( '01' ) = abap_true.
        result-%create = if_abap_behv=>auth-allowed.
      ELSE.
        result-%create = if_abap_behv=>auth-unauthorized.
      ENDIF.
    ENDIF.

    " Authorization Check for Update
    IF requested_authorizations-%update                =  if_abap_behv=>mk-on OR
           requested_authorizations-%action-edit           =  if_abap_behv=>mk-on.
      IF is_standard_action_granted( '02' ) = abap_true.
        result-%update = if_abap_behv=>auth-allowed.
        result-%action-edit = if_abap_behv=>auth-allowed.
      ELSE.
        result-%update = if_abap_behv=>auth-unauthorized.
        result-%action-edit = if_abap_behv=>auth-unauthorized.
      ENDIF.
    ENDIF.

    " Authorization Check for Delete
    IF requested_authorizations-%delete =  if_abap_behv=>mk-on.
      IF is_standard_action_granted( '06' ) = abap_true.
        result-%delete = if_abap_behv=>auth-allowed.
      ELSE.
        result-%delete = if_abap_behv=>auth-unauthorized.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD is_standard_action_granted.

    ##AUTH_FLD_MISSING
    AUTHORITY-CHECK OBJECT 'ZZ_AUTH03'
*    ID 'ZZDUMMY' FIELD abap_true
        ID 'ACTVT'      FIELD iv_action.
    action_granted = COND #( WHEN sy-subrc = 0 THEN abap_true ELSE abap_false ).

*    DATA(lo_bu_factory) = cl_iam_business_user_factory=>create_instance( ).
*    lo_bu_factory->get_business_user(
*      EXPORTING
*        iv_user_id       = 'CB9980000019'
*      IMPORTING
*        eo_business_user = DATA(lo_buser)
*        et_return        = DATA(lt_return) ).
*    DATA(lo_br_factory) = cl_iam_business_role_factory=>create_instance( ).
*    DATA(lt_brole_id) = lo_buser->get_business_roles( ).
*    LOOP AT lt_brole_id ASSIGNING FIELD-SYMBOL(<fs_brole_id>).
*      lo_br_factory->get_business_role_by_id(
*        EXPORTING
*          iv_id            = <fs_brole_id>
*        IMPORTING
*          eo_business_role = DATA(lo_brole)
*          et_return        = lt_return ).
*
**      out->write( |ID: { lo_brole->get_id(  ) }| ).
*    ENDLOOP.

*    DATA(lo_br_factory) = cl_iam_business_role_factory=>create_instance( ).
*
*    lo_br_factory->query_business_roles(
*      EXPORTING
*        ir_brole_id = VALUE #( ( sign = 'I'
*                                 option = 'CP'
*                                 low = 'ZZ_BR_MATERIALSERIAL_MAPPING' ) )
*      IMPORTING
*        et_result   = DATA(lt_result) ).
*    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<fs_result>).
*
*      lo_br_factory->get_business_role(
*              EXPORTING
*                iv_uuid          = <fs_result>-uuid
*              IMPORTING
*                eo_business_role = DATA(lo_brole)
*                et_return        = DATA(lt_return) ).
*
*      DATA(lv_id) = lo_brole->get_id( ).
*
*
*      lo_brole->get_access_restriction(
*        IMPORTING
*            ev_write = DATA(lv_w)
*            ev_read  = DATA(lv_r)
*            ev_f4    = DATA(lv_f4) ).
*    ENDLOOP.

  ENDMETHOD.


  METHOD check.
    READ ENTITIES OF zr_tmm001 IN LOCAL MODE
    ENTITY zr_tmm001
    FIELDS ( product )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    IF lt_data IS NOT INITIAL.
      SELECT *                                "#EC CI_ALL_FIELDS_NEEDED
      FROM i_product
      WITH PRIVILEGED ACCESS
      FOR ALL ENTRIES IN @lt_data
      WHERE product      = @lt_data-product
      INTO TABLE @DATA(lt_product).
      SORT lt_product BY product.
    ENDIF.

    LOOP AT lt_data INTO DATA(ls_data).
      IF ls_data-product IS NOT INITIAL.
        READ TABLE lt_product INTO DATA(ls_product) WITH KEY product = ls_data-product BINARY SEARCH.
        IF sy-subrc <> 0.
          ##NO_TEXT
          INSERT VALUE #( uuid                         = ls_data-uuid
                            %msg                       = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                                                text     = 'Product not exist' )
                            %element-product = if_abap_behv=>mk-on
                          ) INTO TABLE reported-zr_tmm001.
          INSERT VALUE #( uuid = ls_data-uuid ) INTO TABLE failed-zr_tmm001.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
