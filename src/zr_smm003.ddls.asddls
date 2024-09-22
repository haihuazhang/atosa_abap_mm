@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Shipment Document Containers'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SMM003
  as select from ztmm002 as _tmm002

  association [0..1] to I_Product         as _Product         on  _Product.Product = $projection.Material
  association [0..1] to I_ProductText     as _ProductText     on  _ProductText.Product  = $projection.Material
                                                              and _ProductText.Language = $session.system_language
  association [0..1] to I_Plant           as _Plant           on  _Plant.Plant = $projection.Plant
  association [0..1] to I_StorageLocation as _StorageLocation on  _StorageLocation.Plant           = $projection.Plant
                                                              and _StorageLocation.StorageLocation = $projection.StorageLocation
  association [0..1] to I_BusinessUserVH  as _CreatedUser     on  _CreatedUser.UserID = $projection.CreatedBy
  association [0..1] to I_BusinessUserVH  as _ChangedUser     on  _ChangedUser.UserID = $projection.LastChangedBy

  association        to parent ZR_SMM001  as _ShipmentHeader  on  _ShipmentHeader.PurchaseOrder = $projection.PurchaseOrder
  composition [0..*] of ZR_SMM004         as _ShipmentSerialNumber
{
  key _tmm002.purchase_order                               as PurchaseOrder,
  key _tmm002.purchase_order_item                          as PurchaseOrderItem,
  key _tmm002.shipment_number                              as ShipmentNumber,
  key _tmm002.container_number                             as ContainerNumber,
      _tmm002.supplier                                     as Supplier,
      _tmm002.material                                     as Material,
      _tmm002.plant                                        as Plant,
      _tmm002.storage_location                             as StorageLocation,
      _tmm002.serial_number_profile                        as SerialNumberProfile,
      @Semantics.quantity.unitOfMeasure: 'OrderUnit'
      _tmm002.loading_quantity                             as LoadingQuantity,
      @Semantics.quantity.unitOfMeasure: 'OrderUnit'
      _tmm002.received_quantity                            as ReceivedQuantity,
      @Semantics.quantity.unitOfMeasure: 'OrderUnit'
      _tmm002.loading_quantity - _tmm002.received_quantity as OpenQuantity,
      _tmm002.order_unit                                   as OrderUnit,
      _tmm002.material_document                            as MaterialDocument,
      _tmm002.material_document_item                       as MaterialDocumentItem,
      _tmm002.created_by                                   as CreatedBy,
      _tmm002.created_at                                   as CreatedAt,
      _tmm002.last_changed_by                              as LastChangedBy,
      _tmm002.last_changed_at                              as LastChangedAt,
      _tmm002.local_last_changed_at                        as LocalLastChangedAt,

      /* Associations */
      _Product,
      _ProductText,
      _Plant,
      _StorageLocation,
      _CreatedUser,
      _ChangedUser,

      _ShipmentHeader,
      _ShipmentSerialNumber
}
