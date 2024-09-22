@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Invoicing Party Report PurOrdItmPricingElementAPI'
define root view entity ZR_SMM015 
    as select from I_PurOrdItmPricingElementAPI01
    
    association [0..1] to I_ConditionTypeText as _ConditionTypeText
    on _ConditionTypeText.ConditionType = $projection.ConditionType
    and _ConditionTypeText.Language = 'E'
    and _ConditionTypeText.ConditionUsage = 'A'
    and _ConditionTypeText.ConditionApplication = 'M'
{
    key PurchaseOrder,
    key PurchaseOrderItem,
    key ConditionType,
    key FreightSupplier,
    _ConditionTypeText.ConditionTypeName,
    TransactionCurrency,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    sum( ConditionAmount ) as ConditionAmount
}
where ConditionInactiveReason = ''
group by PurchaseOrder,PurchaseOrderItem, ConditionType, FreightSupplier, _ConditionTypeText.ConditionTypeName, TransactionCurrency
