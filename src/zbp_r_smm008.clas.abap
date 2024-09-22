CLASS zbp_r_smm008 DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zr_smm008.
  PUBLIC SECTION.

    CLASS-DATA:
      BEGIN OF gs_serialnumber,
        purchase_order      TYPE ebeln,
        purchase_order_item TYPE ebelp,
        material            TYPE zzemm009,
        old_serial_number   TYPE zzemm007,
        serial_number       TYPE zzemm008,
        receipt_date        TYPE datum,
      END OF gs_serialnumber,
      BEGIN OF gs_item,
        Reversion_No  TYPE zzemm009,
        Item          TYPE zzemm009,
        Plant         TYPE werks_d,
        Storage       TYPE zzemm006,
        Material      TYPE zzemm009,
        Description   TYPE zzemm009,
        Movement_Type TYPE zzemm009,
        Total_Qty     TYPE zzemm009,
        Base_Unit     TYPE meins,
        Post_Qty      TYPE menge_d,
        Note          TYPE zzemm009,
      END OF gs_item,
      BEGIN OF gs_data,
        Reversion_No TYPE zzemm009,
        Item         TYPE zzemm009,
        Note         TYPE bktxt,
        Items        LIKE TABLE OF gs_item,
      END OF gs_data,
      BEGIN OF gs_stockinplantItem,
        Plant              TYPE werks_d,
        Storage            TYPE zzemm006,
        dest_plant         TYPE werks_d,
        Dest_Storage       TYPE zzemm006,
        Material           TYPE zzemm009,
        Serial_Number      TYPE zzemm008,
        Inventory_Stock_Type TYPE c LENGTH 2,
        Transfer_Qty       TYPE menge_d,
        Base_Unit          TYPE meins,
        flag               TYPE string,          "serial flag
      END OF gs_stockinplantItem,
      BEGIN OF gs_stockinplant,
        Plant   TYPE werks_d,
        Storage TYPE zzemm006,
        Items   LIKE TABLE OF gs_stockinplantItem,
      END OF gs_stockinplant,

*&---跨工厂收货BAPI 变量
      BEGIN OF gs_stockcrossplantRItem,
        Material_Document_Year TYPE mjahr,
        Material_Document      TYPE mblnr,
        Material_Document_Item TYPE mblpo,
        Plant                  TYPE werks_d,
        Storage_Location       TYPE zzemm006,
        Receiving_Plant        TYPE werks_d,
        Receiving_Storage_Loc  TYPE zzemm006,
        Material               TYPE matnr,
        Serial_Number          TYPE zzemm008,
        Quantity_In_Base_Unit  TYPE menge_d,
        Material_Base_Unit     TYPE meins,
        Transfer_Qty           TYPE menge_d,
        flag                   TYPE string,          "serial flag
        Serial_Number_List     TYPE TABLE OF zr_smm008_matdocsn_post,
      END OF gs_stockcrossplantRItem,
      BEGIN OF gs_stockcrossplantR,
        Items LIKE TABLE OF gs_stockcrossplantRItem,
      END OF gs_stockcrossplantR,

*&---工厂+库存+物料，获取物料库存信息 【API 输入参数】
      BEGIN OF gs_MatlStk,
        Plant    TYPE werks_d,
        Storage  TYPE zzemm006,
        Material TYPE zzemm009,
      END OF gs_MatlStk,

*&---工厂+库存+物料，获取物料库存信息 【API 输出表】
      BEGIN OF gs_MatlStkItab,
        Plant     TYPE werks_d,
        Storage   TYPE zzemm006,
        Material  TYPE zzemm009,
        Quntity   TYPE menge_d,
        Base_Unit TYPE meins,
      END OF gs_MatlStkItab,
*&---===获取序列号信息，【API 输入参数】
      BEGIN OF ty_getMatlStkSerialIn,
        Serial_Number TYPE zzemm008,
      END OF ty_getMatlStkSerialIn,

*&---===获取预留信息，【API 输入参数】
      BEGIN OF ty_getReservationItemIn,
        Reversion_No TYPE c LENGTH 30,
      END OF ty_getReservationItemIn,
*&---===获取预留信息，【API 输入参数】
      BEGIN OF ty_getMatlDocItemIn,
        Material_Document TYPE mblnr,
      END OF ty_getMatlDocItemIn,

*&---===获取凭证行序列号信息，【API 输入参数】
      BEGIN OF gs_getMatDocSNIn,
        Material_Document_Year TYPE mjahr,
        Material_Document      TYPE mblnr,
        Material_Document_Item TYPE mblpo,
      END OF gs_getMatDocSNIn.

    CLASS-DATA gt_MatlStkItab LIKE TABLE OF gs_MatlStkItab.

    CLASS-DATA gt_serial_numbers LIKE TABLE OF gs_serialnumber.

    CLASS-DATA gs_mapped_material_document TYPE RESPONSE FOR MAPPED i_materialdocumenttp.

    CLASS-DATA gt_material_document_items TYPE TABLE FOR CREATE i_materialdocumenttp\_materialdocumentitem.
ENDCLASS.



CLASS ZBP_R_SMM008 IMPLEMENTATION.
ENDCLASS.
