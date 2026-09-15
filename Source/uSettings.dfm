object frmSettings: TfrmSettings
  Left = 180
  Top = 60
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 672
  ClientWidth = 760
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
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 760
    Height = 612
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object lblDir: TLabel
      Left = 14
      Top = 20
      Width = 160
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edDir: TEdit
      Left = 182
      Top = 16
      Width = 520
      Height = 25
      TabOrder = 0
    end
    object lblSchool: TLabel
      Left = 14
      Top = 56
      Width = 160
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edSchool: TEdit
      Left = 182
      Top = 52
      Width = 520
      Height = 25
      TabOrder = 1
    end
    object lblAddr: TLabel
      Left = 14
      Top = 92
      Width = 160
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edAddr: TEdit
      Left = 182
      Top = 88
      Width = 520
      Height = 25
      TabOrder = 2
    end
    object lblPhone: TLabel
      Left = 14
      Top = 128
      Width = 160
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edPhone: TEdit
      Left = 182
      Top = 124
      Width = 520
      Height = 25
      TabOrder = 3
    end
    object lblFax: TLabel
      Left = 14
      Top = 164
      Width = 160
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edFax: TEdit
      Left = 182
      Top = 160
      Width = 520
      Height = 25
      TabOrder = 4
    end
    object lblEmail: TLabel
      Left = 14
      Top = 200
      Width = 160
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edEmail: TEdit
      Left = 182
      Top = 196
      Width = 520
      Height = 25
      TabOrder = 5
    end
    object lblDirector: TLabel
      Left = 14
      Top = 236
      Width = 160
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edDirector: TEdit
      Left = 182
      Top = 232
      Width = 520
      Height = 25
      TabOrder = 6
    end
    object lblAdvisor: TLabel
      Left = 14
      Top = 272
      Width = 160
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edAdvisor: TEdit
      Left = 182
      Top = 268
      Width = 520
      Height = 25
      TabOrder = 7
    end
    object gbThr: TGroupBox
      Left = 14
      Top = 306
      Width = 730
      Height = 88
      Caption = 'Thresholds'
      TabOrder = 8
      object lblThr1: TLabel
        Left = 16
        Top = 26
        Width = 120
        Height = 21
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'X'
      end
      object edThr1: TEdit
        Left = 144
        Top = 22
        Width = 70
        Height = 25
        TabOrder = 0
      end
      object lblThr2: TLabel
        Left = 236
        Top = 26
        Width = 120
        Height = 21
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'X'
      end
      object edThr2: TEdit
        Left = 364
        Top = 22
        Width = 70
        Height = 25
        TabOrder = 1
      end
      object lblThr3: TLabel
        Left = 456
        Top = 26
        Width = 120
        Height = 21
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'X'
      end
      object edThr3: TEdit
        Left = 584
        Top = 22
        Width = 70
        Height = 25
        TabOrder = 2
      end
      object lblThrHint: TLabel
        Left = 16
        Top = 58
        Width = 690
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
    end
    object gbMedia: TGroupBox
      Left = 14
      Top = 404
      Width = 730
      Height = 172
      Caption = 'Media'
      TabOrder = 9
      object lblLogo: TLabel
        Left = 16
        Top = 26
        Width = 90
        Height = 21
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'X'
      end
      object imgLogo: TImage
        Left = 114
        Top = 20
        Width = 96
        Height = 96
        Center = True
        Proportional = True
        Stretch = True
      end
      object btnLogoPick: TButton
        Left = 220
        Top = 26
        Width = 140
        Height = 30
        Caption = 'Pick'
        TabOrder = 0
        OnClick = btnLogoPickClick
      end
      object btnLogoClear: TButton
        Left = 220
        Top = 62
        Width = 140
        Height = 30
        Caption = 'Clear'
        TabOrder = 1
        OnClick = btnLogoClearClick
      end
      object lblCover: TLabel
        Left = 380
        Top = 26
        Width = 90
        Height = 21
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'X'
      end
      object imgCover: TImage
        Left = 380
        Top = 44
        Width = 330
        Height = 72
        Center = True
        Proportional = True
        Stretch = True
      end
      object btnCoverPick: TButton
        Left = 380
        Top = 124
        Width = 160
        Height = 30
        Caption = 'Pick'
        TabOrder = 2
        OnClick = btnCoverPickClick
      end
      object btnCoverClear: TButton
        Left = 550
        Top = 124
        Width = 160
        Height = 30
        Caption = 'Clear'
        TabOrder = 3
        OnClick = btnCoverClearClick
      end
      object lblImgHint: TLabel
        Left = 16
        Top = 128
        Width = 350
        Height = 34
        AutoSize = False
        WordWrap = True
        Caption = 'Hint'
        Font.Charset = ARABIC_CHARSET
        Font.Color = clGrayText
        Font.Height = -12
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 612
    Width = 760
    Height = 60
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnSave: TButton
      Left = 14
      Top = 12
      Width = 140
      Height = 36
      Caption = 'Save'
      TabOrder = 0
      OnClick = btnSaveClick
    end
    object btnClose: TButton
      Left = 604
      Top = 12
      Width = 140
      Height = 36
      Caption = 'Close'
      TabOrder = 1
      OnClick = btnCloseClick
    end
  end
  object dlgImg: TOpenDialog
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 690
    Top = 620
  end
end
