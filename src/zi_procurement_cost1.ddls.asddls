@AbapCatalog.sqlViewName: 'YPROCUREMENTCOST'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Procurement Cost Report'
define root view ZI_PROCUREMENT_COST1
  as select from ZI_PROCUREMENT_COST
{
  key PurchaseOrder,
  key PurchaseOrderItem,
  key MaterialDocumentType,
  key MaterialDocumentYear,
  key MaterialDocument,
  key MaterialDocumentItem,
      PurchaseOrderType,
      PurchasingOrganization,
      CreatedByUser,
      CreationDate,
      ShipmentNumber,
      Plant,
      Product,
      ProductType,
      ProductGroup,
      QuantityUnit,
      POQuantity,
      DeliveryCostQuantity,
      LocalCurrency,
      ValueReceived,

      @Semantics.amount.currencyCode: 'LocalCurrency'
      cast( ConditionAmount_ZTX1 * Ratio as abap.curr( 15, 2 ) )     as Tariff,

      @Semantics.amount.currencyCode: 'LocalCurrency'
      cast( ( ConditionAmount_ZFR1 * Ratio
              +
              ConditionAmount_ZFRL * Ratio
              +
              ConditionAmount_ZTAR * Ratio
              +
              ConditionAmount_ZTAX * Ratio ) as abap.curr( 15, 2 ) ) as Freight,

      @Semantics.amount.currencyCode: 'LocalCurrency'
      cast( ( ConditionAmount_ZTX1 * Ratio
              +
              ConditionAmount_ZFR1 * Ratio
              +
              ConditionAmount_ZFRL * Ratio
              +
              ConditionAmount_ZTAR * Ratio
              +
              ConditionAmount_ZTAX * Ratio ) as abap.curr( 15, 2 ) ) as DeliveryCost,

      @Semantics.amount.currencyCode: 'LocalCurrency'
      ValueReceived
      +
      cast( ( ConditionAmount_ZTX1 * Ratio
              +
              ConditionAmount_ZFR1 * Ratio
              +
              ConditionAmount_ZFRL * Ratio
              +
              ConditionAmount_ZTAR * Ratio
              +
              ConditionAmount_ZTAX * Ratio ) as abap.curr( 15, 2 ) ) as TotalCost,

      /* Associations */
      _CreatedUser,
      _MaterialDocumentItem,
      _Plant,
      _Product,
      _ProductGroupName,
      _ProductName,
      _PurchaseOrderTypeName,
      _PurchasingOrganization
}
