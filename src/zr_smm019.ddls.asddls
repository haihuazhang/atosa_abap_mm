@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Variance for Container'
define root view entity ZR_SMM019
  as select from I_PurchaseOrderAPI01     as _PurchaseOrder
    inner join   I_PurchaseOrderItemAPI01 as _PurchaseOrderItem on _PurchaseOrderItem.PurchaseOrder = _PurchaseOrder.PurchaseOrder

  association [0..1] to I_CompanyCode            as _CompanyCode            on  _CompanyCode.CompanyCode = $projection.CompanyCode
  association [0..1] to I_Supplier               as _Supplier               on  _Supplier.Supplier = $projection.Supplier
  association [0..1] to I_PurchasingOrganization as _PurchasingOrganization on  _PurchasingOrganization.PurchasingOrganization = $projection.PurchasingOrganization
                                                                            and _PurchasingOrganization.CompanyCode            = $projection.CompanyCode
  association [0..1] to I_PurchasingGroup        as _PurchasingGroup        on  _PurchasingGroup.PurchasingGroup = $projection.PurchasingGroup
  association [0..1] to I_BusinessUserVH         as _User                   on  _User.UserID = $projection.CreatedByUser
  association [0..1] to I_Plant                  as _Plant                  on  _Plant.Plant = $projection.Plant
  association [0..1] to I_Product                as _Product                on  _Product.Product = $projection.Material
  association [0..1] to I_ProductText            as _ProductText            on  _ProductText.Product  = $projection.Material
                                                                            and _ProductText.Language = $session.system_language
{
  key _PurchaseOrder.PurchaseOrder,
  key _PurchaseOrderItem.PurchaseOrderItem,

      upper( _PurchaseOrder.CorrespncExternalReference ) as ShipmentNumber,
      _PurchaseOrder.CompanyCode,
      _PurchaseOrder.Supplier,
      _PurchaseOrder.PurchasingOrganization,
      _PurchaseOrder.PurchasingGroup,
      _PurchaseOrder.PurchaseOrderDate,
      _PurchaseOrder.CreatedByUser,
      _PurchaseOrder.CreationDate,

      _PurchaseOrderItem.Plant,
      _PurchaseOrderItem.Material,
      @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'
      _PurchaseOrderItem.OrderQuantity,
      _PurchaseOrderItem.PurchaseOrderQuantityUnit,

      // association
      _CompanyCode,
      _Supplier,
      _PurchasingOrganization,
      _PurchasingGroup,
      _User,
      _Plant,
      _Product,
      _ProductText
}
