object frmDocs: TfrmDocs
  Left = 60
  Top = 50
  Caption = 'Docs'
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
  object pc: TPageControl
    Left = 0
    Top = 0
    Width = 1000
    Height = 546
    ActivePage = tabPermit
    Align = alClient
    TabOrder = 0
    object tabPermit: TTabSheet
      Caption = 'Permit'
      object grdPermit: TDBGrid
        Left = 0
        Top = 0
        Width = 992
        Height = 371
        Align = alClient
        DataSource = dsPermit
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = ARABIC_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = [fsBold]
        OnCellClick = grdPermitCellClick
      end
      object pnlPermit: TPanel
        Left = 0
        Top = 371
        Width = 992
        Height = 146
        Align = alBottom
        BevelOuter = bvNone
        BorderStyle = bsSingle
        TabOrder = 1
        object lblPClass: TLabel
          Left = 10
          Top = 18
          Width = 70
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object cbPClass: TComboBox
          Left = 86
          Top = 14
          Width = 120
          Height = 25
          Style = csDropDownList
          TabOrder = 0
          OnChange = cbPClassChange
        end
        object lblPStudent: TLabel
          Left = 220
          Top = 18
          Width = 70
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object cbPStudent: TComboBox
          Left = 296
          Top = 14
          Width = 300
          Height = 25
          Style = csDropDownList
          TabOrder = 1
        end
        object lblPDate: TLabel
          Left = 610
          Top = 18
          Width = 60
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object dtPDate: TDateTimePicker
          Left = 676
          Top = 14
          Width = 130
          Height = 25
          Date = 45000.000000000000000000
          Format = 'dd/MM/yyyy'
          Time = 0.000000000000000000
          TabOrder = 2
        end
        object lblPTime: TLabel
          Left = 820
          Top = 18
          Width = 60
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object edPTime: TEdit
          Left = 886
          Top = 14
          Width = 80
          Height = 25
          TabOrder = 3
        end
        object lblPReason: TLabel
          Left = 10
          Top = 54
          Width = 70
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object edPReason: TEdit
          Left = 86
          Top = 50
          Width = 510
          Height = 25
          TabOrder = 4
        end
        object btnPNew: TButton
          Left = 10
          Top = 90
          Width = 110
          Height = 32
          Caption = 'New'
          TabOrder = 5
          OnClick = btnPNewClick
        end
        object btnPSave: TButton
          Left = 128
          Top = 90
          Width = 110
          Height = 32
          Caption = 'Save'
          TabOrder = 6
          OnClick = btnPSaveClick
        end
        object btnPDel: TButton
          Left = 246
          Top = 90
          Width = 110
          Height = 32
          Caption = 'Delete'
          TabOrder = 7
          OnClick = btnPDelClick
        end
        object btnPPrint: TButton
          Left = 380
          Top = 90
          Width = 150
          Height = 32
          Caption = 'Print'
          TabOrder = 8
          OnClick = btnPPrintClick
        end
      end
    end
    object tabCert: TTabSheet
      Caption = 'Certificate'
      ImageIndex = 1
      object grdCert: TDBGrid
        Left = 0
        Top = 0
        Width = 992
        Height = 371
        Align = alClient
        DataSource = dsCert
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = ARABIC_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = [fsBold]
        OnCellClick = grdCertCellClick
      end
      object pnlCert: TPanel
        Left = 0
        Top = 371
        Width = 992
        Height = 146
        Align = alBottom
        BevelOuter = bvNone
        BorderStyle = bsSingle
        TabOrder = 1
        object lblCClass: TLabel
          Left = 10
          Top = 18
          Width = 70
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object cbCClass: TComboBox
          Left = 86
          Top = 14
          Width = 120
          Height = 25
          Style = csDropDownList
          TabOrder = 0
          OnChange = cbCClassChange
        end
        object lblCStudent: TLabel
          Left = 220
          Top = 18
          Width = 70
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object cbCStudent: TComboBox
          Left = 296
          Top = 14
          Width = 300
          Height = 25
          Style = csDropDownList
          TabOrder = 1
        end
        object lblCNo: TLabel
          Left = 610
          Top = 18
          Width = 60
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object edCNo: TEdit
          Left = 676
          Top = 14
          Width = 90
          Height = 25
          TabOrder = 2
        end
        object lblCDate: TLabel
          Left = 780
          Top = 18
          Width = 60
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object dtCDate: TDateTimePicker
          Left = 846
          Top = 14
          Width = 130
          Height = 25
          Date = 45000.000000000000000000
          Format = 'dd/MM/yyyy'
          Time = 0.000000000000000000
          TabOrder = 3
        end
        object lblCPurpose: TLabel
          Left = 10
          Top = 54
          Width = 70
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object edCPurpose: TEdit
          Left = 86
          Top = 50
          Width = 510
          Height = 25
          TabOrder = 4
        end
        object lblCCopies: TLabel
          Left = 610
          Top = 54
          Width = 60
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object edCCopies: TEdit
          Left = 676
          Top = 50
          Width = 70
          Height = 25
          TabOrder = 5
        end
        object btnCNew: TButton
          Left = 10
          Top = 90
          Width = 110
          Height = 32
          Caption = 'New'
          TabOrder = 6
          OnClick = btnCNewClick
        end
        object btnCSave: TButton
          Left = 128
          Top = 90
          Width = 110
          Height = 32
          Caption = 'Save'
          TabOrder = 7
          OnClick = btnCSaveClick
        end
        object btnCDel: TButton
          Left = 246
          Top = 90
          Width = 110
          Height = 32
          Caption = 'Delete'
          TabOrder = 8
          OnClick = btnCDelClick
        end
        object btnCPrint: TButton
          Left = 380
          Top = 90
          Width = 150
          Height = 32
          Caption = 'Print'
          TabOrder = 9
          OnClick = btnCPrintClick
        end
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 546
    Width = 1000
    Height = 54
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
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
  object dsPermit: TDataSource
    Left = 40
    Top = 560
  end
  object dsCert: TDataSource
    Left = 100
    Top = 560
  end
end
