object dmMain: TdmMain
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 420
  Width = 640
  object conn: TADOConnection
    ConnectionString = ''
    LoginPrompt = False
    Left = 32
    Top = 24
  end
  object tblLevels: TADOTable
    Connection = conn
    CursorType = ctStatic
    LockType = ltOptimistic
    TableName = 'GradeLevels'
    Left = 32
    Top = 88
  end
  object tblSubjects: TADOTable
    Connection = conn
    CursorType = ctStatic
    LockType = ltOptimistic
    TableName = 'Subjects'
    Left = 32
    Top = 144
  end
  object tblSlots: TADOTable
    Connection = conn
    CursorType = ctStatic
    LockType = ltOptimistic
    TableName = 'TimeSlots'
    Left = 32
    Top = 200
  end
  object tblYears: TADOTable
    Connection = conn
    CursorType = ctStatic
    LockType = ltOptimistic
    TableName = 'SchoolYears'
    Left = 32
    Top = 256
  end
  object dsLevels: TDataSource
    DataSet = tblLevels
    Left = 128
    Top = 88
  end
  object dsSubjects: TDataSource
    DataSet = tblSubjects
    Left = 128
    Top = 144
  end
  object dsSlots: TDataSource
    DataSet = tblSlots
    Left = 128
    Top = 200
  end
  object dsYears: TDataSource
    DataSet = tblYears
    Left = 128
    Top = 256
  end
  object qStudents: TADOQuery
    Connection = conn
    CursorType = ctStatic
    Parameters = <>
    Left = 248
    Top = 24
  end
  object qClasses: TADOQuery
    Connection = conn
    CursorType = ctStatic
    Parameters = <>
    Left = 248
    Top = 80
  end
  object qTeachers: TADOQuery
    Connection = conn
    CursorType = ctStatic
    Parameters = <>
    Left = 248
    Top = 136
  end
  object qUsers: TADOQuery
    Connection = conn
    CursorType = ctStatic
    Parameters = <>
    Left = 248
    Top = 192
  end
  object qAbsences: TADOQuery
    Connection = conn
    CursorType = ctStatic
    Parameters = <>
    Left = 248
    Top = 248
  end
  object qNotices: TADOQuery
    Connection = conn
    CursorType = ctStatic
    Parameters = <>
    Left = 248
    Top = 304
  end
  object dsStudents: TDataSource
    DataSet = qStudents
    Left = 352
    Top = 24
  end
  object dsClasses: TDataSource
    DataSet = qClasses
    Left = 352
    Top = 80
  end
  object dsTeachers: TDataSource
    DataSet = qTeachers
    Left = 352
    Top = 136
  end
  object dsUsers: TDataSource
    DataSet = qUsers
    Left = 352
    Top = 192
  end
  object dsAbsences: TDataSource
    DataSet = qAbsences
    Left = 352
    Top = 248
  end
  object dsNotices: TDataSource
    DataSet = qNotices
    Left = 352
    Top = 304
  end
  object qWork: TADOQuery
    Connection = conn
    CursorType = ctStatic
    Parameters = <>
    Left = 472
    Top = 24
  end
  object qRep: TADOQuery
    Connection = conn
    CursorType = ctStatic
    Parameters = <>
    Left = 472
    Top = 80
  end
end
