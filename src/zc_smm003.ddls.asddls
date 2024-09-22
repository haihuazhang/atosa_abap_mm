@EndUserText.label: 'Shipment Document Containers'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_SMM003
  as projection on ZR_SMM003
{
  key PurchaseOrder,
  key PurchaseOrderItem,
  key ShipmentNumber,
  key ContainerNumber,
      Supplier,
      @ObjectModel: { text.element: [ 'ProductName' ] }
      Material,
      @ObjectModel: { text.element: [ 'PlantName' ] }
      Plant,
      @ObjectModel: { text.element: [ 'StorageLocationName' ] }
      StorageLocation,
      SerialNumberProfile,
      @Semantics.quantity.unitOfMeasure: 'OrderUnit'
      LoadingQuantity,
      @Semantics.quantity.unitOfMeasure: 'OrderUnit'
      ReceivedQuantity,
      OpenQuantity,
      OrderUnit,
      MaterialDocument,
      MaterialDocumentItem,
      @ObjectModel: { text.element: [ 'CreatedUserDescription' ] }
      CreatedBy,
      CreatedAt,
      @ObjectModel: { text.element: [ 'ChangedUserDescription' ] }
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      @UI.hidden:true
      _Product,
      @UI.hidden:true
      _ProductText.ProductName,
      @UI.hidden:true
      _Plant.PlantName,
      @UI.hidden:true
      _StorageLocation.StorageLocationName,
      @UI.hidden:true
      _CreatedUser.PersonFullName as CreatedUserDescription,
      @UI.hidden:true
      _ChangedUser.PersonFullName as ChangedUserDescription,

      /* Associations */
      _ShipmentHeader       : redirected to parent ZC_SMM001,
      _ShipmentSerialNumber : redirected to composition child ZC_SMM004
}
