@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Shipment Document Container''s Serial'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SMM004
  as select from ztmm003 as _tmm003
  association [0..1] to I_ProductText     as _ProductText       on  _ProductText.Product  = $projection.Material
                                                                and _ProductText.Language = $session.system_language
  association [0..1] to I_CompanyCode     as _CompanyCode       on  _CompanyCode.CompanyCode = $projection.CompanyCode
  association [0..1] to I_Plant           as _Plant             on  _Plant.Plant = $projection.Plant
  association [0..1] to I_StorageLocation as _StorageLocation   on  _StorageLocation.Plant           = $projection.Plant
                                                                and _StorageLocation.StorageLocation = $projection.StorageLocation
  association [0..1] to I_BusinessUserVH  as _CreatedUser       on  _CreatedUser.UserID = $projection.CreatedBy
  association [0..1] to I_BusinessUserVH  as _ChangedUser       on  _ChangedUser.UserID = $projection.LastChangedBy

  association        to parent ZR_SMM003  as _ShipmentContainer on  _ShipmentContainer.ShipmentNumber    = $projection.ShipmentNumber
                                                                and _ShipmentContainer.ContainerNumber   = $projection.ContainerNumber
                                                                and _ShipmentContainer.PurchaseOrder     = $projection.PurchaseOrder
                                                                and _ShipmentContainer.PurchaseOrderItem = $projection.PurchaseOrderItem
  association [1..1] to ZR_SMM001         as _ShipmentHeader    on  _ShipmentHeader.PurchaseOrder = $projection.PurchaseOrder
{
  key _tmm003.shipment_number       as ShipmentNumber,
  key _tmm003.material              as Material,
  key _tmm003.old_serial_number     as OldSerialNumber,
  key _tmm003.serial_number         as SerialNumber,
      _tmm003.received              as Received,
      _tmm003.container_number      as ContainerNumber,
      _tmm003.purchase_order        as PurchaseOrder,
      _tmm003.purchase_order_item   as PurchaseOrderItem,
      _tmm003.company_code          as CompanyCode,
      _tmm003.plant                 as Plant,
      _tmm003.storage_location      as StorageLocation,
      _tmm003.created_by            as CreatedBy,
      _tmm003.created_at            as CreatedAt,
      _tmm003.last_changed_by       as LastChangedBy,
      _tmm003.last_changed_at       as LastChangedAt,
      _tmm003.local_last_changed_at as LocalLastChangedAt,

      /* Associations */
      _ProductText,
      _CompanyCode,
      _Plant,
      _StorageLocation,
      _CreatedUser,
      _ChangedUser,

      _ShipmentContainer,
      _ShipmentHeader
}
