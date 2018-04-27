object POSDataMod: TPOSDataMod
  OldCreateOrder = True
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Left = 317
  Top = 202
  Height = 686
  Width = 1269
  object CCBatchSource: TDataSource
    DataSet = IBCCBatchQuery
    Left = 40
    Top = 440
  end
  object FuelTranSource: TDataSource
    DataSet = IBFuelTranQuery
    Left = 40
    Top = 384
  end
  object UserSource: TDataSource
    DataSet = IBUserQuery
    Left = 40
    Top = 328
  end
  object PLUSource: TDataSource
    DataSet = PLUMemTable
    Left = 464
    Top = 8
  end
  object AESImportQry: TQuery
    DatabaseName = 'AESImport'
    SessionName = 'Default'
    Left = 384
    Top = 8
  end
  object AESData: TDatabase
    AliasName = 'Aes2000'
    DatabaseName = 'AESImport'
    LoginPrompt = False
    Params.Strings = (
      'DATABASE NAME=C:\AES2000\aes2000.db'
      'USER NAME=DBA'
      'ODBC DSN=Aes2000'
      'OPEN MODE=READ/WRITE'
      'BATCH COUNT=200'
      'LANGDRIVER='
      'MAX ROWS=-1'
      'SCHEMA CACHE DIR='
      'SCHEMA CACHE SIZE=8'
      'SCHEMA CACHE TIME=-1'
      'SQLPASSTHRU MODE=SHARED AUTOCOMMIT'
      'SQLQRYMODE='
      'ENABLE SCHEMA CACHE=FALSE'
      'ENABLE BCD=FALSE'
      'ROWSET SIZE=20'
      'BLOBS TO CACHE=64'
      'BLOB SIZE=32'
      'PASSWORD=SQL')
    SessionName = 'Default'
    Left = 312
    Top = 8
  end
  object IBDb: TIBDatabase
    Params.Strings = (
      'user_name=rsgretail'
      'password=pos')
    LoginPrompt = False
    DefaultTransaction = IBDefaultTransaction
    AfterConnect = IBDbAfterConnect
    BeforeDisconnect = IBDbBeforeDisconnect
    Left = 24
    Top = 8
  end
  object IBTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 208
    Top = 8
  end
  object IBPDITransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 258
    Top = 8
  end
  object IBFuelPriceChangeQuery: TIBQuery
    Database = IBDb
    Transaction = IBFuelPriceChangeTransaction
    Left = 224
    Top = 404
  end
  object IBTaxTableQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    Left = 552
    Top = 312
  end
  object IBFuelTranQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    SQL.Strings = (
      
        'select * from FuelTran where ((SaleType = "POS") or (SaleType = ' +
        '"PPY"))'
      'and (Completed = 1) '
      'order by TransNo desc')
    Left = 128
    Top = 384
  end
  object IBCCBatchQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    SQL.Strings = (
      'select * from ccBatch cb left outer join cwtrans cw'
      ' on (cb.transno=cw.transno)'
      ' where cb.hostid > 0 and cb.OrigSource = '#39'CAT'#39' and cb.Amount > 0'
      ' order by cb.AuthID desc')
    Left = 128
    Top = 440
  end
  object IBUserQuery: TIBQuery
    Database = IBDb
    Transaction = IBUserTransaction
    SQL.Strings = (
      'Select * from Users where UserID = :pUserID')
    Left = 128
    Top = 328
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'pUserID'
        ParamType = ptUnknown
      end>
  end
  object IBActionQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    Left = 40
    Top = 224
  end
  object IBReportQuery: TIBQuery
    Database = IBDb
    Transaction = IBReportTransaction
    Left = 128
    Top = 224
  end
  object IBReportQuery2: TIBQuery
    Database = IBDb
    Transaction = IBReportTransaction2
    Left = 216
    Top = 520
  end
  object IBPDIQuery: TIBQuery
    Database = IBDb
    Transaction = IBPDITransaction
    Left = 264
    Top = 328
  end
  object IBTempQry1: TIBQuery
    Database = IBDb
    Transaction = IBTempTrans1
    Left = 120
    Top = 272
  end
  object IBTempQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    ForcedRefresh = True
    Left = 40
    Top = 280
  end
  object IBTempQuery2: TIBQuery
    Database = IBDb
    Transaction = IBTempTrans2
    Left = 200
    Top = 272
  end
  object IBEODQuery: TIBQuery
    Database = IBDb
    Transaction = IBEODTransaction
    Left = 288
    Top = 280
  end
  object IBShiftQuery: TIBQuery
    Database = IBDb
    Transaction = IBShiftTransaction
    Left = 648
    Top = 8
  end
  object IBRestrictionQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    Left = 816
    Top = 104
  end
  object IBGradeQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    Left = 576
    Top = 232
  end
  object IBPrintQuery: TIBQuery
    Database = IBDb
    Transaction = IBPrintTransaction
    Left = 808
    Top = 48
  end
  object IBReceiptQuery: TIBQuery
    Database = IBDb
    Transaction = IBReceiptTransaction
    Left = 728
    Top = 8
  end
  object IBModifierQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    Left = 696
    Top = 120
  end
  object IBPLUQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    Left = 512
    Top = 384
  end
  object IBPLUModQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    Left = 824
    Top = 296
  end
  object IBDeptQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    SQL.Strings = (
      'Select * from Dept where DeptNo = :pDeptNo')
    Left = 800
    Top = 360
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'pDeptNo'
        ParamType = ptUnknown
      end>
  end
  object IBBankFuncQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    Left = 624
    Top = 368
  end
  object IBDiscQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    Left = 736
    Top = 312
  end
  object IBTotalsQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    Left = 760
    Top = 248
  end
  object IBNFPLUQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    Left = 704
    Top = 384
  end
  object IBPumpDefQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    Left = 640
    Top = 248
  end
  object IBMediaQuery: TIBQuery
    Database = IBDb
    Transaction = IBTransaction
    SQL.Strings = (
      'Select * from Media where MediaNo = :pMediaNo')
    Left = 656
    Top = 304
    ParamData = <
      item
        DataType = ftUnknown
        Name = 'pMediaNo'
        ParamType = ptUnknown
      end>
  end
  object IBKybdQuery: TIBQuery
    Database = IBDb
    Transaction = IBKybdTransaction
    Left = 736
    Top = 64
  end
  object IBMenuQuery: TIBQuery
    Database = IBDb
    Transaction = IBMenuTransaction
    Left = 664
    Top = 64
  end
  object IBShiftTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 336
    Top = 56
  end
  object IBDefaultTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 96
    Top = 8
  end
  object IBSetupTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 552
    Top = 112
  end
  object IBSetupQuery: TIBQuery
    Database = IBDb
    Transaction = IBSetupTransaction
    SQL.Strings = (
      'Select * from Setup')
    Left = 840
    Top = 168
  end
  object IBMixMatchQuery: TIBQuery
    Database = IBDb
    Transaction = IBMixMatchTransaction
    SQL.Strings = (
      'Select * from MixMatch')
    Left = 556
    Top = 169
  end
  object IBMixMatchTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 660
    Top = 177
  end
  object IBUserTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 40
    Top = 56
  end
  object IBLogSQL: TIBSQL
    Database = IBDb
    Transaction = IBLogTransaction
    Left = 40
    Top = 567
  end
  object IBLogTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 160
    Top = 166
  end
  object IBPostTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 112
    Top = 514
  end
  object IBPostSQL: TIBSQL
    Database = IBDb
    Transaction = IBPostTransaction
    Left = 40
    Top = 515
  end
  object IBFuelPriceChangeTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 208
    Top = 52
  end
  object IBFuelPriceUpdateSQL: TIBSQL
    Database = IBDb
    Transaction = IBFuelPriceUpdateTransaction
    Left = 56
    Top = 115
  end
  object IBFuelPriceUpdateTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 200
    Top = 116
  end
  object IBReceiptTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 552
    Top = 56
  end
  object PLUMemTable: TRxMemoryData
    FieldDefs = <
      item
        Name = 'PLUNo'
        DataType = ftCurrency
      end
      item
        Name = 'UPC'
        DataType = ftCurrency
      end
      item
        Name = 'Name'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'ModifierNo'
        DataType = ftCurrency
      end
      item
        Name = 'Price'
        DataType = ftCurrency
      end>
    Left = 544
    Top = 8
  end
  object IBEODTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 320
    Top = 104
  end
  object IBMenuTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 264
    Top = 168
  end
  object IBKybdTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 432
    Top = 56
  end
  object IBTempTrans2: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 432
    Top = 104
  end
  object IBTempTrans1: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 368
    Top = 160
  end
  object IBReportTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Left = 456
    Top = 160
  end
  object IBBatchReportQuery: TIBQuery
    Database = IBDb
    Transaction = IBBatchReportTransaction
    Left = 512
    Top = 456
  end
  object IBBatchReportTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 632
    Top = 456
  end
  object IBReportTransaction2: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Left = 320
    Top = 520
  end
  object IBPrintTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Left = 832
    Top = 8
  end
  object IBExportQuery: TIBQuery
    Database = IBDb
    Transaction = IBExportTransaction
    Left = 504
    Top = 512
  end
  object IBExportTransaction: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Left = 600
    Top = 512
  end
  object IBTransactionMenuUpdate: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Left = 776
    Top = 456
  end
  object IBQueryMenuUpdate: TIBQuery
    Database = IBDb
    Transaction = IBTransactionMenuUpdate
    Left = 776
    Top = 512
  end
  object IBXMDQry1: TIBQuery
    Database = IBDb
    Transaction = IBXMDTrans
    Left = 400
    Top = 424
  end
  object IBXMDTrans: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 408
    Top = 368
  end
  object IBXMDQry2: TIBQuery
    Database = IBDb
    Transaction = IBXMDTrans
    Left = 400
    Top = 472
  end
  object IBSecTrans: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 400
    Top = 304
  end
  object IBSecQry1: TIBQuery
    Database = IBDb
    Transaction = IBSecTrans
    Left = 400
    Top = 248
  end
  object IBKioskTrans: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Left = 240
    Top = 568
  end
  object IBQryKiosk: TIBQuery
    Database = IBDb
    Transaction = IBKioskTrans
    Left = 304
    Top = 568
  end
  object KioskConn: TADOConnection
    KeepConnection = False
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 360
    Top = 572
  end
  object KioskQry: TADOStoredProc
    Connection = KioskConn
    CursorType = ctStatic
    ProcedureName = 'SP_TBLORDERS_SELECT_CHARGEABLES;1'
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = 0
      end
      item
        Name = '@I_OR_ID'
        Attributes = [paNullable]
        DataType = ftInteger
        Precision = 10
        Value = 2
      end>
    Prepared = True
    Left = 416
    Top = 584
  end
  object IBSuspendTrans: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 328
    Top = 368
  end
  object IBSuspendQry: TIBQuery
    Database = IBDb
    Transaction = IBSuspendTrans
    Left = 328
    Top = 424
  end
  object KioskOrderQry: TADOQuery
    Connection = KioskConn
    CursorType = ctDynamic
    Parameters = <>
    Left = 488
    Top = 570
  end
  object KioskCompleteQry: TADOStoredProc
    Connection = KioskConn
    ProcedureName = 'SP_TBLORDERS_UPDATE_PAID'
    Parameters = <
      item
        Name = '@I_OR_ID'
        Attributes = [paNullable]
        DataType = ftInteger
        Precision = 10
        Value = Null
      end>
    Left = 408
    Top = 522
  end
  object IBSetPortQry: TIBQuery
    Database = IBDb
    Transaction = IBSetPortTrans
    Left = 208
    Top = 464
  end
  object IBSetPortTrans: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'concurrency'
      'nowait')
    Left = 280
    Top = 464
  end
  object IBInvTrans: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 120
    Top = 568
  end
  object IBInvQry: TIBQuery
    Database = IBDb
    Transaction = IBInvTrans
    Left = 184
    Top = 568
  end
  object IBInventoryTrans: TIBTransaction
    DefaultDatabase = IBDb
    Left = 576
    Top = 562
  end
  object IBQryInventory: TIBQuery
    Database = IBDb
    Transaction = IBInventoryTrans
    Left = 656
    Top = 560
  end
  object IBQryInventory2: TIBQuery
    Database = IBDb
    Transaction = IBInventoryTrans
    Left = 736
    Top = 560
  end
  object ThreadTrans: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'write'
      'consistency')
    Left = 480
    Top = 256
  end
  object IBThreadConfigTrans: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 208
    Top = 352
  end
  object IBEvents: TIBEvents
    AutoRegister = False
    Database = IBDb
    Events.Strings = (
      'AdPriceChange'
      'AdReload')
    Registered = False
    OnEventAlert = IBEventHandler
    OnError = IBEventErrorHandler
    Left = 832
    Top = 584
  end
  object IBAdTrans: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 472
    Top = 320
  end
  object DoEvent: TIBStoredProc
    Database = IBDb
    Transaction = EventTran
    StoredProcName = 'DOEVENT'
    Left = 40
    Top = 176
  end
  object EventTran: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'concurrency'
      'nowait')
    Left = 96
    Top = 176
  end
  object IBSpTransNo: TIBStoredProc
    Database = IBDb
    Transaction = IBShiftTransaction
    StoredProcName = 'GETNEWTRANSNO'
    Left = 760
    Top = 200
  end
  object IBRptTrans: TIBTransaction
    AllowAutoStart = False
    DefaultDatabase = IBDb
    Params.Strings = (
      'read_committed'
      'rec_version'
      'nowait')
    Left = 944
    Top = 8
  end
  object IBRptSQL01Main: TIBSQL
    Database = IBDb
    Transaction = IBRptTrans
    Left = 944
    Top = 56
  end
  object IBRptSQL01Sub1: TIBSQL
    Database = IBDb
    Transaction = IBRptTrans
    Left = 1048
    Top = 56
  end
  object IBRptSQL02Main: TIBSQL
    Database = IBDb
    Transaction = IBRptTrans
    Left = 944
    Top = 104
  end
  object IBRptSQL02Sub1: TIBSQL
    Database = IBDb
    Transaction = IBRptTrans
    Left = 1048
    Top = 104
  end
  object IBRptSQL01Sub2: TIBSQL
    Database = IBDb
    Transaction = IBRptTrans
    Left = 1160
    Top = 56
  end
  object IBRptSQL03Main: TIBSQL
    Database = IBDb
    Transaction = IBRptTrans
    Left = 944
    Top = 168
  end
  object IBRptSQL03Sub1: TIBSQL
    Database = IBDb
    Transaction = IBRptTrans
    Left = 1056
    Top = 168
  end
  object IBRptSQL03Sub2: TIBSQL
    Database = IBDb
    Transaction = IBRptTrans
    Left = 1160
    Top = 168
  end
  object IBRptSQL03Sub3: TIBSQL
    Database = IBDb
    Transaction = IBRptTrans
    Left = 1056
    Top = 224
  end
  object IBRptSub1: TIBQuery
    Database = IBDb
    Transaction = IBReportTransaction
    Left = 192
    Top = 224
  end
  object IBRptSub2: TIBQuery
    Database = IBDb
    Transaction = IBReportTransaction
    Left = 248
    Top = 224
  end
  object IBRptSub3: TIBQuery
    Database = IBDb
    Transaction = IBReportTransaction
    Left = 304
    Top = 224
  end
end
