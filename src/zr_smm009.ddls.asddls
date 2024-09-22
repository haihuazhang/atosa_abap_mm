@EndUserText.label: 'PO List - Received but not Invoiced'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_MM_001'
@UI: {
  headerInfo: {
    typeName: 'Purchase Order',
    typeNamePlural: 'Purchase Order',
    title: { type: #STANDARD, value: 'PurchaseOrder' }
  }
}
define custom entity ZR_SMM009
{
      @UI.facet               : [ {
        id                    : 'idIdentification',
        type                  : #IDENTIFICATION_REFERENCE,
        label                 : 'General information',
        position              : 10
      } ]

      @UI.lineItem            : [ { position: 10 , importance: #MEDIUM, label: 'Purchase Order' } ]
      @UI.identification      : [ { position: 10 , label: 'Purchase Order' } ]
      @UI.selectionField      : [ { position: 20 } ]
      @EndUserText.label      : 'Purchase Order'
      @Consumption.semanticObject: 'PurchaseOrder'
      @Consumption.valueHelpDefinition: [ {
        entity                : { name: 'I_PurchaseOrderAPI01', element: 'PurchaseOrder' }
      } ]
  key PurchaseOrder           : ebeln;

      @UI.lineItem            : [ { position: 30 , importance: #MEDIUM, label: 'Condition Type' } ]
      @UI.identification      : [ { position: 30 , label: 'Condition Type' } ]
      @EndUserText.label      : 'Condition Type'
      @Consumption.valueHelpDefinition: [ {
        entity                : { name: 'I_ConditionType', element: 'ConditionType' }
      } ]
      @ObjectModel.text.element: [ 'ConditionTypeName' ]
  key ConditionType           : abap.char( 4 );

      @UI.lineItem            : [ { position: 20 , importance: #MEDIUM, label: 'Supplier' } ]
      @UI.identification      : [ { position: 20 , label: 'Supplier' } ]
      @UI.selectionField      : [ { position: 40 } ]
      @EndUserText.label      : 'Supplier'
      @Consumption.semanticObject: 'Supplier'
      @Consumption.valueHelpDefinition: [ {
        entity                : { name: 'I_SupplierPurchasingOrg', element: 'Supplier' }
      } ]
      @ObjectModel.foreignKey.association: '_Supplier1'
      Supplier                : lifnr;

      @UI.lineItem            : [ { position: 40 , importance: #MEDIUM, label: 'Condition Type Supplier' } ]
      @UI.identification      : [ { position: 40 , label: 'Condition Type Supplier' } ]
      @Consumption.semanticObject: 'Supplier'
      @EndUserText.label      : 'Condition Type Supplier'
      @ObjectModel.foreignKey.association: '_Supplier2'
      ConditionTypeSupplier   : lifnr;

      @UI.lineItem            : [ { position: 50 , importance: #MEDIUM, label: 'Purchasing Organization' } ]
      @UI.identification      : [ { position: 50 , label: 'Purchasing Organization' } ]
      @EndUserText.label      : 'Purchasing Organization'
      @Consumption.valueHelpDefinition: [ {
         entity               : { name: 'I_PurchasingOrganization', element: 'PurchasingOrganization' }
      } ]
      @ObjectModel.foreignKey.association: '_PurchasingOrganization'
      PurchasingOrganization  : abap.char( 4 );

      @UI.lineItem            : [ { position: 60 , importance: #MEDIUM, label: 'Purchasing Group' } ]
      @UI.identification      : [ { position: 60 , label: 'Purchasing Group' } ]
      @EndUserText.label      : 'Purchasing Group'
      @Consumption.valueHelpDefinition: [ {
         entity               : { name: 'I_PurchasingGroup', element: 'PurchasingGroup' }
      } ]
      @ObjectModel.foreignKey.association: '_PurchasingGroup'
      PurchasingGroup         : abap.char( 3 );

      @UI.lineItem            : [ { position: 70 , importance: #MEDIUM, label: 'Company Code' } ]
      @UI.identification      : [ { position: 70 , label: 'Company Code' } ]
      @UI.selectionField      : [ { position: 10 } ]
      @EndUserText.label      : 'Company Code'
      @Consumption.valueHelpDefinition: [ {
         entity               : { name: 'I_CompanyCode', element: 'CompanyCode' }
      } ]
      @ObjectModel.foreignKey.association: '_CompanyCode'
      CompanyCode             : bukrs;

      @UI.lineItem            : [ { position: 80 , importance: #MEDIUM, label: 'Plant' } ]
      @UI.identification      : [ { position: 80 , label: 'Plant' } ]
      @UI.selectionField      : [ { position: 30 } ]
      @EndUserText.label      : 'Plant'
      //      @Consumption.filter.mandatory: true
      @Consumption.valueHelpDefinition: [ {
         entity               : { name: 'I_Plant', element: 'Plant' }
      } ]
      @ObjectModel.foreignKey.association: '_Plant'
      Plant                   : werks_d;

      @UI.lineItem            : [ { position: 90 , importance: #MEDIUM, label: 'Created By' } ]
      @UI.identification      : [ { position: 90 , label: 'Created By' } ]
      @UI.selectionField      : [ { position: 50 } ]
      @EndUserText.label      : 'Created By'
      @Consumption.valueHelpDefinition: [ {
         entity               : { name: 'I_BusinessUserVH', element: 'UserID' }
      } ]
      @ObjectModel.foreignKey.association: '_User'
      CreatedBy               : abap.char( 12 );

      @UI.lineItem            : [ { position: 100 , importance: #MEDIUM, label: 'Created On' } ]
      @UI.identification      : [ { position: 100 , label: 'Created On' } ]
      @EndUserText.label      : 'Created On'
      CreatedOn               : datum;

      @UI.lineItem            : [ { position: 110 , importance: #MEDIUM, label: 'Last Received Date' } ]
      @UI.identification      : [ { position: 110 , label: 'Last Received Date' } ]
      @EndUserText.label      : 'Last Received Date'
      LastedReceivedDate      : datum;

      @UI.lineItem            : [ { position: 120 , importance: #MEDIUM, label: 'Invoiced' } ]
      @UI.identification      : [ { position: 120 , label: 'Invoiced' } ]
      @EndUserText.label      : 'Invoiced'
      Invoiced                : abap_boolean;

      @UI.lineItem            : [ { position: 130 , importance: #MEDIUM, label: 'Delivery Cost Invoiced' } ]
      @UI.identification      : [ { position: 130 , label: 'Delivery Cost Invoiced' } ]
      @EndUserText.label      : 'Delivery Cost Invoiced'
      DeliveryCostInvoiced    : abap_boolean;

      @UI.lineItem            : [ { position: 15 , importance: #MEDIUM, label: 'Shipment Number' } ]
      @UI.identification      : [ { position: 15 , label: 'Shipment Number' } ]
      @EndUserText.label      : 'Shipment Number'
      ShipmentNumber          : abap.char( 12 );

      @UI.hidden              : true
      ConditionTypeName       : abap.char( 30 );


      @ObjectModel.sort.enabled   : false
      @ObjectModel.filter.enabled : false
      _Supplier1              : association [0..1] to I_Supplier on _Supplier1.Supplier = $projection.Supplier;
      @ObjectModel.sort.enabled   : false
      @ObjectModel.filter.enabled : false
      _Supplier2              : association [0..1] to I_Supplier on _Supplier2.Supplier = $projection.ConditionTypeSupplier;
      @ObjectModel.sort.enabled   : false
      @ObjectModel.filter.enabled : false
      _PurchasingOrganization : association [0..1] to I_PurchasingOrganization on  _PurchasingOrganization.PurchasingOrganization = $projection.PurchasingOrganization
                                                                               and _PurchasingOrganization.CompanyCode            = $projection.CompanyCode;
      @ObjectModel.sort.enabled   : false
      @ObjectModel.filter.enabled : false
      _PurchasingGroup        : association [0..1] to I_PurchasingGroup on _PurchasingGroup.PurchasingGroup = $projection.PurchasingGroup;
      @ObjectModel.sort.enabled   : false
      @ObjectModel.filter.enabled : false
      _CompanyCode            : association [0..1] to I_CompanyCode on _CompanyCode.CompanyCode = $projection.CompanyCode;
      @ObjectModel.sort.enabled   : false
      @ObjectModel.filter.enabled : false
      _Plant                  : association [0..1] to I_Plant on _Plant.Plant = $projection.Plant;
      @ObjectModel.sort.enabled   : false
      @ObjectModel.filter.enabled : false
      _User                   : association [0..1] to I_BusinessUserVH on _User.UserID = $projection.CreatedBy;
}
