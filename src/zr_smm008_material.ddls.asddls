@EndUserText.label: 'Get material Stock data'
define abstract entity zr_smm008_material
{
  Plant                        : werks_d;
  StorageLocation              : zzemm006;
  Material                     : zzemm009;
  SerialNumber                 : zzemm008;
  InventoryStockType           : abap.char(2);
  @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
  MatlWrhsStkQtyInMatlBaseUnit : menge_d;
  MaterialBaseUnit             : meins;

}
