@EndUserText.label: 'Shipment Document Container''s Serial'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_SMM004
  as projection on ZR_SMM004
{
  key ShipmentNumber,
      @ObjectModel: { text.element: [ 'ProductName' ] }
  key Material,
  key OldSerialNumber,
  key SerialNumber,
      Received,
      ContainerNumber,
      PurchaseOrder,
      PurchaseOrderItem,
      @ObjectModel: { text.element: [ 'CompanyCodeName' ] }
      CompanyCode,
      @ObjectModel: { text.element: [ 'PlantName' ] }
      Plant,
      @ObjectModel: { text.element: [ 'StorageLocationName' ] }
      StorageLocation,
      @ObjectModel: { text.element: [ 'CreatedUserDescription' ] }
      CreatedBy,
      CreatedAt,
      @ObjectModel: { text.element: [ 'ChangedUserDescription' ] }
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      @UI.hidden:true
      _ProductText.ProductName,
      @UI.hidden:true
      _CompanyCode.CompanyCodeName,
      @UI.hidden:true
      _Plant.PlantName,
      @UI.hidden:true
      _StorageLocation.StorageLocationName,
      @UI.hidden:true
      _CreatedUser.PersonFullName as CreatedUserDescription,
      @UI.hidden:true
      _ChangedUser.PersonFullName as ChangedUserDescription,

      /* Associations */
      _ShipmentContainer : redirected to parent ZC_SMM003,
      _ShipmentHeader    : redirected to ZC_SMM001
}
