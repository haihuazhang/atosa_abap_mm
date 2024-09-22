@EndUserText.label: 'Stock Aging Report'
@ObjectModel.query.implementedBy:'ABAP:ZCL_MM_003'
@UI: {
    headerInfo: {
        typeNamePlural: 'Stock Aging Report Results',
        description: {
            value: 'Material'
        }
    }
}
@Search.searchable: true
define custom entity ZR_SMM010
{
      --key uuid     : sysuuid_x16;
      @UI.facet     : [
      {
           label    : 'General Information',
           id       : 'GeneralInfo',
           type     : #COLLECTION,
           position : 10
         },{
       id           : 'idIdentification',
       type         : #IDENTIFICATION_REFERENCE,
       label        : 'General Information',
       position     : 10
      } ]
      
      @UI           : { lineItem:[ { position: 10, importance: #HIGH, label: 'Product Type' } ],
      selectionField: [{ position: 10 }] }
      @UI.identification              : [ {position: 10 ,label: 'Product Type'} ]
      @EndUserText.label              : 'Product Type'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Producttype', element: 'ProductType' }}]
      @Search.defaultSearchElement:true
  key producttype   : abap.char(4);

      @UI           : { lineItem:[ { position: 20, importance: #LOW, label: 'Plant' } ],
      selectionField: [{ position: 20 }]}
      @UI.identification              : [ {position: 20 ,label: 'Plant'} ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Plant', element: 'Plant' }}]
      @EndUserText.label              : 'Plant'
  key Plant         : werks_d;

      @UI           : { lineItem:[ { position: 30, importance: #LOW, label: 'Storage Location' } ]}
      @UI.identification              : [ {position: 30 ,label: 'Storage Location'} ]
      @EndUserText.label              : 'Storage Location'
  key Storage       : abap.char(4);

      @UI           : { lineItem:[ { position: 40, importance: #LOW, label: 'Stock Type' } ]}
      @UI.identification              : [ {position: 40 ,label: 'Stock Type'} ]
      @EndUserText.label              : 'Stock Type'
  key InventoryStockType      : abap.char(2);
  
      @UI           : { lineItem:[ { position: 50, importance: #LOW, label: 'Product' } ],
      selectionField: [{ position: 50 }]}
      @UI.identification              : [ {position: 50 ,label: 'Product'} ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductPlantBasic', element: 'Product' }}]
      @EndUserText.label              : 'Product'
  key Material      : matnr;

      @UI           : { lineItem:[ { position: 70, importance: #LOW, label: 'Serial Number' } ],
      selectionField: [{ position: 60 }]}
      @UI.identification              : [ {position: 70 ,label: 'Serial Number'} ]
      @EndUserText.label              : 'Serial Number'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Equipment', element: 'SerialNumber' }}]
  key SerialNumber      : abap.char(18);
      
      @UI           : { lineItem:[ { position: 60, importance: #LOW, label: 'Product Description' } ]}
      @UI.identification              : [ {position: 60 ,label: 'Product Description'} ]
      @EndUserText.label              : 'Product Description'
      Description   : abap.char(40);

      @UI           : { lineItem:[ { position: 80, importance: #LOW, label: 'Material Group' } ]}
      @UI.identification              : [ {position: 80 ,label: 'Material Group'} ]
      @EndUserText.label              : 'Material Group'
      MaterialGroup : abap.char(4);

      @UI           : { lineItem:[ { position: 90, importance: #LOW, label: 'Base of Unit' } ]}
      @UI.identification              : [ {position: 90 ,label: 'Base of Unit'} ]
      @EndUserText.label              : 'Base of Unit'
      @Semantics.unitOfMeasure        : true
      BaseOfUnit    : meins;

      @UI           : { lineItem:[ { position: 100, importance: #LOW, label: 'Stock Quantity' } ]}
      @UI.identification              : [ {position: 100 ,label: 'Stock Quantity'} ]
      @EndUserText.label              : 'Stock Quantity'
      @Semantics.quantity.unitOfMeasure: 'BaseOfUnit'
      Quantity      : abap.quan( 15, 3 );



      @UI           : { lineItem:[ { position: 110, importance: #LOW, label: 'Aging Date' } ]}
      @UI.identification              : [ {position: 110 ,label: 'Aging Date'} ]
      @EndUserText.label              : 'Aging Date'
      AgingDate      : abap.dats;
      
      @UI           : { lineItem:[ { position: 120, importance: #LOW, label: 'Aging Month' } ]}
      @UI.identification              : [ {position: 120 ,label: 'Aging Month'} ]
      @EndUserText.label              : 'Aging Month'
      AgingMonth      : abap.char(2);
      
      @UI           : { lineItem:[ { position: 130, importance: #LOW, label: 'Aging Year' } ]}
      @UI.identification              : [ {position: 130 ,label: 'Aging Year'} ]
      @EndUserText.label              : 'Aging Year'
      AgingYear      : abap.char(4);

}
