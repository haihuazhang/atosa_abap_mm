@EndUserText.label: 'Get material document items Info'
define abstract entity ZR_SMM008_MATDOC
{
  MaterialDocumentYear         : mjahr;
  MaterialDocument             : mblnr;
  MaterialDocumentItem         : mblpo;
  Material                     : matnr;
  Plant                        : werks_d;
  StorageLocation              : zzemm006;
  IssuingOrReceivingPlant      : werks_d;
  IssuingOrReceivingStorageLoc : zzemm006;
  @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
  QuantityInBaseUnit           : menge_d;
  MaterialBaseUnit             : meins;

}
