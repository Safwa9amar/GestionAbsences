object frmReports: TfrmReports
  Left = 60
  Top = 50
  Caption = 'Reports'
  ClientHeight = 600
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
    Height = 96
    Align = alTop
    BevelOuter = bvNone
    BorderStyle = bsSingle
    TabOrder = 0
    object lblType: TLabel
      Left = 12
      Top = 16
      Width = 90
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Type'
    end
    object lblFrom: TLabel
      Left = 380
      Top = 16
      Width = 60
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'From'
    end
    object lblTo: TLabel
      Left = 590
      Top = 16
      Width = 40
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'To'
    end
    object lblClass: TLabel
      Left = 12
      Top = 54
      Width = 90
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Class'
    end
    object lblTop: TLabel
      Left = 260
      Top = 54
      Width = 80
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Top'
    end
    object cbType: TComboBox
      Left = 108
      Top = 13
      Width = 250
      Height = 25
      Style = csDropDownList
      TabOrder = 0
      OnChange = cbTypeChange
    end
    object dtFrom: TDateTimePicker
      Left = 446
      Top = 13
      Width = 130
      Height = 25
      Date = 45000.000000000000000000
      Format = 'dd/MM/yyyy'
      Time = 0.000000000000000000
      TabOrder = 1
    end
    object dtTo: TDateTimePicker
      Left = 636
      Top = 13
      Width = 130
      Height = 25
      Date = 45000.000000000000000000
      Format = 'dd/MM/yyyy'
      Time = 0.000000000000000000
      TabOrder = 2
    end
    object cbClass: TComboBox
      Left = 108
      Top = 51
      Width = 140
      Height = 25
      Style = csDropDownList
      TabOrder = 3
    end
    object edTop: TEdit
      Left = 346
      Top = 51
      Width = 70
      Height = 25
      TabOrder = 4
      Text = '20'
    end
    object btnPreview: TButton
      Left = 790
      Top = 12
      Width = 90
      Height = 32
      Caption = 'Preview'
      TabOrder = 5
      OnClick = btnPreviewClick
    end
    object btnPrint: TButton
      Left = 886
      Top = 12
      Width = 100
      Height = 32
      Caption = 'Print'
      Font.Charset = ARABIC_CHARSET
      Font.Color = clWindowText
      Font.Height = -14
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 6
      OnClick = btnPrintClick
    end
  end
  object grd: TDBGrid
    Left = 0
    Top = 96
    Width = 1000
    Height = 450
    Align = alClient
    DataSource = dsRep
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = ARABIC_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -13
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = [fsBold]
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 546
    Width = 1000
    Height = 54
    Align = alBottom
    BevelOuter = bvNone
    BorderStyle = bsSingle
    TabOrder = 2
    object lblInfo: TLabel
      Left = 12
      Top = 16
      Width = 800
      Height = 22
      AutoSize = False
      Caption = 'Info'
      Font.Charset = ARABIC_CHARSET
      Font.Color = clGrayText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object btnClose: TButton
      Left = 870
      Top = 10
      Width = 116
      Height = 34
      Caption = 'Close'
      TabOrder = 0
      OnClick = btnCloseClick
    end
  end
  object dsRep: TDataSource
    Left = 40
    Top = 560
  end
end
