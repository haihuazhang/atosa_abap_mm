//&---------------------------------------------------------------------*
//&CDS名称/CDS Name              : ZC_SMM006
//&CDS描述/CDS Des.              : Sales Cost Report Consumption View
//&CDS版本/CDS Ver.              : V.10
//&申请单位/Applicant            :  Atosa
//&申请人/Applicant              : Alexis/Aang.Luo
//&申请日期/Date of App          : 2023-11-27
//&开发单位/Development Company  : HAND
//&作者/Author                   : Zonghua.Bai
//&完成日期/Completion Date      : 2023-11-27
//&---------------------------------------------------------------------*
//&-----------------------------abstract/摘要：
//&   1. Business backgroud/业务背景
//&      1).Material Purchase Order Receipt Analysis
//&   2. Usage scenario/使用场景
//&      1). Analysts view material inventory and purchase order status
//&   3. Lnvoling data sources/涉及数据源
//&       1). ZC_SMM006
//&   4.  CDS Design：
//&       1). ZR_SMM006 root view
//&       2). UI fields
//&       3). root view entity
//&       4). Key plant/ProductType/productor/Po/PoItem/MaterialDocument/MaterialDocumentItem
//&   5.  Code specification/代码规范
//&       遵循 《汉得SAP标准化程序开发规范 V2.0》；
//&   6.  Code changes/代码更改
//&       个人代码更改点为如下代码片段（非此片段不能更改）：
//&   7.  Code annotation/代码注释
//&       Comprehensive and concise annotations (single line, within 25 words);
//&       注释全面、简洁明了（单行，字数25以内）；
//&---------------------------------------------------------------------*
//&Change record/变更记录：
//& Date        Developer           ReqNo         Descriptions
//& ==========  ==================  ============  ======================*
//& 2023-11-24  Zonghua.Bai（Hand）  X7UK900360    Initial development
//&---------------------------------------------------------------------*
@EndUserText.label: 'Sales Cost Report'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@UI: {
    headerInfo: {
        typeNamePlural: 'Results',
        title: {
            type: #STANDARD,
            value: 'Plant'
        },
        description: {
            value: 'Product'
        }
    }
    ,
    presentationVariant: [{
        sortOrder: [{
            by: 'Plant',
            direction: #ASC
        },{
            by: 'Product',
            direction: #ASC
        },{
            by: 'SalesOrder',
            direction: #ASC
        },{
            by: 'SalesOrderItem',
            direction: #ASC
        }]
    }]
}
@Search.searchable: true
define root view entity ZC_SMM006
  provider contract transactional_query
  as projection on ZR_SMM006
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
             
         @UI:{ lineItem:[ { position: 10, importance: #HIGH, label: 'Material Type' } ],
               selectionField: [{ position: 20 }],
               identification: [{ position: 10, label: 'Material Type' }] }
         @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Producttype', element: 'ProductType' }}]
         @EndUserText.label: 'Material Type'
  key    ProductType,
         
         @UI:{ lineItem:[ { position: 11, importance: #HIGH, label: 'Material Document' } ],
               identification: [{ position: 11, label: 'Material Document' }] }
         @EndUserText.label: 'Material Document'
  key    MaterialDocument,
         
         @UI:{ lineItem:[ { position: 12, importance: #HIGH, label: 'Material Document Item' } ],
               identification: [{ position: 12, label: 'Material Document Item' }] }
         @EndUserText.label: 'Material Document Item'
  key    MaterialDocumentItem,
  
        @UI:{ lineItem:[ { position: 20, importance: #HIGH, label: 'Goods Movement Type' } ],
               identification: [{ position: 20, label: 'Goods Movement Type' }] }
         @Consumption.valueHelpDefinition: [{ entity: { name: 'I_DeliveryDocumentItem', element: 'GoodsMovementType' }}]
         @EndUserText.label: 'Goods Movement Type'
  key    GoodsMovementType,
  
         @UI:{ lineItem:[ { position: 30, importance: #HIGH, label: 'Plant' } ],
               selectionField: [{ position: 10 }],
               identification: [{ position: 30, label: 'Plant' }] }
         @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Plant', element: 'Plant' }}]
         //        @Consumption.filter.mandatory: true
         @Search.defaultSearchElement:true
         @EndUserText.label: 'Plant'
  key    Plant,

         @UI:{ lineItem:[ { position: 40, importance: #HIGH, label: 'Material No.' } ],
               identification: [{ position: 40, label: 'Material No.' }],
               selectionField: [{ position: 30 }] }
         @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductPlantBasic', element: 'Product' }}]
         @EndUserText.label: 'Material No.'
  key    Product,
  
         @UI:{ lineItem:[ { position: 50, importance: #HIGH, label: 'SerialNumber' } ],
               identification: [{ position: 50, label: 'SerialNumber' }]}
         //              @Search.defaultSearchElement:true
         @EndUserText.label: 'SerialNumber'
  key    SerialNumber,
  
         @UI:{ lineItem:[ { position: 60, importance: #HIGH, label: 'DN Number' } ],
               identification: [{ position: 60, label: 'DN Number' }]}
  key    DeliveryDocument,

         @UI:{ lineItem:[ { position: 70, importance: #HIGH, label: 'DN Item' } ],
             identification: [{ position: 70, label: 'DN Item' }]}
         @EndUserText.label: 'DN Item'
  key    DeliveryDocumentItem,

         @UI:{ lineItem:[ { position: 80, importance: #HIGH, label: 'Sales Order' } ],
               identification: [{ position: 80, label: 'Sales Order' }],
               selectionField: [{ position: 40  }] }
         @Consumption.valueHelpDefinition: [{ entity: { name: 'I_SalesDocumentStdVH', element: 'SalesDocument' }}]
         @EndUserText.label: 'Sales Order'
  key    SalesOrder,

         @UI:{ lineItem:[ { position: 90, importance: #HIGH, label: 'Sales Order Item' } ],
               identification: [{ position: 90, label: 'Sales Order Item' }]}
         @EndUserText.label: 'Sales Order Item'
  key    SalesOrderItem,
 
         @UI:{ lineItem:[ { position: 100, importance: #HIGH, label: 'Sales Organization' } ],
               identification: [{ position: 100, label: 'Sales Organization' }],
               selectionField: [{ position: 60  }] }
         @Consumption.valueHelpDefinition: [{ entity: { name: 'I_SalesOrganization', element: 'SalesOrganization' }}]
         @EndUserText.label: 'Sales Organization'
         SalesOrganization,

         @UI:{ lineItem:[ { position: 110, importance: #HIGH, label: 'Sales Cost' } ],
             identification: [{ position: 110, label: 'Sales Cost' }]}
         @EndUserText.label: 'Sales Cost'
         SalesCost,

         @UI:{ lineItem:[ { position: 120, importance: #HIGH, label: 'Shipment Document Number' } ],
         identification: [{ position: 120, label: 'Shipment Document Number' }]}
         @EndUserText.label: 'Shipment Document Number'
         ShipmentNumber,

         @UI:{ lineItem:[ { position: 130, importance: #HIGH, label: 'PO Number' } ],
         identification: [{ position: 120, label: 'PO Number' }]}
         @EndUserText.label: 'PO Number'
         PurchaseOrder,

         @UI:{ lineItem:[ { position: 140, importance: #HIGH, label: 'PO Item' } ],
         identification: [{ position: 140, label: 'PO Item' }]}
         @EndUserText.label: 'PO Item'
         PurchaseOrderItem,

         @UI:{ lineItem:[ { position: 150, importance: #HIGH, label: 'Purchase Cost' } ],
         identification: [{ position: 150, label: 'Purchase Cost' }]}
         @EndUserText.label: 'Purchase Cost'
         PurchaseCost,

         @UI:{ lineItem:[ { position: 160, importance: #HIGH, label: 'Tariff Cost' } ],
         identification: [{ position: 160, label: 'Tariff Cost' }]}
         @EndUserText.label: 'Tariff Cost'
         TariffCost,

         @UI:{ lineItem:[ { position: 170, importance: #HIGH, label: 'Freight Cost' } ],
         identification: [{ position: 170, label: 'Freight Cost' }]}
         @EndUserText.label: 'Freight Cost'
         FreightCost,

         @UI:{ lineItem:[ { position: 180, importance: #LOW, label: 'Posting Date' } ],
               selectionField: [{ position: 160 }],
               fieldGroup: [{ qualifier: 'DatesGroup', position: 10, label: 'Posting Date' }] }
         @EndUserText.label: 'Posting Date'
         PostingDate,

         @UI:{ lineItem:[ { position: 190, importance: #LOW, label: 'Creation Date' } ],
               fieldGroup: [{ qualifier: 'DatesGroup', position: 20, label: 'Creation Date' }] }
         @EndUserText.label: 'Creation Date'
         CreationDate,

         @UI:{ lineItem:[ { position: 200, importance: #LOW, label: 'Created By' } ],
               fieldGroup: [{ qualifier: 'DatesGroup', position: 30, label: 'Created By' }] }
         @EndUserText.label: 'Created By'
         CreatedByUser,

         @EndUserText.label: 'Purchase Cost Currency'
         ConditionCurrency,
         @EndUserText.label: 'Sales Cost Currency'
         TransactionCurrency,
         @EndUserText.label: 'Tariff Currency'
         ConditionCurrencyZTX1

}
