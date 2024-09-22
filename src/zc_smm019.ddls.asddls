@EndUserText.label: 'Variance for Container'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_SMM019
  provider contract transactional_query
  as projection on ZR_SMM019
{
  key     PurchaseOrder,
  key     PurchaseOrderItem,
          ShipmentNumber,
          @ObjectModel.text.element: [ 'CompanyCodeName' ]
          CompanyCode,
          @ObjectModel.text.element: [ 'SupplierName' ]
          Supplier,
          @ObjectModel.text.element: [ 'PurchasingOrganizationName' ]
          PurchasingOrganization,
          @ObjectModel.text.element: [ 'PurchasingGroupName' ]
          PurchasingGroup,
          PurchaseOrderDate,
          @ObjectModel.text.element: [ 'PersonFullName' ]
          CreatedByUser,
          CreationDate,
          @ObjectModel.text.element: [ 'PlantName' ]
          Plant,
          @ObjectModel.text.element: [ 'ProductName' ]
          Material,
          OrderQuantity,
          PurchaseOrderQuantityUnit,

          @Semantics.quantity.unitOfMeasure : 'PurchaseOrderQuantityUnit'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_MM_004'
  virtual LoadingQuantity          : abap.quan( 13, 3 ),

          @Semantics.quantity.unitOfMeasure : 'PurchaseOrderQuantityUnit'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_MM_004'
  virtual LoadingVariance          : abap.quan( 13, 3 ),

          @Semantics.quantity.unitOfMeasure : 'PurchaseOrderQuantityUnit'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_MM_004'
  virtual ReceivedQuantity         : abap.quan( 13, 3 ),

          @Semantics.quantity.unitOfMeasure : 'PurchaseOrderQuantityUnit'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZZCL_MM_004'
  virtual OpenQuantityforReceiving : abap.quan( 13, 3 ),

          @UI.hidden: true
          _CompanyCode.CompanyCodeName,
          @UI.hidden: true
          _Plant.PlantName,
          @UI.hidden: true
          _ProductText.ProductName,
          @UI.hidden: true
          _PurchasingOrganization.PurchasingOrganizationName,
          @UI.hidden: true
          _PurchasingGroup.PurchasingGroupName,
          @UI.hidden: true
          _Supplier.SupplierName,
          @UI.hidden: true
          _User.PersonFullName,

          /* Associations */
          _CompanyCode,
          _Plant,
          _Product,
          _ProductText,
          _PurchasingOrganization,
          _PurchasingGroup,
          _Supplier,
          _User
}
