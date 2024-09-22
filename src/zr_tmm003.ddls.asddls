@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTMM003'
define root view entity ZR_TMM003
  as select from ztmm003

  association [0..1] to I_Product         as _Product         on  _Product.Product = $projection.Material
  association [0..1] to I_ProductText     as _ProductText     on  _ProductText.Product  = $projection.Material
                                                              and _ProductText.Language = $session.system_language
  association [0..1] to I_CompanyCode     as _CompanyCode     on  _CompanyCode.CompanyCode = $projection.CompanyCode
  association [0..1] to I_Plant           as _Plant           on  _Plant.Plant = $projection.Plant
  association [0..1] to I_StorageLocation as _StorageLocation on  _StorageLocation.Plant           = $projection.Plant
                                                              and _StorageLocation.StorageLocation = $projection.StorageLocation

{
  key shipment_number       as ShipmentNumber,
  key material              as Material,
  key old_serial_number     as OldSerialNumber,
  key serial_number         as SerialNumber,
      received              as Received,
      receipt_date          as ReceiptDate,
      container_number      as ContainerNumber,
      purchase_order        as PurchaseOrder,
      purchase_order_item   as PurchaseOrderItem,
      company_code          as CompanyCode,
      plant                 as Plant,
      storage_location      as StorageLocation,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      /* Associations */
      _Product,
      _ProductText,
      _CompanyCode,
      _Plant,
      _StorageLocation
}
