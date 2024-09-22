@AbapCatalog.sqlViewName: 'ZPROCUREMENTCOST'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Procurement Cost Report'
define root view ZI_PROCUREMENT_COST
  as select from    I_PurchaseOrderHistoryAPI01 as _POHistory
    left outer join I_PurchaseOrderItemAPI01    as _PurchaseOrderItem on  _PurchaseOrderItem.PurchaseOrder     = _POHistory.PurchaseOrder
                                                                      and _PurchaseOrderItem.PurchaseOrderItem = _POHistory.PurchaseOrderItem
    left outer join I_PurchaseOrderAPI01        as _PurchaseOrder     on _PurchaseOrder.PurchaseOrder = _POHistory.PurchaseOrder

  association [0..1] to I_PurchasingDocumentTypeText   as _PurchaseOrderTypeName  on  _PurchaseOrderTypeName.PurchasingDocumentType     = $projection.PurchaseOrderType
                                                                                  and _PurchaseOrderTypeName.PurchasingDocumentCategory = 'F'
                                                                                  and _PurchaseOrderTypeName.Language                   = $session.system_language
  association [0..1] to I_PurchasingOrganization       as _PurchasingOrganization on  _PurchasingOrganization.PurchasingOrganization = $projection.PurchasingOrganization
  association [0..1] to I_BusinessUserVH               as _CreatedUser            on  _CreatedUser.UserID = $projection.CreatedByUser
  association [0..1] to I_Plant                        as _Plant                  on  _Plant.Plant = $projection.Plant
  association [0..1] to I_Product                      as _Product                on  _Product.Product = $projection.Product
  association [0..1] to I_ProductText                  as _ProductName            on  _ProductName.Product  = $projection.Product
                                                                                  and _ProductName.Language = $session.system_language
  association [0..1] to I_ProductGroupText_2           as _ProductGroupName       on  _ProductGroupName.ProductGroup = $projection.ProductGroup
                                                                                  and _ProductGroupName.Language     = $session.system_language
  association [1..1] to I_MaterialDocumentItem_2       as _MaterialDocumentItem   on  _MaterialDocumentItem.MaterialDocumentYear = $projection.MaterialDocumentYear
                                                                                  and _MaterialDocumentItem.MaterialDocument     = $projection.MaterialDocument
                                                                                  and _MaterialDocumentItem.MaterialDocumentItem = $projection.MaterialDocumentItem
  // Tariff
  association [0..1] to I_PurOrdItmPricingElementAPI01 as _Pricing_ZTX1           on  _Pricing_ZTX1.PurchaseOrder           = $projection.PurchaseOrder
                                                                                  and _Pricing_ZTX1.PurchaseOrderItem       = $projection.PurchaseOrderItem
                                                                                  and _Pricing_ZTX1.ConditionType           = 'ZTX1'
                                                                                  and _Pricing_ZTX1.ConditionInactiveReason = ''
  // Freight ZFR1 ZFRL ZTAR ZTAX
  association [0..1] to I_PurOrdItmPricingElementAPI01 as _Pricing_ZFR1           on  _Pricing_ZFR1.PurchaseOrder           = $projection.PurchaseOrder
                                                                                  and _Pricing_ZFR1.PurchaseOrderItem       = $projection.PurchaseOrderItem
                                                                                  and _Pricing_ZFR1.ConditionType           = 'ZFR1'
                                                                                  and _Pricing_ZFR1.ConditionInactiveReason = ''

  association [0..1] to I_PurOrdItmPricingElementAPI01 as _Pricing_ZFRL           on  _Pricing_ZFRL.PurchaseOrder           = $projection.PurchaseOrder
                                                                                  and _Pricing_ZFRL.PurchaseOrderItem       = $projection.PurchaseOrderItem
                                                                                  and _Pricing_ZFRL.ConditionType           = 'ZFRL'
                                                                                  and _Pricing_ZFRL.ConditionInactiveReason = ''

  association [0..1] to I_PurOrdItmPricingElementAPI01 as _Pricing_ZTAR           on  _Pricing_ZTAR.PurchaseOrder           = $projection.PurchaseOrder
                                                                                  and _Pricing_ZTAR.PurchaseOrderItem       = $projection.PurchaseOrderItem
                                                                                  and _Pricing_ZTAR.ConditionType           = 'ZTAR'
                                                                                  and _Pricing_ZTAR.ConditionInactiveReason = ''

  association [0..1] to I_PurOrdItmPricingElementAPI01 as _Pricing_ZTAX           on  _Pricing_ZTAX.PurchaseOrder           = $projection.PurchaseOrder
                                                                                  and _Pricing_ZTAX.PurchaseOrderItem       = $projection.PurchaseOrderItem
                                                                                  and _Pricing_ZTAX.ConditionType           = 'ZTAX'
                                                                                  and _Pricing_ZTAX.ConditionInactiveReason = ''

