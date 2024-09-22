@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Invoicing Party Report Item'
define root view entity ZR_SMM014 
    as select from I_PurchaseOrderAPI01 as _PurchaseOrderAPI01
    
    inner join I_PurchaseOrderItemAPI01 as _PurchaseOrderItemAPI01
    on _PurchaseOrderAPI01.PurchaseOrder = _PurchaseOrderItemAPI01.PurchaseOrder
    
    association [0..1] to ZR_SMM013 as _ScheduleLineDeliveryDate
    on _PurchaseOrderItemAPI01.PurchaseOrder = _ScheduleLineDeliveryDate.PurchaseOrder
    and _PurchaseOrderItemAPI01.PurchaseOrderItem = _ScheduleLineDeliveryDate.PurchaseOrderItem
    
    association [0..*] to ZR_SMM015
    on ZR_SMM015.PurchaseOrder = _PurchaseOrderItemAPI01.PurchaseOrder
    and ZR_SMM015.PurchaseOrderItem = _PurchaseOrderItemAPI01.PurchaseOrderItem
    
    association [0..1] to I_Product as _Product
    on _Product.Product = _PurchaseOrderItemAPI01.Material
    
{
    key _PurchaseOrderAPI01.PurchaseOrder,
    key _PurchaseOrderItemAPI01.PurchaseOrderItem,
    key concat_with_space( ZR_SMM015.ConditionType,concat_with_space( '-',ZR_SMM015.ConditionTypeName, 1), 1 ) as ConditionTypeName,
    key _PurchaseOrderItemAPI01.Plant,
    case when ZR_SMM015.ConditionType = 'PPR0' or ZR_SMM015.ConditionType = 'PMP0'
    then _PurchaseOrderAPI01.Supplier
    else ZR_SMM015.FreightSupplier
    end as ConditionInvoicingParty,
    _PurchaseOrderAPI01.Supplier,
    _PurchaseOrderAPI01.PurchasingOrganization,
    _PurchaseOrderAPI01.CompanyCode,
    _PurchaseOrderAPI01.PurchaseOrderDate,
    _PurchaseOrderAPI01.CreatedByUser,
    _PurchaseOrderAPI01.CreationDate,
    _ScheduleLineDeliveryDate.ScheduleLineDeliveryDate,
    _PurchaseOrderAPI01.CorrespncExternalReference,
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    ZR_SMM015.ConditionAmount,
    ZR_SMM015.TransactionCurrency,
    
    _PurchaseOrderItemAPI01.Material,
    _Product
}
