@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Shipment PO'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SMM000_AC
  as select distinct from I_PurchaseOrderItemAPI01 as _PurchaseOrderItem

  association [0..1] to I_Product as _Product on _Product.Product = $projection.Material
{

  key _PurchaseOrderItem.PurchaseOrder,
  key _PurchaseOrderItem.PurchaseOrderItem,
      _PurchaseOrderItem.Plant,
      _PurchaseOrderItem.Material,

      _Product
}
where
  _PurchaseOrderItem.AccountAssignmentCategory = ''
