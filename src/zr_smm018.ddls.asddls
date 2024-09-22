@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Cost Report Preprocessing'
define root view entity ZR_SMM018 
    as select distinct from I_MaterialDocumentItem_2 as _MaterialDocumentItem
    
    left outer join I_DeliveryDocumentItem as _DeliveryDocumentItem
    on  _DeliveryDocumentItem.DeliveryDocument = _MaterialDocumentItem.DeliveryDocument
    and _DeliveryDocumentItem.DeliveryDocumentItem = _MaterialDocumentItem.DeliveryDocumentItem
    
    inner join I_DeliveryDocument as _DeliveryDocument
    on _DeliveryDocumentItem.DeliveryDocument = _DeliveryDocument.DeliveryDocument
    
    left outer join I_SerialNumberMaterialDoc_2 as _SerialNumberMaterialDoc
    on  _SerialNumberMaterialDoc.MaterialDocumentYear = _MaterialDocumentItem.MaterialDocumentYear
    and _SerialNumberMaterialDoc.MaterialDocument = _MaterialDocumentItem.MaterialDocument
    and _SerialNumberMaterialDoc.MaterialDocumentItem = _MaterialDocumentItem.MaterialDocumentItem
    
    left outer join I_Product as _Product
    on _Product.Product = _MaterialDocumentItem.Material
  
    left outer join ZR_TMM003
    on  ZR_TMM003.Material = _Product.ProductExternalID
    and ZR_TMM003.SerialNumber = _SerialNumberMaterialDoc.SerialNumber
    
    left outer join I_SalesDocItemPricingElement as _SalesDocItemPricingElement
    on  _SalesDocItemPricingElement.SalesDocument = _DeliveryDocumentItem.ReferenceSDDocument
    and _SalesDocItemPricingElement.SalesDocumentItem = _DeliveryDocumentItem.ReferenceSDDocumentItem
    and _SalesDocItemPricingElement.ConditionType = 'PCIP'
    
    left outer join I_PurOrdItmPricingElementAPI01 as _PoItmPriceElmtPPR0
    on  _PoItmPriceElmtPPR0.PurchaseOrder = ZR_TMM003.PurchaseOrder
    and _PoItmPriceElmtPPR0.PurchaseOrderItem = ZR_TMM003.PurchaseOrderItem
    and ( _PoItmPriceElmtPPR0.ConditionType = 'PPR0'
         or _PoItmPriceElmtPPR0.ConditionType = 'PMP0' )
    
    left outer join I_PurOrdItmPricingElementAPI01 as _PoItmPriceElmtZTX1
    on _PoItmPriceElmtZTX1.PurchaseOrder = ZR_TMM003.PurchaseOrder
    and _PoItmPriceElmtZTX1.PurchaseOrderItem = ZR_TMM003.PurchaseOrderItem
    and _PoItmPriceElmtZTX1.ConditionType = 'ZTX1'
    
    left outer join ZR_TMM004
    on  ZR_TMM004.Plant = _MaterialDocumentItem.Plant
    and ZR_TMM004.Material = _MaterialDocumentItem.Material
    and ZR_TMM004.SerialNumber = _SerialNumberMaterialDoc.SerialNumber

