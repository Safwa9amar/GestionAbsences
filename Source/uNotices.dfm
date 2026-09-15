object frmNotices: TfrmNotices
  Left = 50
  Top = 40
  Caption = 'Notices'
  ClientHeight = 640
  ClientWidth = 1000
  Color = clBtnFace
  Font.Charset = ARABIC_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 17
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 1000
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    BorderStyle = bsSingle
    TabOrder = 0
    object lblFKind: TLabel
      Left = 10
      Top = 16
      Width = 70
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Kind'
    end
    object lblFClass: TLabel
      Left = 250
      Top = 16
      Width = 60
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Class'
    end
    object lblFFrom: TLabel
      Left = 420
      Top = 16
      Width = 50
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'From'
    end
    object lblFTo: TLabel
      Left = 620
      Top = 16
      Width = 40
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'To'
    end
    object cbFKind: TComboBox
      Left = 86
      Top = 13
      Width = 150
      Height = 25
      Style = csDropDownList
      TabOrder = 0
    end
    object cbFClass: TComboBox
      Left = 316
      Top = 13
      Width = 90
      Height = 25
      Style = csDropDownList
      TabOrder = 1
    end
    object dtFFrom: TDateTimePicker
      Left = 476
      Top = 13
      Width = 130
      Height = 25
      Date = 45000.000000000000000000
      Format = 'dd/MM/yyyy'
      Time = 0.000000000000000000
      TabOrder = 2
    end
    object dtFTo: TDateTimePicker
      Left = 666
      Top = 13
      Width = 130
      Height = 25
      Date = 45000.000000000000000000
      Format = 'dd/MM/yyyy'
      Time = 0.000000000000000000
      TabOrder = 3
    end
    object btnApply: TButton
      Left = 806
      Top = 12
      Width = 80
      Height = 28
      Caption = 'Refresh'
      TabOrder = 4
      OnClick = btnApplyClick
    end
    object btnGenerate: TButton
      Left = 892
      Top = 12
      Width = 96
      Height = 28
      Caption = 'Generate'
      TabOrder = 5
      OnClick = btnGenerateClick
    end
  end
  object grd: TDBGrid
    Left = 0
    Top = 56
    Width = 1000
    Height = 416
    Align = alClient
    DataSource = dmMain.dsNotices
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = ARABIC_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -13
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = [fsBold]
    OnCellClick = grdCellClick
  end
  object pnlEdit: TPanel
    Left = 0
    Top = 472
    Width = 1000
    Height = 168
    Align = alBottom
    BevelOuter = bvNone
    BorderStyle = bsSingle
    TabOrder = 2
      object lblClass: TLabel
        Left = 10
        Top = 16
        Width = 70
        Height = 21
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'X'
      end
      object cbClass: TComboBox
        Left = 86
        Top = 12
        Width = 130
        Height = 25
        Style = csDropDownList
        TabOrder = 0
        OnChange = cbClassChange
      end
      object lblStudent: TLabel
        Left = 230
        Top = 16
        Width = 70
        Height = 21
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'X'
      end
      object cbStudent: TComboBox
        Left = 306
        Top = 12
        Width = 280
        Height = 25
        Style = csDropDownList
        TabOrder = 1
      end
      object lblKind: TLabel
        Left = 600
        Top = 16
        Width = 70
        Height = 21
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'X'
      end
      object cbKind: TComboBox
        Left = 676
        Top = 12
        Width = 240
        Height = 25
        Style = csDropDownList
        TabOrder = 2
        OnChange = cbKindChange
      end
      object lblNo: TLabel
        Left = 10
        Top = 52
        Width = 70
        Height = 21
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'X'
      end
      object edNo: TEdit
        Left = 86
        Top = 48
        Width = 130
        Height = 25
        TabOrder = 3
      end
      object lblIssue: TLabel
        Left = 230
        Top = 52
        Width = 70
        Height = 21
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'X'
      end
      object dtIssue: TDateTimePicker
        Left = 306
        Top = 48
        Width = 140
        Height = 25
        Date = 45000.000000000000000000
        Format = 'dd/MM/yyyy'
        Time = 0.000000000000000000
        TabOrder = 4
      end
      object lblMeet: TLabel
        Left = 460
        Top = 52
        Width = 80
        Height = 21
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'X'
      end
      object dtMeet: TDateTimePicker
        Left = 546
        Top = 48
        Width = 140
        Height = 25
        Date = 45000.000000000000000000
        Format = 'dd/MM/yyyy'
        Time = 0.000000000000000000
        TabOrder = 5
      end
      object lblMeetTime: TLabel
        Left = 700
        Top = 52
        Width = 60
        Height = 21
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'X'
      end
      object edMeetTime: TEdit
        Left = 766
        Top = 48
        Width = 70
        Height = 25
        TabOrder = 6
      end
      object lblAbsCount: TLabel
        Left = 850
        Top = 52
        Width = 60
        Height = 21
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'X'
      end
      object edAbsCount: TEdit
        Left = 916
        Top = 48
        Width = 60
        Height = 25
        TabOrder = 7
      end
      object lblTopic: TLabel
        Left = 10
        Top = 88
        Width = 70
        Height = 21
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'X'
      end
      object edTopic: TEdit
        Left = 86
        Top = 84
        Width = 600
        Height = 25
        TabOrder = 8
      end
      object chkDelivered: TCheckBox
        Left = 700
        Top = 87
        Width = 200
        Height = 21
        Caption = 'Delivered'
        TabOrder = 9
      end
      object btnNew: TButton
        Left = 10
        Top = 122
        Width = 110
        Height = 32
        Caption = 'New'
        TabOrder = 10
        OnClick = btnNewClick
      end
      object btnSave: TButton
        Left = 128
        Top = 122
        Width = 110
        Height = 32
        Caption = 'Save'
        TabOrder = 11
        OnClick = btnSaveClick
      end
      object btnDelete: TButton
        Left = 246
        Top = 122
        Width = 110
        Height = 32
        Caption = 'Delete'
        TabOrder = 12
        OnClick = btnDeleteClick
      end
      object btnPrintDoc: TButton
        Left = 380
        Top = 122
        Width = 180
        Height = 32
        Caption = 'PrintDoc'
        TabOrder = 13
        OnClick = btnPrintDocClick
      end
      object btnClose: TButton
        Left = 866
        Top = 122
        Width = 110
        Height = 32
        Caption = 'Close'
        TabOrder = 14
        OnClick = btnCloseClick
      end
  end
end
