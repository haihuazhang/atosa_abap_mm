//&---------------------------------------------------------------------*
//&CDS名称/CDS Name              : ZC_SMM005
//&CDS描述/CDS Des.              : Inventory Cost Report Consumption View
//&CDS版本/CDS Ver.              : V.10
//&申请单位/Applicant            :  Atosa
//&申请人/Applicant              : Alexis/Aang.Luo
//&申请日期/Date of App          : 2023-11-24
//&开发单位/Development Company  : HAND
//&作者/Author                   : Zonghua.Bai
//&完成日期/Completion Date      : 2023-11-24
//&---------------------------------------------------------------------*
//&-----------------------------abstract/摘要：
//&   1. Business backgroud/业务背景
//&      1).Material Purchase Order Receipt Analysis
//&   2. Usage scenario/使用场景
//&      1). Analysts view material inventory and purchase order status
//&   3. Lnvoling data sources/涉及数据源
//&       1). ZC_SMM005 
//&   4.  CDS Design：
//&       1). ZI_SMM005 root view
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
@EndUserText.label: 'Inventory Cost Report Consumption View'
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
    },
    presentationVariant: [{
        sortOrder: [{
            by: 'Plant',
            direction: #ASC
        },{
            by: 'Product',
            direction: #ASC
        },{
            by: 'PurchaseOrder',
            direction: #ASC
        }]
    }]
}
define root view entity ZC_SMM005 
  provider contract transactional_query
  as projection on ZR_SMM005
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
            
        @UI:{ lineItem:[ { position: 10, importance: #HIGH, label: 'Plant' } ],
              selectionField: [{ position: 10 }] }
        @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Plant', element: 'Plant' }}]
  key   Plant,

        @UI:{ lineItem:[ { position: 20, importance: #LOW, label: 'Material Type' } ]}
  key   ProductType,

        @UI:{ lineItem:[ { position: 30, importance: #HIGH, label: 'Material No.' } ],
              selectionField: [{ position: 20 }] }
        @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductPlantBasic', element: 'Product' }}]
  key   Product,
  
        @UI:{ selectionField: [{ position: 70 }],
              identification: [{ position: 70, label: 'Purchase Order Number' }] }
        @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PurchaseOrderAPI01', element: 'PurchaseOrder' }}]
  key   PurchaseOrder,

        @UI:{ lineItem:[ { position: 30, importance: #LOW, label: 'Serial Number' } ],
              selectionField: [{ position: 30 }],
              identification: [{ position: 30, label: 'Serial Number' }] }
  key   SerialNumber,
        
        @UI:{ lineItem:[ { position: 40, importance: #LOW, label: 'Original Serial Number' } ],
              selectionField: [{ position: 40 }],
              identification: [{ position: 40, label: 'Original Serial Number' }] }
  key   OriginalSerialNumber,

        @UI:{ lineItem:[ { position: 50, importance: #HIGH, label: 'Delivery Cost' } ],
              fieldGroup: [{ qualifier: 'QuantityCostGroup', position: 10, label: 'Delivery Cost' }] }
        DeliveryCost,


        @UI:{ lineItem:[ { position: 60, importance: #HIGH, label: 'Value received' } ],
              fieldGroup: [{ qualifier: 'QuantityCostGroup', position: 20, label: 'Value received' }] }
        ValueReceived,
        
        @UI:{ lineItem:[ { position: 70, importance: #HIGH, label: 'Freight' } ],
              fieldGroup: [{ qualifier: 'QuantityCostGroup', position: 30, label: 'Freight' }] }
        Freight,
        
        @UI:{ lineItem:[ { position: 80, importance: #HIGH, label: 'Tariff' } ],
              fieldGroup: [{ qualifier: 'QuantityCostGroup', position: 40, label: 'Freight' }] }
        Tariff,
        
        @UI:{ lineItem:[ { position: 100, importance: #HIGH, label: 'Local Currency' } ],
              fieldGroup: [{ qualifier: 'QuantityCostGroup', position: 30, label: 'Local Currency' }] }
        LocalCurrency,
        
        @UI:{ lineItem:[ { position: 110, importance: #LOW, label: 'Posting Date' } ],
              selectionField: [{ position: 130 }],
              fieldGroup: [{ qualifier: 'DatesGroup', position: 10, label: 'Posting Date' }] }
        PostingDate

}
