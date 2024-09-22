@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TMM002'
@ObjectModel.semanticKey: [ 'ShipmentNumber', 'ContainerNumber', 'PurchaseOrder', 'PurchaseOrderItem' ]
define root view entity ZC_TMM002
  provider contract transactional_query
  as projection on ZR_TMM002
{
  key ShipmentNumber,
  key ContainerNumber,
  key PurchaseOrder,
  key PurchaseOrderItem,
      @ObjectModel: { text.element: [ 'SupplierName' ] }
      Supplier,
      @ObjectModel: { text.element: [ 'ProductName' ] }
      Material,
      @ObjectModel: { text.element: [ 'PlantName' ] }
      Plant,
      @ObjectModel: { text.element: [ 'StorageLocationName' ] }
      StorageLocation,
      SerialNumberProfile,
      LoadingQuantity,
      ReceivedQuantity,
      OpenQuantity,
      OrderUnit,
      MaterialDocument,
      MaterialDocumentItem,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      @UI.hidden:true
      _Supplier.SupplierName,
      @UI.hidden:true
      _Product,
      @UI.hidden:true
      _ProductText.ProductName,
      @UI.hidden:true
      _Plant.PlantName,
      @UI.hidden:true
      _StorageLocation.StorageLocationName
}
