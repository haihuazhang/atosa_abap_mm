@EndUserText.label: 'Shipment Document Item from PO'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_SMM002
  as projection on ZR_SMM002
{
  key PurchaseOrder,
  key PurchaseOrderItem as ShipmentItem,
      @ObjectModel: { text.element: [ 'ProductName' ] }
      Material,
      PurchaseOrderItemText,
      @ObjectModel: { text.element: [ 'ProductGroupName' ] }
      MaterialGroup,
      PurchaseOrderQuantityUnit,
      _PurOrdScheduleLine.ScheduleLineDeliveryDate,
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      OrderQuantity,
      @ObjectModel: { text.element: [ 'PlantName' ] }
      Plant,
      @ObjectModel: { text.element: [ 'StorageLocationName' ] }
      StorageLocation,

      @UI.hidden:true
      _Product,
      @UI.hidden:true
      _ProductText.ProductName,
      @UI.hidden:true
      _ProductGroupText.ProductGroupName,
      @UI.hidden:true
      _Plant.PlantName,
      @UI.hidden:true
      _StorageLocation.StorageLocationName,

      /* Associations */
      _ShipmentHeader : redirected to parent ZC_SMM001
}
