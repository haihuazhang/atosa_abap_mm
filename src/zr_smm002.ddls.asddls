@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Shipment Document Item from PO'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SMM002
  as select from I_PurchaseOrderItemAPI01 as _PurchaseOrderItem

  association [0..1] to I_Product                 as _Product            on  _Product.Product = $projection.Material
  association [0..1] to I_ProductText             as _ProductText        on  _ProductText.Product  = $projection.Material
                                                                         and _ProductText.Language = $session.system_language
  association [0..1] to I_ProductGroupText_2      as _ProductGroupText   on  _ProductGroupText.ProductGroup = $projection.MaterialGroup
                                                                         and _ProductGroupText.Language     = $session.system_language
  association [0..1] to I_Plant                   as _Plant              on  _Plant.Plant = $projection.Plant
  association [0..1] to I_StorageLocation         as _StorageLocation    on  _StorageLocation.Plant           = $projection.Plant
                                                                         and _StorageLocation.StorageLocation = $projection.StorageLocation
  association [1]    to I_PurOrdScheduleLineAPI01 as _PurOrdScheduleLine on  _PurOrdScheduleLine.PurchaseOrder             = $projection.PurchaseOrder
                                                                         and _PurOrdScheduleLine.PurchaseOrderItem         = $projection.PurchaseOrderItem
                                                                         and _PurOrdScheduleLine.PurchaseOrderScheduleLine = '0001'
  association        to parent ZR_SMM001          as _ShipmentHeader     on  _ShipmentHeader.PurchaseOrder = $projection.PurchaseOrder

{

  key _PurchaseOrderItem.PurchaseOrder,
  key _PurchaseOrderItem.PurchaseOrderItem, // Shipment Item
      _PurchaseOrderItem.Material,
      _PurchaseOrderItem.PurchaseOrderItemText,
      _PurchaseOrderItem.MaterialGroup,
      _PurchaseOrderItem.PurchaseOrderQuantityUnit,
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      _PurchaseOrderItem.OrderQuantity,
      _PurchaseOrderItem.Plant,
      _PurchaseOrderItem.StorageLocation,

      /* Associations */
      _Product,
      _ProductText,
      _ProductGroupText,
      _Plant,
      _StorageLocation,

      _PurOrdScheduleLine,
      _ShipmentHeader
}
where
  _PurchaseOrderItem.AccountAssignmentCategory = ''
