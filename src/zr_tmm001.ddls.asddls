@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTMM001'
define root view entity ZR_TMM001
  as select from ztmm001
{
  key uuid as UUID,
  product as Product,
  zserialnumber as Zserialnumber,
  zoldserialnumber as Zoldserialnumber,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt
  
}
