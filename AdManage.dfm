object AdManageMod: TAdManageMod
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Left = 669
  Top = 197
  Height = 440
  Width = 144
  object AdLoad: TIBSQL
    Database = POSDataMod.IBDb
    SQL.Strings = (
      'Select * from ADS where DispOrder > 0 order by DispOrder;')
    Transaction = POSDataMod.IBAdTrans
    Left = 32
    Top = 64
  end
  object AdvedPLULoad: TIBSQL
    Database = POSDataMod.IBDb
    SQL.Strings = (
      
        'Select p.PLUNO, p.PRICE from PLU p, ADS a where a.PLUNO=p.PLUNO ' +
        'order by p.PLUNO;')
    Transaction = POSDataMod.IBAdTrans
    Left = 32
    Top = 160
  end
  object AdReloadProc: TIBStoredProc
    Database = POSDataMod.IBDb
    Transaction = POSDataMod.IBAdTrans
    StoredProcName = 'DoAdReload'
    Left = 32
    Top = 296
  end
end
