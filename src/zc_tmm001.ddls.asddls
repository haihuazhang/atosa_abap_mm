@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TMM001'
define root view entity ZC_TMM001
  provider contract transactional_query
  as projection on ZR_TMM001
{
  key UUID,
  Product,
  Zserialnumber,
  Zoldserialnumber,
  LocalLastChangedAt
  
}
