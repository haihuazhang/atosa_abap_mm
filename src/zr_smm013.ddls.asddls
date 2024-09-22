@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Invoicing Party Report ScheduleLineDeliveryDate'
define root view entity ZR_SMM013 
    as select from I_PurOrdScheduleLineAPI01
{
    key PurchaseOrder,
    key PurchaseOrderItem,
    max( ScheduleLineDeliveryDate ) as ScheduleLineDeliveryDate
}
group by PurchaseOrder,PurchaseOrderItem
