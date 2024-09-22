@EndUserText.label: 'Get Reservation Info'
define abstract entity ZR_SMM008_RESERVATION
{
  Reservation                    : abap.char(30);
  ReservationItem                : abap.char(30);
  Product                        : matnr;
  ResvnItmRequiredQtyInBaseUnit  : abap.char(30);
  ResvnItmWithdrawnQtyInBaseUnit : abap.char(30);
  BaseUnit                       : meins;
  Plant                          : werks_d;
  StorageLocation                : abap.char(4);
  GoodsMovementType              : abap.char(3);
}
