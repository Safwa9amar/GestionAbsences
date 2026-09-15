object frmMain: TfrmMain
  Left = 100
  Top = 60
  Caption = 'Main'
  ClientHeight = 620
  ClientWidth = 1000
  Color = clBtnFace
  Font.Charset = ARABIC_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mnu
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object sb: TStatusBar
    Left = 0
    Top = 601
    Width = 1000
    Height = 19
    Panels = <
      item
        Text = 'User'
        Width = 320
      end
      item
        Text = 'Date'
        Width = 380
      end
      item
        Text = 'DB'
        Width = 250
      end>
  end
  object pnlSide: TPanel
    Left = 0
    Top = 0
    Width = 204
    Height = 601
    Align = alLeft
    BevelOuter = bvNone
    Color = clInactiveCaption
    ParentBackground = False
    TabOrder = 1
    object btnStudents: TSpeedButton
      Left = 12
      Top = 20
      Width = 180
      Height = 45
      Caption = 'Students'
      Flat = True
      Font.Charset = ARABIC_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = miStudentsClick
    end
    object btnAbsence: TSpeedButton
      Left = 12
      Top = 75
      Width = 180
      Height = 45
      Caption = 'Absence'
      Flat = True
      Font.Charset = ARABIC_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = miDailyAbsClick
    end
    object btnJustify: TSpeedButton
      Left = 12
      Top = 130
      Width = 180
      Height = 45
      Caption = 'Justify'
      Flat = True
      Font.Charset = ARABIC_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = miJustifyClick
    end
    object btnNotices: TSpeedButton
      Left = 12
      Top = 185
      Width = 180
      Height = 45
      Caption = 'Notices'
      Flat = True
      Font.Charset = ARABIC_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = miNoticesClick
    end
    object btnReports: TSpeedButton
      Left = 12
      Top = 240
      Width = 180
      Height = 45
      Caption = 'Reports'
      Flat = True
      Font.Charset = ARABIC_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = miReportsClick
    end
    object btnRefData: TSpeedButton
      Left = 12
      Top = 295
      Width = 180
      Height = 45
      Caption = 'RefData'
      Flat = True
      Font.Charset = ARABIC_CHARSET
      Font.Color = clWhite
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = miRefDataClick
    end
  end
  object pnlClient: TPanel
    Left = 204
    Top = 0
    Width = 796
    Height = 601
    Align = alClient
    BevelOuter = bvNone
    Color = clWindow
    ParentBackground = False
    TabOrder = 2
    object imgCover: TImage
      Left = 0
      Top = 0
      Width = 796
      Height = 140
      Align = alTop
      Center = True
      Proportional = True
      Stretch = True
      Visible = False
    end
    object pnlHeader: TPanel
      Left = 0
      Top = 140
      Width = 796
      Height = 108
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object imgLogo: TImage
        Left = 16
        Top = 12
        Width = 84
        Height = 84
        Center = True
        Proportional = True
        Stretch = True
      end
      object lblSchool: TLabel
        Left = 112
        Top = 14
        Width = 660
        Height = 28
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'School'
        Font.Charset = ARABIC_CHARSET
        Font.Color = clWindowText
        Font.Height = -20
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblYear: TLabel
        Left = 112
        Top = 46
        Width = 660
        Height = 22
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Year'
        Font.Charset = ARABIC_CHARSET
        Font.Color = clGrayText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblWelcome: TLabel
        Left = 112
        Top = 72
        Width = 660
        Height = 22
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Welcome'
        Font.Charset = ARABIC_CHARSET
        Font.Color = clHighlight
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlCards: TPanel
      Left = 0
      Top = 248
      Width = 796
      Height = 353
      Align = alClient
      BevelOuter = bvNone
      Color = clWindow
      ParentBackground = False
      TabOrder = 1
      OnResize = pnlCardsResize
    end
  end
  object mnu: TMainMenu
    Left = 40
    Top = 400
    object miFile: TMenuItem
      Caption = 'File'
      object miLogout: TMenuItem
        Caption = 'Logout'
        OnClick = miLogoutClick
      end
      object miSep1: TMenuItem
        Caption = '-'
      end
      object miExit: TMenuItem
        Caption = 'Exit'
        OnClick = miExitClick
      end
    end
    object miData: TMenuItem
      Caption = 'Data'
      object miStudents: TMenuItem
        Caption = 'Students'
        OnClick = miStudentsClick
      end
      object miRefData: TMenuItem
        Caption = 'RefData'
        OnClick = miRefDataClick
      end
    end
    object miAbsence: TMenuItem
      Caption = 'Absence'
      object miDailyAbs: TMenuItem
        Caption = 'Daily'
        OnClick = miDailyAbsClick
      end
      object miJustify: TMenuItem
        Caption = 'Justify'
        OnClick = miJustifyClick
      end
    end
    object miDocs: TMenuItem
      Caption = 'Docs'
      object miNotices: TMenuItem
        Caption = 'Notices'
        OnClick = miNoticesClick
      end
      object miPermit: TMenuItem
        Caption = 'Permit'
        OnClick = miPermitClick
      end
      object miCertificate: TMenuItem
        Caption = 'Certificate'
        OnClick = miCertificateClick
      end
    end
    object miReports: TMenuItem
      Caption = 'Reports'
      object miRepDaily: TMenuItem
        Caption = 'Daily'
        OnClick = miReportsClick
      end
      object miRepRegister: TMenuItem
        Caption = 'Register'
        OnClick = miReportsClick
      end
      object miRepStats: TMenuItem
        Caption = 'Stats'
        OnClick = miReportsClick
      end
    end
    object miTools: TMenuItem
      Caption = 'Tools'
      object miUsers: TMenuItem
        Caption = 'Users'
        OnClick = miUsersClick
      end
      object miSettings: TMenuItem
        Caption = 'Settings'
        OnClick = miSettingsClick
      end
      object miLang: TMenuItem
        Caption = 'Language'
        object miLangAR: TMenuItem
          Caption = 'Arabic'
          GroupIndex = 1
          RadioItem = True
          OnClick = miLangClick
        end
        object miLangFR: TMenuItem
          Caption = 'French'
          GroupIndex = 1
          RadioItem = True
          OnClick = miLangClick
        end
      end
      object miSep2: TMenuItem
        Caption = '-'
      end
      object miBackup: TMenuItem
        Caption = 'Backup'
        OnClick = miBackupClick
      end
      object miRestore: TMenuItem
        Caption = 'Restore'
        OnClick = miRestoreClick
      end
    end
    object miHelp: TMenuItem
      Caption = 'Help'
      object miAbout: TMenuItem
        Caption = 'About'
        OnClick = miAboutClick
      end
    end
  end
  object tmr: TTimer
    Interval = 1000
    OnTimer = tmrTimer
    Left = 104
    Top = 400
  end
  object dlgSave: TSaveDialog
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 168
    Top = 400
  end
  object dlgOpen: TOpenDialog
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 232
    Top = 400
  end
end
