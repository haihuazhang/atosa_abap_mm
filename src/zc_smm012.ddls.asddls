@EndUserText.label: 'PO Invoicing Party Report'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Search.searchable: true
@UI: {
    headerInfo: {
        typeNamePlural: 'Results'
    }
}
define root view entity ZC_SMM012
    provider contract transactional_query
    as projection on ZR_SMM012
{
    @UI:{
        lineItem: [ { position: 1,
                      importance: #HIGH,
                      label: 'Purchase Order' } ],
        selectionField: [{ position: 1 }]
    }
    @EndUserText.label: 'Purchase Order'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PurchaseOrderAPI01', element: 'PurchaseOrder' }}]
    key PurchaseOrder,
//    @UI.hidden: true
//    key PurchaseOrderItem,
    @UI:{
        lineItem: [ { position: 6,
                      importance: #HIGH,
                      label: 'Condition Type' } ]
    }
    @EndUserText.label: 'Condition Type'
    key ConditionTypeName,
    @UI:{
        lineItem: [ { position: 5,
                      importance: #HIGH,
                      label: 'Plant' } ],
        selectionField: [{ position: 5 }]
    }
    @EndUserText.label: 'Plant'
    key Plant,
    @UI:{
        lineItem: [ { position: 2,
                      importance: #HIGH,
                      label: 'Purchase Order Date' } ],
        selectionField: [{ position: 6 }]
    }
    @EndUserText.label: 'Purchase Order Date'
    key PurchaseOrderDate,
    @UI:{
        lineItem: [ { position: 3,
                      importance: #HIGH,
                      label: 'Delivery Date' } ]
    }
    @EndUserText.label: 'Delivery Date'
    key ScheduleLineDeliveryDate,
    @UI:{
        lineItem: [ { position: 7,
                      importance: #HIGH,
                      label: 'Condition Invoicing Party' } ]
    }
    @EndUserText.label: 'Condition Invoicing Party'
    ConditionInvoicingParty,
    @UI.selectionField: [{ position: 2 }]
    @EndUserText.label: 'Supplier'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PurchaseOrderAPI01', element: 'Supplier' }}]
    Supplier,
    @UI.selectionField: [{ position: 3 }]
    @EndUserText.label: 'Purchasing Organization'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PurchaseOrderAPI01', element: 'PurchasingOrganization' }}]
    PurchasingOrganization,
    @UI.selectionField: [{ position: 4 }]
    @EndUserText.label: 'Company Code'
    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PurchaseOrderAPI01', element: 'CompanyCode' }}]
    CompanyCode,
    
    
    @UI:{
        lineItem: [ { position: 4,
                      importance: #HIGH,
                      label: 'Shipment No.' } ]
    }
    @EndUserText.label: 'Shipment No.'
    CorrespncExternalReference,
    
    
    
    @UI:{
        lineItem: [ { position: 8,
                      importance: #HIGH,
                      label: 'Invoicing Party Name' } ]
    }
    @EndUserText.label: 'Invoicing Party Name'
    BusinessPartnerName,
    @UI:{
        lineItem: [ { position: 9,
                      importance: #HIGH,
                      label: 'Condition Amount' } ]
    }
    @EndUserText.label: 'Condition Amount'
    ConditionAmount,
    @UI.hidden: true
    TransactionCurrency,
    @UI.selectionField: [{ position: 7 }]
    @EndUserText.label: 'Created By'
    CreatedByUser,
    @UI.selectionField: [{ position: 8 }]
    @EndUserText.label: 'Created On'
    CreationDate
}
