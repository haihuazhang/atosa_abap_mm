@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Cost Report Preprocessing'
define root view entity ZR_SMM017
  as select distinct from    I_ProductPlantBasic            as _ProductPlant
  
  left outer join I_Product as _Product on _Product.Product = _ProductPlant.Product
  
  left outer join I_SerialNumberDeliveryDocument as _SerialNumberDeliveryDocument
  on _SerialNumberDeliveryDocument.Material = _ProductPlant.Product
  
  left outer join ZR_TMM001 on ZR_TMM001.Product = _ProductPlant.Product
  
  left outer join I_PurchaseOrderHistoryAPI01 as _PurchaseOrderHistoryAPI01
  on  _PurchaseOrderHistoryAPI01.Plant = _ProductPlant.Plant
  and _PurchaseOrderHistoryAPI01.Material = _ProductPlant.Product
  
  left outer join I_PurOrdItmPricingElementAPI01 as _PoItmPriceElmtZFR1
  on  _PoItmPriceElmtZFR1.PurchaseOrder = _PurchaseOrderHistoryAPI01.PurchaseOrder
  and _PoItmPriceElmtZFR1.PurchaseOrderItem = _PurchaseOrderHistoryAPI01.PurchaseOrderItem
  and _PoItmPriceElmtZFR1.ConditionType = 'ZFR1'
  
  left outer join I_PurOrdItmPricingElementAPI01 as _PoItmPriceElmtZFRL
  on  _PoItmPriceElmtZFRL.PurchaseOrder = _PurchaseOrderHistoryAPI01.PurchaseOrder
  and _PoItmPriceElmtZFRL.PurchaseOrderItem = _PurchaseOrderHistoryAPI01.PurchaseOrderItem
  and _PoItmPriceElmtZFRL.ConditionType = 'ZFRL'
  
  left outer join I_PurOrdItmPricingElementAPI01 as _PoItmPriceElmtZTAR
  on  _PoItmPriceElmtZTAR.PurchaseOrder = _PurchaseOrderHistoryAPI01.PurchaseOrder
  and _PoItmPriceElmtZTAR.PurchaseOrderItem = _PurchaseOrderHistoryAPI01.PurchaseOrderItem
  and _PoItmPriceElmtZTAR.ConditionType = 'ZTAR'
  
  left outer join I_PurOrdItmPricingElementAPI01 as _PoItmPriceElmtZTAX
  on  _PoItmPriceElmtZTAX.PurchaseOrder = _PurchaseOrderHistoryAPI01.PurchaseOrder
  and _PoItmPriceElmtZTAX.PurchaseOrderItem = _PurchaseOrderHistoryAPI01.PurchaseOrderItem
  and _PoItmPriceElmtZTAX.ConditionType = 'ZTAX'
  
  left outer join I_PurOrdItmPricingElementAPI01 as _PoItmPriceElmtZTX1
  on  _PoItmPriceElmtZTX1.PurchaseOrder = _PurchaseOrderHistoryAPI01.PurchaseOrder
  and _PoItmPriceElmtZTX1.PurchaseOrderItem = _PurchaseOrderHistoryAPI01.PurchaseOrderItem
  and _PoItmPriceElmtZTX1.ConditionType = 'ZTX1'
  
  left outer join I_ProductValuationAcct as _ProductValuationAcct
  on  _ProductValuationAcct.Product = _ProductPlant.Product
  and _ProductValuationAcct.ValuationArea = _ProductPlant.Plant
  
  left outer join I_PurOrdHistDeliveryCostAPI01 as _PurOrdHistDeliveryCostAPI01
  on  _PurOrdHistDeliveryCostAPI01.PurchaseOrder = _PurchaseOrderHistoryAPI01.PurchaseOrder
  and _PurOrdHistDeliveryCostAPI01.PurchaseOrderItem = _PurchaseOrderHistoryAPI01.PurchaseOrderItem
{
    key   _ProductPlant.Plant                                        as Plant,
    key   cast(_Product.ProductType as producttype preserving type ) as ProductType,
    key   _ProductPlant.Product                                      as Product,
    key   case when _PurchaseOrderHistoryAPI01.PurchaseOrder is null
          then ''
          else _PurchaseOrderHistoryAPI01.PurchaseOrder
          end        as PurchaseOrder,
          
    key   case when _SerialNumberDeliveryDocument.SerialNumber is null
          then ''
          else _SerialNumberDeliveryDocument.SerialNumber
          end        as SerialNumber,
    key   case when ZR_TMM001.Zoldserialnumber is null
          then ''
          else ZR_TMM001.Zoldserialnumber
          end        as OriginalSerialNumber,
    
    case when _PurchaseOrderHistoryAPI01.Currency is null
    then cast('USD'  as waers)
    else _PurchaseOrderHistoryAPI01.Currency
    end              as LocalCurrency,
    
    @Semantics.amount.currencyCode: 'LocalCurrency'
    case when _PoItmPriceElmtZFR1.ConditionAmount is null
    then cast(0 as abap.curr( 15, 2 ))
    else _PoItmPriceElmtZFR1.ConditionAmount
    end              as SeaFreight,
    
    @Semantics.amount.currencyCode: 'LocalCurrency'
    case when _PoItmPriceElmtZFRL.ConditionAmount is null
    then cast(0 as abap.curr( 15, 2 ))
    else _PoItmPriceElmtZFRL.ConditionAmount
    end              as LastMile,
    
    @Semantics.amount.currencyCode: 'LocalCurrency'
    case when _PoItmPriceElmtZTAR.ConditionAmount is null
    then cast(0 as abap.curr( 15, 2 ))
    else _PoItmPriceElmtZTAR.ConditionAmount
    end              as DocumentsFee,
    
    @Semantics.amount.currencyCode: 'LocalCurrency'
    case when _PoItmPriceElmtZFRL.ConditionAmount is null
    then cast(0 as abap.curr( 15, 2 ))
    else _PoItmPriceElmtZFRL.ConditionAmount
    end              as Insurance,
    
    @Semantics.amount.currencyCode: 'LocalCurrency'
    case when _PurchaseOrderHistoryAPI01.PurOrdAmountInCompanyCodeCrcy is null
    then cast(0 as abap.curr( 15, 2 ))
    else _PurchaseOrderHistoryAPI01.PurOrdAmountInCompanyCodeCrcy
    end              as ValueReceived,
    
    @Semantics.amount.currencyCode: 'LocalCurrency'
    case when _PoItmPriceElmtZTX1.ConditionAmount is null
    then cast(0 as abap.curr( 15, 2 ))
    else _PoItmPriceElmtZTX1.ConditionAmount
    end              as Tariff,
    
    @Semantics.amount.currencyCode: 'LocalCurrency'
    case when _ProductValuationAcct.MvgAvgPriceInPreviousPeriod is null
    then cast(0 as abap.curr( 15, 2 ))
    else _ProductValuationAcct.MvgAvgPriceInPreviousPeriod
    end as MvgAvgPriceInPreviousPeriod,
    
    case when _PurOrdHistDeliveryCostAPI01.PostingDate is null
    then cast('00010101' as budat)
    else _PurOrdHistDeliveryCostAPI01.PostingDate
    end as PostingDate
    
}
