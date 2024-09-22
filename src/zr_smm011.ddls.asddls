@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Reverse Scanning Records'
define root view entity ZR_SMM011
  as select from    I_MaterialDocumentItem_2    as _MaterialDocItem
    left outer join I_MaterialDocumentHeader_2  as _MaterialDocHeader       on  _MaterialDocHeader.MaterialDocumentYear = _MaterialDocItem.MaterialDocumentYear
                                                                            and _MaterialDocHeader.MaterialDocument     = _MaterialDocItem.MaterialDocument
    left outer join I_SerialNumberMaterialDoc_2 as _SerialNumberMaterialDoc on  _SerialNumberMaterialDoc.MaterialDocumentYear = _MaterialDocItem.MaterialDocumentYear
                                                                            and _SerialNumberMaterialDoc.MaterialDocument     = _MaterialDocItem.MaterialDocument
                                                                            and _SerialNumberMaterialDoc.MaterialDocumentItem = _MaterialDocItem.MaterialDocumentItem

  association [0..1] to I_BusinessUserVH  as _User            on  _User.UserID = $projection.CreatedByUser
  association [0..1] to I_Product         as _Product         on  _Product.Product = $projection.Material
  association [0..1] to I_ProductText     as _ProductText     on  _ProductText.Product  = $projection.Material
                                                              and _ProductText.Language = $session.system_language
  association [0..1] to I_Plant           as _Plant           on  _Plant.Plant = $projection.Plant
  association [0..1] to I_StorageLocation as _StorageLocation on  _StorageLocation.StorageLocation = $projection.StorageLocation
                                                              and _StorageLocation.Plant           = $projection.Plant
  association [0..1] to I_Supplier        as _Supplier        on  _Supplier.Supplier = $projection.Supplier
  association [0..1] to ztmm005           as _ztmm005         on  _ztmm005.material_document_year = $projection.MaterialDocumentYear
                                                              and _ztmm005.material_document      = $projection.MaterialDocument
                                                              and _ztmm005.material_document_item = $projection.MaterialDocumentItem
                                                              and (
                                                                 _ztmm005.serial_number           = $projection.SerialNumber
                                                                 or _ztmm005.serial_number        = ''
                                                               )
{

  key _MaterialDocItem.MaterialDocumentYear,
  key _MaterialDocItem.MaterialDocument,
  key _MaterialDocItem.MaterialDocumentItem,
  key _SerialNumberMaterialDoc.SerialNumber,

      _MaterialDocHeader.DocumentDate,
      _MaterialDocHeader.PostingDate,
      _MaterialDocHeader.MaterialDocumentHeaderText,
      _MaterialDocHeader.CreatedByUser,
      _MaterialDocHeader.CreationDate,

      _MaterialDocItem.GoodsMovementType,
      _MaterialDocItem.Material,
      _MaterialDocItem.Plant,
      _MaterialDocItem.StorageLocation,
      _MaterialDocItem.PurchaseOrder,
      _MaterialDocItem.PurchaseOrderItem,
      _MaterialDocItem.Supplier,

      _MaterialDocItem.QuantityInBaseUnit,
      _MaterialDocItem.MaterialBaseUnit,

      _MaterialDocItem.QuantityInEntryUnit,
      _MaterialDocItem.EntryUnit,

      _MaterialDocItem.ReversedMaterialDocumentYear,
      _MaterialDocItem.ReversedMaterialDocument,
      _MaterialDocItem.ReversedMaterialDocumentItem,

      case when _ztmm005.uuid is not null then 'Y' else 'N' end as IsReversed,

      _User,
      _Product,
      _ProductText,
      _Plant,
      _StorageLocation,
      _Supplier

}
where
     _MaterialDocItem.GoodsMovementType = '102'
  or _MaterialDocItem.GoodsMovementType = '122'
  or _MaterialDocItem.GoodsMovementType = '161'
