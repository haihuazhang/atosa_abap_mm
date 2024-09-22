//&---------------------------------------------------------------------*
//&CDS名称/CDS Name              : ZR_SMM006
//&CDS描述/CDS Des.              : Sales Cost Report Interface View
//&CDS版本/CDS Ver.              : V.10
//&申请单位/Applicant            :  Atosa
//&申请人/Applicant              : Alexis/Aang.Luo
//&申请日期/Date of App          : 2023-11-27
//&开发单位/Development Company  : HAND
//&作者/Author                   : Zonghua.Bai
//&完成日期/Completion Date      : 2023-11-27
//&---------------------------------------------------------------------*
//&-----------------------------abstract/摘要：
//&   1. Business backgroud/业务背景
//&      1).Material Purchase Order Receipt Analysis
//&   2. Usage scenario/使用场景
//&      1). Analysts view material inventory and purchase order status
//&   3. Lnvoling data sources/涉及数据源
//&       1). I_ProductPlantBasic
//&       2). I_Product
//&       3). I_PurchaseOrderHistoryAPI01
//&       4). I_PurchaseOrderAPI01
//&       5). I_PurchaseOrderItemAPI01
//&       6). I_PurOrdItmPricingElementAPI01
//&       7). I_PurOrdHistDeliveryCostAPI01
//&       8). I_ProductValuationBasic
//&   4.  CDS Design：
//&       1). ZR_SMM006 root view
//&       2). Basic data fields
//&       3). root view
//&       4). Key plant/ProductType/productor/Po/PoItem/MaterialDocument/MaterialDocumentItem
//&   5.  Code specification/代码规范
//&       遵循 《汉得SAP标准化程序开发规范 V2.0》；
//&   6.  Code changes/代码更改
//&       个人代码更改点为如下代码片段（非此片段不能更改）：
//&   7.  Code annotation/代码注释
//&       Comprehensive and concise annotations (single line, within 25 words);
//&       注释全面、简洁明了（单行，字数25以内）；
//&---------------------------------------------------------------------*
//&Change record/变更记录：
//& Date        Developer           ReqNo         Descriptions
//& ==========  ==================  ============  ======================*
//& 2023-11-24  Zonghua.Bai（Hand）  X7UK900358    Initial development
//&---------------------------------------------------------------------*
@AbapCatalog.sqlViewName: 'ZRSMM006'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Cost Report'
define root view ZR_SMM006
    as select distinct from ZR_SMM018
    
{
    key ProductType,
    key MaterialDocument,
    key MaterialDocumentItem,
    key GoodsMovementType,
    key Plant,
    key Product,
    key SerialNumber,
    key DeliveryDocument,
    key DeliveryDocumentItem,
    key SalesOrder,
    key SalesOrderItem,
    SalesOrganization,
    SalesCost,
    TransactionCurrency,
    ShipmentNumber,
    PurchaseOrder,
    PurchaseOrderItem,
    case when SerialNumber is null or SerialNumber = ''
    then SalesCost
    else 
        case when PurchaseOrder is null or PurchaseOrder = ''
        then ValueReceived
        else PurchaseCost
        end
    end as PurchaseCost,
    
    ConditionCurrency,
    
    case when SerialNumber is null or SerialNumber = ''
    then cast( 0 as abap.dec( 13,2 ) )
    else 
        case when PurchaseOrder is null or PurchaseOrder = ''
        then Tariff
        else 
            cast(cast(ConditionAmount as abap.decfloat16) / cast(OrderQuantity as abap.decfloat16) as abap.dec( 13, 2 ))
        end
    end as TariffCost,
    
    ConditionCurrencyZTX1,
    
    case when SerialNumber is null or SerialNumber = ''
    then cast( 0 as abap.dec( 13,2 ) )
    else
        case when PurchaseOrder is null or PurchaseOrder = ''
        then SalesCost - ValueReceived - Tariff
        else SalesCost - PurchaseCost - cast(cast(ConditionAmount as abap.decfloat16) / cast(OrderQuantity as abap.decfloat16) as abap.dec( 13, 2 ))
        end
    end as FreightCost,
    
    CreatedByUser,
    CreationDate,
    PostingDate
}
