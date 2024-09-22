@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Reservation Document Item Info.'
define root view entity ZR_SMM008
  as select from I_ReservationDocumentItem as _ReservationItem
{
  key  cast( _ReservationItem.Reservation as abap.numc(10) )    as Reservation,
  key  cast( _ReservationItem.ReservationItem as abap.numc(4) ) as ReservationItem,
  //key  _ReservationItem.RecordType,
       Plant,
       StorageLocation,
       Product,
       GoodsMovementType,
       GoodsMovementIsAllowed,

       BaseUnit,

       EntryUnit,
       ResvnItmRequiredQtyInEntryUnit,
       ResvnItmWithdrawnQtyInBaseUnit,

       CompanyCodeCurrency,
       ResvnItmWithdrawnAmtInCCCrcy,

       GoodsRecipientName,
       UnloadingPointName,
       ReservationItemText,
       GLAccount,
       ConfdQtyForATPInBaseUoM,
       MatlCompRequirementDate,
       ResvnItmRequiredQtyInBaseUnit
       
}
