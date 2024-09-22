@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTMM004'
define root view entity ZR_TMM004
  as select from ztmm004
{
  key plant as Plant,
  key material as Material,
  key serial_number as SerialNumber,
  original_serial_number as OriginalSerialNumber,
  delivery_cost as DeliveryCost,
  value_received as ValueReceived,
  freight as Freight,
  tariff as Tariff,
  inventory_value as InventoryValue,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