{

  key _POHistory.PurchaseOrder,
  key _POHistory.PurchaseOrderItem,
  key _POHistory.PurchasingHistoryDocumentType                             as MaterialDocumentType,
  key _POHistory.PurchasingHistoryDocumentYear                             as MaterialDocumentYear,
  key _POHistory.PurchasingHistoryDocument                                 as MaterialDocument,
  key _POHistory.PurchasingHistoryDocumentItem                             as MaterialDocumentItem,

      _PurchaseOrder.PurchaseOrderType                                     as PurchaseOrderType,
      _PurchaseOrder.PurchasingOrganization                                as PurchasingOrganization,
      _PurchaseOrder.CreatedByUser                                         as CreatedByUser,
      _PurchaseOrder.CreationDate                                          as CreationDate,
      _PurchaseOrder.CorrespncInternalReference                            as ShipmentNumber,

      _PurchaseOrderItem.Plant,
      _PurchaseOrderItem.Material                                          as Product,
      cast(_Product.ProductType as producttype preserving type )           as ProductType,
      cast(_Product.ProductGroup as zzemm015 preserving type )             as ProductGroup,

      @Semantics.unitOfMeasure: true
      _PurchaseOrderItem.PurchaseOrderQuantityUnit                         as QuantityUnit,
      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      _PurchaseOrderItem.OrderQuantity                                     as POQuantity,

      @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
      _POHistory.Quantity                                                  as DeliveryCostQuantity,
      @Semantics.currencyCode:true
      _POHistory.Currency                                                  as LocalCurrency,
      @Semantics.amount.currencyCode: 'LocalCurrency'
      _POHistory.PurOrdAmountInCompanyCodeCrcy                             as ValueReceived,

      cast( case when _Pricing_ZTX1.ConditionAmount is not null
                 then _Pricing_ZTX1.ConditionAmount
                 else 0 end as abap.dec( 15, 2 ) )                         as ConditionAmount_ZTX1,

      cast( case when _Pricing_ZFR1.ConditionAmount is not null
                 then _Pricing_ZFR1.ConditionAmount
                 else 0 end as abap.dec( 15, 2 ) )                         as ConditionAmount_ZFR1,

      cast( case when _Pricing_ZFRL.ConditionAmount is not null
                 then _Pricing_ZFRL.ConditionAmount
                 else 0 end as abap.dec( 15, 2 ) )                         as ConditionAmount_ZFRL,

      cast( case when _Pricing_ZTAR.ConditionAmount is not null
                 then _Pricing_ZTAR.ConditionAmount
                 else 0 end as abap.dec( 15, 2 ) )                         as ConditionAmount_ZTAR,

      cast( case when _Pricing_ZTAX.ConditionAmount is not null
                 then _Pricing_ZTAX.ConditionAmount
                 else 0 end as abap.dec( 15, 2 ) )                         as ConditionAmount_ZTAX,

      division( _POHistory.Quantity, _PurchaseOrderItem.OrderQuantity, 6 ) as Ratio,

      _PurchaseOrderTypeName,
      _PurchasingOrganization,
      _CreatedUser,
      _Plant,
      _Product,
      _ProductName,
      _ProductGroupName,
      _MaterialDocumentItem
}
where
       _POHistory.AccountAssignmentNumber                = '00'
  and  _POHistory.PurchasingHistoryDocumentType          = '1' // Goods Receipt
  and  _POHistory.GoodsMovementType                      = '101'
  and  _PurchaseOrderItem.PurchasingDocumentDeletionCode = ''
  and(
       _Product.ProductType                              = 'FERT'
    or _Product.ProductType                              = 'ZERT'
    or _Product.ProductType                              = 'ERSA'
    or _Product.ProductType                              = 'ZRSA'
  )
