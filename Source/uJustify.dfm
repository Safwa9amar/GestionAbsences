object frmJustify: TfrmJustify
  Left = 70
  Top = 50
  Caption = 'Justify'
  ClientHeight = 620
  ClientWidth = 1010
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
    Width = 1010
    Height = 90
    Align = alTop
    BevelOuter = bvNone
    BorderStyle = bsSingle
    TabOrder = 0
    object lblFrom: TLabel
      Left = 12
      Top = 16
      Width = 80
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'From'
    end
    object lblTo: TLabel
      Left = 258
      Top = 16
      Width = 80
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'To'
    end
    object lblClass: TLabel
      Left = 504
      Top = 16
      Width = 70
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Class'
    end
    object lblSearch: TLabel
      Left = 12
      Top = 54
      Width = 80
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Search'
    end
    object dtFrom: TDateTimePicker
      Left = 98
      Top = 13
      Width = 140
      Height = 25
      Date = 45000.000000000000000000
      Format = 'dd/MM/yyyy'
      Time = 0.000000000000000000
      TabOrder = 0
    end
    object dtTo: TDateTimePicker
      Left = 344
      Top = 13
      Width = 140
      Height = 25
      Date = 45000.000000000000000000
      Format = 'dd/MM/yyyy'
      Time = 0.000000000000000000
      TabOrder = 1
    end
    object cbClass: TComboBox
      Left = 580
      Top = 13
      Width = 150
      Height = 25
      Style = csDropDownList
      TabOrder = 2
    end
    object chkOnlyUnj: TCheckBox
      Left = 750
      Top = 15
      Width = 230
      Height = 21
      Caption = 'OnlyUnjustified'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object edSearch: TEdit
      Left = 98
      Top = 51
      Width = 240
      Height = 25
      TabOrder = 4
    end
    object btnApply: TButton
      Left = 360
      Top = 50
      Width = 130
      Height = 28
      Caption = 'Refresh'
      TabOrder = 5
      OnClick = btnApplyClick
    end
  end
  object grd: TDBGrid
    Left = 0
    Top = 90
    Width = 1010
    Height = 470
    Align = alClient
    DataSource = dmMain.dsAbsences
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgMultiSelect, dgAlwaysShowSelection, dgCancelOnExit]
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
    Top = 560
    Width = 1010
    Height = 60
    Align = alBottom
    BevelOuter = bvNone
    BorderStyle = bsSingle
    TabOrder = 2
    object lblCount: TLabel
      Left = 12
      Top = 18
      Width = 240
      Height = 22
      AutoSize = False
      Caption = 'Count'
      Font.Charset = ARABIC_CHARSET
      Font.Color = clHighlight
      Font.Height = -14
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnJustify: TButton
      Left = 290
      Top = 12
      Width = 180
      Height = 34
      Caption = 'Justify'
      TabOrder = 0
      OnClick = btnJustifyClick
    end
    object btnUnjust: TButton
      Left = 480
      Top = 12
      Width = 180
      Height = 34
      Caption = 'Unjustify'
      TabOrder = 1
      OnClick = btnUnjustClick
    end
    object btnPrint: TButton
      Left = 700
      Top = 12
      Width = 140
      Height = 34
      Caption = 'Print'
      TabOrder = 2
      OnClick = btnPrintClick
    end
    object btnClose: TButton
      Left = 870
      Top = 12
      Width = 120
      Height = 34
      Caption = 'Close'
      TabOrder = 3
      OnClick = btnCloseClick
    end
  end
end
