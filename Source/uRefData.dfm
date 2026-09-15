object frmRefData: TfrmRefData
  Left = 80
  Top = 60
  Caption = 'RefData'
  ClientHeight = 620
  ClientWidth = 992
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
    Width = 992
    Height = 566
    ActivePage = tabLevels
    Align = alClient
    TabOrder = 0
    object tabLevels: TTabSheet
      Caption = 'Levels'
      object grdLevels: TDBGrid
        Left = 0
        Top = 34
        Width = 984
        Height = 503
        Align = alClient
        DataSource = dmMain.dsLevels
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        TabOrder = 1
        TitleFont.Charset = ARABIC_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = [fsBold]
      end
      object navLevels: TDBNavigator
        Left = 0
        Top = 0
        Width = 984
        Height = 34
        DataSource = dmMain.dsLevels
        Align = alTop
        TabOrder = 0
      end
    end
    object tabClasses: TTabSheet
      Caption = 'Classes'
      ImageIndex = 1
      object grdClasses: TDBGrid
        Left = 0
        Top = 0
        Width = 984
        Height = 387
        Align = alClient
        DataSource = dmMain.dsClasses
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = ARABIC_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = [fsBold]
        OnCellClick = grdClassesCellClick
      end
      object pnlCls: TPanel
        Left = 0
        Top = 387
        Width = 984
        Height = 150
        Align = alBottom
        BevelOuter = bvNone
        BorderStyle = bsSingle
        TabOrder = 1
        object lblClsName: TLabel
          Left = 12
          Top = 18
          Width = 110
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object edClsName: TEdit
          Left = 128
          Top = 14
          Width = 160
          Height = 25
          TabOrder = 0
        end
        object lblClsLevel: TLabel
          Left = 300
          Top = 18
          Width = 90
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object cbClsLevel: TComboBox
          Left = 396
          Top = 14
          Width = 180
          Height = 25
          Style = csDropDownList
          TabOrder = 1
        end
        object lblClsYear: TLabel
          Left = 590
          Top = 18
          Width = 110
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object cbClsYear: TComboBox
          Left = 706
          Top = 14
          Width = 160
          Height = 25
          Style = csDropDownList
          TabOrder = 2
        end
        object lblClsRoom: TLabel
          Left = 12
          Top = 54
          Width = 110
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object edClsRoom: TEdit
          Left = 128
          Top = 50
          Width = 160
          Height = 25
          TabOrder = 3
        end
        object lblClsCap: TLabel
          Left = 300
          Top = 54
          Width = 90
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object edClsCap: TEdit
          Left = 396
          Top = 50
          Width = 90
          Height = 25
          TabOrder = 4
        end
        object btnClsNew: TButton
          Left = 12
          Top = 86
          Width = 110
          Height = 30
          Caption = 'New'
          TabOrder = 5
          OnClick = btnClsNewClick
        end
        object btnClsSave: TButton
          Left = 130
          Top = 86
          Width = 110
          Height = 30
          Caption = 'Save'
          TabOrder = 6
          OnClick = btnClsSaveClick
        end
        object btnClsDel: TButton
          Left = 248
          Top = 86
          Width = 110
          Height = 30
          Caption = 'Delete'
          TabOrder = 7
          OnClick = btnClsDelClick
        end
      end
    end
    object tabSubjects: TTabSheet
      Caption = 'Subjects'
      ImageIndex = 2
      object grdSubjects: TDBGrid
        Left = 0
        Top = 34
        Width = 984
        Height = 503
        Align = alClient
        DataSource = dmMain.dsSubjects
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        TabOrder = 1
        TitleFont.Charset = ARABIC_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = [fsBold]
      end
      object navSubjects: TDBNavigator
        Left = 0
        Top = 0
        Width = 984
        Height = 34
        DataSource = dmMain.dsSubjects
        Align = alTop
        TabOrder = 0
      end
    end
    object tabTeachers: TTabSheet
      Caption = 'Teachers'
      ImageIndex = 3
      object grdTeachers: TDBGrid
        Left = 0
        Top = 0
        Width = 984
        Height = 387
        Align = alClient
        DataSource = dmMain.dsTeachers
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 0
        TitleFont.Charset = ARABIC_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = [fsBold]
        OnCellClick = grdTeachersCellClick
      end
      object pnlTch: TPanel
        Left = 0
        Top = 387
        Width = 984
        Height = 150
        Align = alBottom
        BevelOuter = bvNone
        BorderStyle = bsSingle
        TabOrder = 1
        object lblTchLast: TLabel
          Left = 12
          Top = 18
          Width = 110
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object edTchLast: TEdit
          Left = 128
          Top = 14
          Width = 160
          Height = 25
          TabOrder = 0
        end
        object lblTchFirst: TLabel
          Left = 300
          Top = 18
          Width = 90
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object edTchFirst: TEdit
          Left = 396
          Top = 14
          Width = 160
          Height = 25
          TabOrder = 1
        end
        object lblTchSubj: TLabel
          Left = 590
          Top = 18
          Width = 110
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object cbTchSubj: TComboBox
          Left = 706
          Top = 14
          Width = 200
          Height = 25
          Style = csDropDownList
          TabOrder = 2
        end
        object lblTchPhone: TLabel
          Left = 12
          Top = 54
          Width = 110
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object edTchPhone: TEdit
          Left = 128
          Top = 50
          Width = 160
          Height = 25
          TabOrder = 3
        end
        object lblTchEmail: TLabel
          Left = 300
          Top = 54
          Width = 90
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'X'
        end
        object edTchEmail: TEdit
          Left = 396
          Top = 50
          Width = 240
          Height = 25
          TabOrder = 4
        end
        object btnTchNew: TButton
          Left = 12
          Top = 86
          Width = 110
          Height = 30
          Caption = 'New'
          TabOrder = 5
          OnClick = btnTchNewClick
        end
        object btnTchSave: TButton
          Left = 130
          Top = 86
          Width = 110
          Height = 30
          Caption = 'Save'
          TabOrder = 6
          OnClick = btnTchSaveClick
        end
        object btnTchDel: TButton
          Left = 248
          Top = 86
          Width = 110
          Height = 30
          Caption = 'Delete'
          TabOrder = 7
          OnClick = btnTchDelClick
        end
      end
    end
    object tabSlots: TTabSheet
      Caption = 'Slots'
      ImageIndex = 4
      object grdSlots: TDBGrid
        Left = 0
        Top = 34
        Width = 984
        Height = 503
        Align = alClient
        DataSource = dmMain.dsSlots
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        TabOrder = 1
        TitleFont.Charset = ARABIC_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = [fsBold]
      end
      object navSlots: TDBNavigator
        Left = 0
        Top = 0
        Width = 984
        Height = 34
        DataSource = dmMain.dsSlots
        Align = alTop
        TabOrder = 0
      end
    end
    object tabYears: TTabSheet
      Caption = 'Years'
      ImageIndex = 5
      object grdYears: TDBGrid
        Left = 0
        Top = 34
        Width = 984
        Height = 463
        Align = alClient
        DataSource = dmMain.dsYears
        Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
        TabOrder = 1
        TitleFont.Charset = ARABIC_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = [fsBold]
      end
      object navYears: TDBNavigator
        Left = 0
        Top = 0
        Width = 984
        Height = 34
        DataSource = dmMain.dsYears
        Align = alTop
        TabOrder = 0
      end
      object pnlYears: TPanel
        Left = 0
        Top = 493
        Width = 984
        Height = 44
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        object btnSetCurrent: TButton
          Left = 12
          Top = 6
          Width = 200
          Height = 32
          Caption = 'SetCurrent'
          TabOrder = 0
          OnClick = btnSetCurrentClick
        end
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 566
    Width = 992
    Height = 54
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnClose: TButton
      Left = 862
      Top = 10
      Width = 116
      Height = 34
      Caption = 'Close'
      TabOrder = 0
      OnClick = btnCloseClick
    end
  end
end
