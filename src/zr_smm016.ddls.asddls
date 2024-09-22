@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help of Y/N'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZR_SMM016
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZZDMM017')
{

      @EndUserText.label: 'Type'
      @ObjectModel.text.element: [ 'Text' ]
  key value_low as Value,

      @EndUserText.label: 'Type Description'
      @Semantics.text: true
      text      as Text
}
where
  language = 'E'
