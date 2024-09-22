@EndUserText.label: 'Get material document serail number POST data'
define abstract entity ZR_SMM008_MATDOCSN_POST
{
  Material_Document_Year : mjahr;
  Material_Document     : mblnr;
  Material_Document_Item : mblpo;
  Material             : matnr;
  Serial_Number         : zzemm008;
  flag                 : abap.char(20);
}
