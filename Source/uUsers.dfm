object frmUsers: TfrmUsers
  Left = 150
  Top = 80
  Caption = 'Users'
  ClientHeight = 520
  ClientWidth = 820
  Color = clBtnFace
  Font.Charset = ARABIC_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 17
  object grd: TDBGrid
    Left = 0
    Top = 0
    Width = 820
    Height = 290
    Align = alClient
    DataSource = dmMain.dsUsers
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = ARABIC_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -13
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = [fsBold]
    OnCellClick = grdCellClick
  end
  object pnlEdit: TPanel
    Left = 0
    Top = 290
    Width = 820
    Height = 230
    Align = alBottom
    BevelOuter = bvNone
    BorderStyle = bsSingle
    TabOrder = 1
    object lblLogin: TLabel
      Left = 12
      Top = 18
      Width = 120
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Login'
    end
    object lblFull: TLabel
      Left = 12
      Top = 54
      Width = 120
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'FullName'
    end
    object lblRole: TLabel
      Left = 12
      Top = 90
      Width = 120
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Role'
    end
    object lblPass: TLabel
      Left = 420
      Top = 18
      Width = 130
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Password'
    end
    object lblPass2: TLabel
      Left = 420
      Top = 54
      Width = 130
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Confirm'
    end
    object lblHint: TLabel
      Left = 420
      Top = 92
      Width = 380
      Height = 20
      AutoSize = False
      Caption = 'Hint'
      Font.Charset = ARABIC_CHARSET
      Font.Color = clGrayText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object edLogin: TEdit
      Left = 140
      Top = 15
      Width = 230
      Height = 25
      TabOrder = 0
    end
    object edFull: TEdit
      Left = 140
      Top = 51
      Width = 230
      Height = 25
      TabOrder = 1
    end
    object cbRole: TComboBox
      Left = 140
      Top = 87
      Width = 230
      Height = 25
      Style = csDropDownList
      TabOrder = 2
    end
    object edPass: TEdit
      Left = 558
      Top = 15
      Width = 230
      Height = 25
      PasswordChar = '*'
      TabOrder = 3
    end
    object edPass2: TEdit
      Left = 558
      Top = 51
      Width = 230
      Height = 25
      PasswordChar = '*'
      TabOrder = 4
    end
    object chkActive: TCheckBox
      Left = 140
      Top = 126
      Width = 230
      Height = 21
      Caption = 'Active'
      Checked = True
      State = cbChecked
      TabOrder = 5
    end
    object btnNew: TButton
      Left = 12
      Top = 170
      Width = 120
      Height = 34
      Caption = 'New'
      TabOrder = 6
      OnClick = btnNewClick
    end
    object btnSave: TButton
      Left = 140
      Top = 170
      Width = 120
      Height = 34
      Caption = 'Save'
      TabOrder = 7
      OnClick = btnSaveClick
    end
    object btnDelete: TButton
      Left = 268
      Top = 170
      Width = 120
      Height = 34
      Caption = 'Delete'
      TabOrder = 8
      OnClick = btnDeleteClick
    end
    object btnClose: TButton
      Left = 668
      Top = 170
      Width = 120
      Height = 34
      Caption = 'Close'
      TabOrder = 9
      OnClick = btnCloseClick
    end
  end
end
