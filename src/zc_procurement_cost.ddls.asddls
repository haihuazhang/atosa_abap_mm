@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Procurement Cost Report'
@UI: {
    headerInfo: {
        typeNamePlural: 'Results',
        title: {
            type: #STANDARD,
            value: 'ProductType'
        },
        description: {
            value: 'Product'
        }
    },
    presentationVariant: [{
        sortOrder: [{
            by: 'PurchaseOrder',
            direction: #ASC
        },{
            by: 'PurchaseOrderItem',
            direction: #ASC
        }]
    }]
}
define root view entity ZC_PROCUREMENT_COST
  provider contract transactional_query
  as projection on ZI_PROCUREMENT_COST1
{
        @UI.facet: [
            {
              label: 'General Information',
              id: 'GeneralInfo',
              type: #COLLECTION,
              position: 10
            },
            {
              label: 'General',
              type: #IDENTIFICATION_REFERENCE,
              purpose: #STANDARD,
              parentId: 'GeneralInfo',
              position: 10
            },
            {
              label: 'Quantity & Cost',
              type: #FIELDGROUP_REFERENCE,
              purpose: #STANDARD,
              parentId: 'GeneralInfo',
              position: 20,
              targetQualifier: 'QuantityCostGroup'
            },
            {
              label: 'Dates',
              type: #FIELDGROUP_REFERENCE,
              purpose: #STANDARD,
              parentId: 'GeneralInfo',
              position: 30,
              targetQualifier: 'DatesGroup'
            }
          ]

        @UI:{ lineItem:[ { position: 40, importance: #MEDIUM, label: 'Purchase Order' } ],
              selectionField: [{ position: 30 }],
              identification: [{ position: 30, label: 'Purchase Order' }] }
        @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PurchaseOrderAPI01', element: 'PurchaseOrder' }}]
  key   PurchaseOrder,

        @UI:{ lineItem:[ { position: 50, importance: #MEDIUM, label: 'Purchase Order Item' } ],
              identification: [{ position: 40, label: 'Purchase Order Item' }] }
  key   PurchaseOrderItem,

  key   MaterialDocumentType,
  key   MaterialDocumentYear,

        @UI:{ lineItem:[ { position: 120, importance: #MEDIUM, label: 'Material Document' } ],
              identification: [{ position: 50, label: 'Material Document' }] }
  key   MaterialDocument,

        @UI:{ lineItem:[ { position: 130, importance: #MEDIUM, label: 'Material Document Item' } ],
              identification: [{ position: 60, label: 'Material Document Item' }] }
  key   MaterialDocumentItem,

        @UI:{ lineItem:[ { position: 10, importance: #MEDIUM, label: 'Material Type' } ],
              identification: [{ position: 10, label: 'Material Type' }] }
        ProductType,

        @UI:{ selectionField: [{ position: 10 }] }
        @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Plant', element: 'Plant' }}]
        @Consumption.filter.mandatory: true
        @ObjectModel.text.element: [ 'PlantName' ]
        Plant,

        @UI:{ lineItem:[ { position: 20, importance: #MEDIUM, label: 'Material Number' } ],
              selectionField: [{ position: 20 }] }
        @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductPlantBasic', element: 'Product' }}]
        @ObjectModel.text.element: [ 'ProductName' ]
        Product,

        @UI:{ lineItem:[ { position: 25, importance: #MEDIUM, label: 'Material Group' } ],
              selectionField: [{ position: 25 }],
              identification: [{ position: 25, label: 'Material Group' }] }
        @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductGroup_2', element: 'ProductGroup' }}]
        @ObjectModel.text.element: [ 'ProductGroupName' ]
        @EndUserText.label: 'Material Group'
        ProductGroup,

        @UI:{ lineItem:[ { position: 60, importance: #MEDIUM, label: 'PO Quantity' } ],
              fieldGroup: [{ qualifier: 'QuantityCostGroup', position: 10, label: 'PO Quantity' }] }
        POQuantity,

        @UI:{ lineItem:[ { position: 70, importance: #MEDIUM, label: 'Delivery Cost Quantity' } ],
              fieldGroup: [{ qualifier: 'QuantityCostGroup', position: 20, label: 'Delivery Cost Quantity' }] }
        DeliveryCostQuantity,

        @UI:{ lineItem:[ { position: 75, importance: #MEDIUM, label: 'Total Cost' } ],
                      fieldGroup: [{ qualifier: 'QuantityCostGroup', position: 25, label: 'Total Cost' }] }
        TotalCost,

        @UI:{ lineItem:[ { position: 80, importance: #MEDIUM, label: 'Value Received' } ],
              fieldGroup: [{ qualifier: 'QuantityCostGroup', position: 30, label: 'Value Received' }] }
        ValueReceived,

        @UI:{ lineItem:[ { position: 90, importance: #MEDIUM, label: 'Delivery Cost' } ],
              fieldGroup: [{ qualifier: 'QuantityCostGroup', position: 40, label: 'Delivery Cost' }] }
        DeliveryCost,

        @UI:{ lineItem:[ { position: 100, importance: #MEDIUM, label: 'Freight' } ],
              fieldGroup: [{ qualifier: 'QuantityCostGroup', position: 50, label: 'Freight' }] }
        Freight,

        @UI:{ lineItem:[ { position: 110, importance: #MEDIUM, label: 'Tariff' } ],
              fieldGroup: [{ qualifier: 'QuantityCostGroup', position: 60, label: 'Tariff' }] }
        Tariff,

        @UI:{ lineItem:[ { position: 30, importance: #MEDIUM, label: 'PO Type' } ],
              identification: [{ position: 20, label: 'PO Type' }] }
        @ObjectModel.text.element: [ 'PurchasingDocumentTypeName' ]
        PurchaseOrderType,

        @UI:{ lineItem:[ { position: 35, importance: #MEDIUM, label: 'Shipment Number' } ],
              identification: [{ position: 25, label: 'Shipment Number' }] }
        ShipmentNumber,

        @UI:{ lineItem:[ { position: 140, importance: #MEDIUM, label: 'Posting Date' } ],
              selectionField: [{ position: 50 }],
              fieldGroup: [{ qualifier: 'DatesGroup', position: 10, label: 'Posting Date' }] }
        @Consumption.filter.mandatory: true
        _MaterialDocumentItem.PostingDate,

        @UI:{ lineItem:[ { position: 150, importance: #MEDIUM, label: 'Creation Date' } ],
              fieldGroup: [{ qualifier: 'DatesGroup', position: 20, label: 'Creation Date' }] }
        CreationDate,

        @UI:{ lineItem:[ { position: 160, importance: #MEDIUM, label: 'Created By' } ],
              fieldGroup: [{ qualifier: 'DatesGroup', position: 30, label: 'Created By' }] }
        @ObjectModel.text.element: [ 'PersonFullName' ]
        CreatedByUser,

        @UI.selectionField: [{ position: 40 }]
        @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PurchasingOrganization', element: 'PurchasingOrganization' }}]
        @Consumption.filter.mandatory: true
        @ObjectModel.text.element: [ 'PurchasingOrganizationName' ]
        PurchasingOrganization,

        @UI.hidden: true
        QuantityUnit,
        @UI.hidden: true
        LocalCurrency,
        @UI.hidden: true
        _PurchaseOrderTypeName.PurchasingDocumentTypeName,
        @UI.hidden: true
        _PurchasingOrganization.PurchasingOrganizationName,
        @UI.hidden: true
        _CreatedUser.PersonFullName,
        @UI.hidden: true
        _Plant.PlantName,
        @UI.hidden: true
        _ProductGroupName.ProductGroupName,
        @UI.hidden: true
        _ProductName.ProductName,

        _Product
}
