@EndUserText.label: 'Reverse Scanning Records'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define root view entity ZC_SMM011
  provider contract transactional_query
  as projection on ZR_SMM011
{
  key     MaterialDocumentYear,
  key     MaterialDocument,
  key     MaterialDocumentItem,
  key     SerialNumber,
          DocumentDate,
          PostingDate,
          MaterialDocumentHeaderText,
          @ObjectModel: { text.element: [ 'PersonFullName' ] }
          CreatedByUser,
          CreationDate,
          GoodsMovementType,
          @ObjectModel: { text.element: [ 'ProductName' ] }
          Material,
          @ObjectModel: { text.element: [ 'PlantName' ] }
          Plant,
          @ObjectModel: { text.element: [ 'StorageLocationName' ] }
          StorageLocation,
          PurchaseOrder,
          PurchaseOrderItem,
          @ObjectModel: { text.element: [ 'SupplierName' ] }
          Supplier,
          QuantityInBaseUnit,
          MaterialBaseUnit,
          QuantityInEntryUnit,
          EntryUnit,
          ReversedMaterialDocumentYear,
          ReversedMaterialDocument,
          ReversedMaterialDocumentItem,
          IsReversed,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_004'
  virtual ShipmentDocument : zzemm004,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_MM_004'
  virtual ContainerNumber  : zzemm005,

          @UI.hidden:true
          _User.PersonFullName,
          @UI.hidden:true
          _Plant.PlantName,
          @UI.hidden:true
          _ProductText.ProductName,
          @UI.hidden:true
          _StorageLocation.StorageLocationName,
          @UI.hidden:true
          _Supplier.SupplierName,

          _Product
}
