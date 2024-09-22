@EndUserText.label: 'Get material document serail number data'
define abstract entity ZR_SMM008_MATDOCSN
{
  MaterialDocumentYear : mjahr;
  MaterialDocument     : mblnr;
  MaterialDocumentItem : mblpo;
  Material             : matnr;
  SerialNumber         : zzemm008;
  flag                 : abap.char(20);
}
