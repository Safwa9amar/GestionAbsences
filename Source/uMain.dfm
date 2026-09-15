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
    Left = 796
    Top = 0
    Width = 204
    Height = 601
    Align = alRight
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
    Left = 0
    Top = 0
    Width = 796
    Height = 601
    Align = alClient
    BevelOuter = bvNone
    Color = clWindow
    ParentBackground = False
    TabOrder = 2
    object lblWelcome: TLabel
      Left = 24
      Top = 28
      Width = 740
      Height = 28
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Welcome'
      Font.Charset = ARABIC_CHARSET
      Font.Color = clHighlight
      Font.Height = -21
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSchool: TLabel
      Left = 24
      Top = 66
      Width = 740
      Height = 22
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'School'
      Font.Charset = ARABIC_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblYear: TLabel
      Left = 24
      Top = 94
      Width = 740
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
    object pnlStats: TPanel
      Left = 24
      Top = 140
      Width = 740
      Height = 190
      BevelOuter = bvNone
      BorderStyle = bsSingle
      Color = clBtnFace
      ParentBackground = False
      TabOrder = 0
      object lblStatTitle: TLabel
        Left = 16
        Top = 12
        Width = 700
        Height = 24
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Stats'
        Font.Charset = ARABIC_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblStatStudents: TLabel
        Left = 16
        Top = 52
        Width = 700
        Height = 22
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'S1'
      end
      object lblStatClasses: TLabel
        Left = 16
        Top = 82
        Width = 700
        Height = 22
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'S2'
      end
      object lblStatAbsToday: TLabel
        Left = 16
        Top = 112
        Width = 700
        Height = 22
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'S3'
      end
      object lblStatUnjust: TLabel
        Left = 16
        Top = 142
        Width = 700
        Height = 22
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'S4'
      end
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
