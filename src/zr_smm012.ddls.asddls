@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Invoicing Party Report'
define root view entity ZR_SMM012 
    as select from ZR_SMM014

    association [0..1] to I_BusinessPartner as _BusinessPartner
    on ZR_SMM014.ConditionInvoicingParty = _BusinessPartner.BusinessPartner
{
    key PurchaseOrder,
    key ConditionTypeName,
    key Plant,
    key PurchaseOrderDate,
    key ScheduleLineDeliveryDate,
    ConditionInvoicingParty,
    Supplier,
    PurchasingOrganization,
    CompanyCode,
    
    CreatedByUser,
    CreationDate,
    
    CorrespncExternalReference,
    _BusinessPartner.BusinessPartnerName,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    sum( ConditionAmount ) as ConditionAmount,
    TransactionCurrency
}
where ConditionAmount <> 0 and ConditionAmount is not null
group by PurchaseOrder,ConditionTypeName,Plant,
        ConditionInvoicingParty,Supplier,PurchasingOrganization,
        CompanyCode,PurchaseOrderDate,CreatedByUser,CreationDate,
        ScheduleLineDeliveryDate,CorrespncExternalReference,_BusinessPartner.BusinessPartnerName,
        TransactionCurrency
