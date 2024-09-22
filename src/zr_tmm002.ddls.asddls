@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTMM002'
define root view entity ZR_TMM002
  as select from ztmm002

  association [0..1] to I_Supplier        as _Supplier        on  _Supplier.Supplier = $projection.Supplier
  association [0..1] to I_Product         as _Product         on  _Product.Product = $projection.Material
  association [0..1] to I_ProductText     as _ProductText     on  _ProductText.Product  = $projection.Material
                                                              and _ProductText.Language = $session.system_language
  association [0..1] to I_Plant           as _Plant           on  _Plant.Plant = $projection.Plant
  association [0..1] to I_StorageLocation as _StorageLocation on  _StorageLocation.Plant           = $projection.Plant
                                                              and _StorageLocation.StorageLocation = $projection.StorageLocation
{
  key shipment_number                                                     as ShipmentNumber,
  key container_number                                                    as ContainerNumber,
  key purchase_order                                                      as PurchaseOrder,
  key purchase_order_item                                                 as PurchaseOrderItem,
      supplier                                                            as Supplier,
      material                                                            as Material,
      plant                                                               as Plant,
      storage_location                                                    as StorageLocation,
      serial_number_profile                                               as SerialNumberProfile,
      @Semantics.quantity.unitOfMeasure: 'OrderUnit'
      loading_quantity                                                    as LoadingQuantity,
      @Semantics.quantity.unitOfMeasure: 'OrderUnit'
      received_quantity                                                   as ReceivedQuantity,
      @Semantics.quantity.unitOfMeasure: 'OrderUnit'
      cast( loading_quantity -  received_quantity as abap.quan( 13, 3 ) ) as OpenQuantity,
      order_unit                                                          as OrderUnit,
      material_document                                                   as MaterialDocument,
      material_document_item                                              as MaterialDocumentItem,
      @Semantics.user.createdBy: true
      created_by                                                          as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                                                          as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                                                     as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                                                     as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at                                               as LocalLastChangedAt,

      /* Associations */
      _Supplier,
      _Product,
      _ProductText,
      _Plant,
      _StorageLocation
}
