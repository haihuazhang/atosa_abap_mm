CLASS zbp_r_tmm002 DEFINITION
  PUBLIC
  ABSTRACT
  FINAL
  FOR BEHAVIOR OF zr_tmm002 .

  PUBLIC SECTION.

    CLASS-DATA:
      BEGIN OF gs_serialnumber,
        purchase_order      TYPE ebeln,
        purchase_order_item TYPE ebelp,
        material            TYPE zzemm009,
        old_serial_number   TYPE zzemm007,
        serial_number       TYPE zzemm008,
        receipt_date        TYPE datum,
        plant               TYPE werks_d,
        storage_location    TYPE zzemm006,
      END OF gs_serialnumber,
      BEGIN OF gs_item,
        material               TYPE zzemm009,
        plant                  TYPE werks_d,
        storage_location       TYPE zzemm006,
        quantity_in_entry_unit TYPE menge_d,
        entry_unit             TYPE meins,
        purchase_order         TYPE ebeln,
        purchase_order_item    TYPE ebelp,
        serial_numbers         LIKE TABLE OF gs_serialnumber,
      END OF gs_item,
      BEGIN OF gs_data,
        shipment_number  TYPE zzemm004,
        container_number TYPE zzemm005,
        items            LIKE TABLE OF gs_item,
      END OF gs_data.

    CLASS-DATA gt_serial_numbers LIKE TABLE OF gs_serialnumber.

    CLASS-DATA gs_mapped_material_document TYPE RESPONSE FOR MAPPED i_materialdocumenttp.

    CLASS-DATA gt_material_document_items TYPE TABLE FOR CREATE i_materialdocumenttp\_materialdocumentitem.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZBP_R_TMM002 IMPLEMENTATION.
ENDCLASS.