{
    key _MaterialDocumentItem.Plant                as Plant,
    key cast( _Product.ProductType as producttype preserving type ) as ProductType,
    key _MaterialDocumentItem.MaterialDocument     as MaterialDocument,
    key _MaterialDocumentItem.MaterialDocumentItem as MaterialDocumentItem,
    key _MaterialDocumentItem.Material             as Product,
    key _DeliveryDocumentItem.ReferenceSDDocument as SalesOrder,
    key _DeliveryDocumentItem.ReferenceSDDocumentItem as SalesOrderItem,
    key _SerialNumberMaterialDoc.SerialNumber as SerialNumber,
    
    key _MaterialDocumentItem.GoodsMovementType,
    
    key _MaterialDocumentItem.DeliveryDocument as DeliveryDocument,
    key _MaterialDocumentItem.DeliveryDocumentItem as DeliveryDocumentItem,
    
    _SalesDocItemPricingElement._SalesDocument.SalesOrganization as SalesOrganization,
    
    _MaterialDocumentItem.DebitCreditCode,
    
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    case when _SalesDocItemPricingElement.ConditionRateValue is null
    then cast(0 as abap.dec( 13, 2 ))
    else 
        case when _MaterialDocumentItem.DebitCreditCode = 'H'
        then cast(abs(_SalesDocItemPricingElement.ConditionRateValue) as abap.dec( 13, 2) )
        when _MaterialDocumentItem.DebitCreditCode = 'S'
        then cast(-1 * _SalesDocItemPricingElement.ConditionRateValue as abap.dec( 13, 2) )
        else cast(_SalesDocItemPricingElement.ConditionRateValue as abap.dec( 13, 2) )
        end
    end  as SalesCost,
    _SalesDocItemPricingElement.TransactionCurrency,
    
    case when ZR_TMM003.PurchaseOrder is null
    then ''
    else ZR_TMM003.PurchaseOrder
    end  as PurchaseOrder,
    
    case when ZR_TMM003.PurchaseOrderItem is null
    then cast( '' as abap.numc( 5 ))
    else ZR_TMM003.PurchaseOrderItem
    end  as PurchaseOrderItem,
    
    case when ZR_TMM003.ShipmentNumber is null
    then ''
    else ZR_TMM003.ShipmentNumber
    end  as ShipmentNumber,
    
    case when ZR_TMM004.ValueReceived is null
    then cast(0 as abap.dec( 13, 2 ))
    else ZR_TMM004.ValueReceived
    end as ValueReceived,
    
    case when ZR_TMM004.Tariff is null
    then cast(0 as abap.dec( 13, 2 ))
    else ZR_TMM004.Tariff
    end as Tariff,
    
    @Semantics.amount.currencyCode: 'ConditionCurrency'
    case when _PoItmPriceElmtPPR0.ConditionRateValue is not null
    then cast(_PoItmPriceElmtPPR0.ConditionRateValue as abap.dec( 13,2 ))
    else cast( 0 as abap.dec( 13,2 ) )
    end as PurchaseCost,
            
    _PoItmPriceElmtPPR0.ConditionCurrency as ConditionCurrency,
    
    @Semantics.amount.currencyCode: 'ConditionCurrencyZTX1'
    case when _PoItmPriceElmtZTX1.ConditionAmount is not null
    then cast(_PoItmPriceElmtZTX1.ConditionAmount as abap.dec( 13, 2 ))
    else cast( 0 as abap.dec( 13,2 ) )
    end as ConditionAmount,
    _PoItmPriceElmtZTX1.ConditionCurrency as ConditionCurrencyZTX1,
    
    @Semantics.quantity.unitOfMeasure: 'PurchaseOrderQuantityUnit'     
    case when _PoItmPriceElmtZTX1._PurchaseOrderItem.OrderQuantity is not null
    then _PoItmPriceElmtZTX1._PurchaseOrderItem.OrderQuantity
    else cast( 1 as abap.quan( 13,2 ) )
    end as OrderQuantity,
    _PoItmPriceElmtZTX1._PurchaseOrderItem.PurchaseOrderQuantityUnit,
     
     _DeliveryDocument.CreatedByUser as CreatedByUser,
     _DeliveryDocument.CreationDate as CreationDate,
     _DeliveryDocument.ActualGoodsMovementDate as PostingDate
}
where _MaterialDocumentItem.GoodsMovementType = '601'
   or _MaterialDocumentItem.GoodsMovementType = '602'
   or _MaterialDocumentItem.GoodsMovementType = '657'
   or _MaterialDocumentItem.GoodsMovementType = '658'
