@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Shipment Document Header from PO'
define root view entity ZR_SMM001
  as select from ZR_SMM000            as _SMM000
    join         I_PurchaseOrderAPI01 as _PurchaseOrder on _PurchaseOrder.PurchaseOrder = _SMM000.PurchaseOrder
  association [0..1] to I_PurchasingDocumentTypeText as _PurchaseOrderTypeText  on  _PurchaseOrderTypeText.PurchasingDocumentType     = $projection.PurchaseOrderType
                                                                                and _PurchaseOrderTypeText.PurchasingDocumentCategory = 'F'
                                                                                and _PurchaseOrderTypeText.Language                   = $session.system_language
  association [0..1] to I_Supplier                   as _Supplier               on  _Supplier.Supplier = $projection.Supplier
  association [0..1] to I_PurchasingOrganization     as _PurchasingOrganization on  _PurchasingOrganization.PurchasingOrganization = $projection.PurchasingOrganization
                                                                                and _PurchasingOrganization.CompanyCode            = $projection.CompanyCode
  association [0..1] to I_PurchasingGroup            as _PurchasingGroup        on  _PurchasingGroup.PurchasingGroup = $projection.PurchasingGroup
  association [0..1] to I_CompanyCode                as _CompanyCode            on  _CompanyCode.CompanyCode = $projection.CompanyCode
  association [0..1] to I_BusinessUserVH             as _User                   on  _User.UserID = $projection.CreatedByUser
  composition [0..*] of ZR_SMM002                    as _ShipmentItem
  composition [0..*] of ZR_SMM003                    as _ShipmentContainer
{

  key _PurchaseOrder.PurchaseOrder,
      _PurchaseOrder.PurchaseOrderType,
      _PurchaseOrder.CorrespncExternalReference as ShipmentDocument,
      _PurchaseOrder.Supplier,
      _PurchaseOrder.PurchasingOrganization,
      _PurchaseOrder.PurchasingGroup,
      _PurchaseOrder.CompanyCode,
      _PurchaseOrder.PurchaseOrderDate,
      _PurchaseOrder.CreatedByUser,
      _PurchaseOrder.CreationDate,

      /* Associations */
      _PurchaseOrderTypeText,
      _Supplier,
      _PurchasingOrganization,
      _PurchasingGroup,
      _CompanyCode,
      _User,

      _ShipmentItem,
      _ShipmentContainer
}
