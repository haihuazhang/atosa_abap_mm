@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TMM003'
@ObjectModel.semanticKey: [ 'ShipmentNumber', 'Material', 'OldSerialNumber', 'SerialNumber' ]
define root view entity ZC_TMM003
  provider contract transactional_query
  as projection on ZR_TMM003
{
  key ShipmentNumber,
      @ObjectModel: { text.element: [ 'ProductName' ] }
  key Material,
  key OldSerialNumber,
  key SerialNumber,
      Received,
      ReceiptDate,
      ContainerNumber,
      PurchaseOrder,
      PurchaseOrderItem,
      @ObjectModel: { text.element: [ 'CompanyCodeName' ] }
      CompanyCode,
      @ObjectModel: { text.element: [ 'PlantName' ] }
      Plant,
      @ObjectModel: { text.element: [ 'StorageLocationName' ] }
      StorageLocation,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      @UI.hidden:true
      _Product,
      @UI.hidden:true
      _ProductText.ProductName,
      @UI.hidden:true
      _CompanyCode.CompanyCodeName,
      @UI.hidden:true
      _Plant.PlantName,
      @UI.hidden:true
      _StorageLocation.StorageLocationName
}
