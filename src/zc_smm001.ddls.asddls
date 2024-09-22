@EndUserText.label: 'Shipment Document Header from PO'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_SMM001
  provider contract transactional_query
  as projection on ZR_SMM001
{

          @ObjectModel: { text.element: [ 'PurchasingDocumentTypeName' ] }
  key     PurchaseOrder,
          ShipmentDocument,
          @ObjectModel: { text.element: [ 'SupplierName' ] }
          Supplier,
          @ObjectModel: { text.element: [ 'PurchasingOrganizationName' ] }
          PurchasingOrganization,
          @ObjectModel: { text.element: [ 'PurchasingGroupName' ] }
          PurchasingGroup,
          @ObjectModel: { text.element: [ 'CompanyCodeName' ] }
          CompanyCode,
          PurchaseOrderDate,
          @ObjectModel: { text.element: [ 'PersonFullName' ] }
          CreatedByUser,
          CreationDate,

          //          @ObjectModel.virtualElementCalculatedBy: 'ABAP:CL_MM_PUR_PO_MAINT_V2_FILTERS'
          //          @ObjectModel.filter.transformedBy: 'ABAP:CL_MM_PUR_PO_MAINT_V2_FILTERS'
          //  virtual Material : abap.sstring( 260 ),

          //          @ObjectModel.virtualElementCalculatedBy: 'ABAP:CL_MM_PUR_PO_MAINT_V2_FILTERS'
          //          @ObjectModel.filter.transformedBy: 'ABAP:CL_MM_PUR_PO_MAINT_V2_FILTERS'
          //  virtual Plant    : abap.sstring( 260 ),

          @UI.hidden:true
          PurchaseOrderType,
          @UI.hidden:true
          _PurchaseOrderTypeText.PurchasingDocumentTypeName,
          @UI.hidden:true
          _Supplier.SupplierName,
          @UI.hidden:true
          _PurchasingOrganization.PurchasingOrganizationName,
          @UI.hidden:true
          _PurchasingGroup.PurchasingGroupName,
          @UI.hidden:true
          _CompanyCode.CompanyCodeName,
          @UI.hidden:true
          _User.PersonFullName,

          /* Associations */
          _ShipmentItem      : redirected to composition child ZC_SMM002,
          _ShipmentContainer : redirected to composition child ZC_SMM003
}
