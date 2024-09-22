@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TMM004'
@ObjectModel.semanticKey: [ 'Material', 'SerialNumber', 'Plant' ]
define root view entity ZC_TMM004
  provider contract transactional_query
  as projection on ZR_TMM004
{
  key Plant,
  key Material,
  key SerialNumber,
  @EndUserText.label: 'Old Serial Number'
  OriginalSerialNumber,
  @EndUserText.label: 'Delivery Cost'
  DeliveryCost,
  @EndUserText.label: 'Value received'
  ValueReceived,
  @EndUserText.label: 'Freight'
  Freight,
  @EndUserText.label: 'Tariff'
  Tariff,
  @EndUserText.label: 'Inventory Value'
  InventoryValue,
  LocalLastChangedAt
  
}
