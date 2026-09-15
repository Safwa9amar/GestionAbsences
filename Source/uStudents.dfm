object frmStudents: TfrmStudents
  Left = 60
  Top = 40
  Caption = 'Students'
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
  object pc: TPageControl
    Left = 0
    Top = 0
    Width = 1000
    Height = 640
    ActivePage = tabList
    Align = alClient
    TabOrder = 0
    OnChange = pcChange
    object tabList: TTabSheet
      Caption = 'List'
      object grdStudents: TDBGrid
        Left = 0
        Top = 48
        Width = 992
        Height = 511
        Align = alClient
        DataSource = dmMain.dsStudents
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 1
        TitleFont.Charset = ARABIC_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = [fsBold]
        OnDblClick = grdStudentsDblClick
      end
      object pnlFilter: TPanel
        Left = 0
        Top = 0
        Width = 992
        Height = 48
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lblFClass: TLabel
          Left = 12
          Top = 14
          Width = 60
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Class'
        end
        object lblFSearch: TLabel
          Left = 230
          Top = 14
          Width = 50
          Height = 21
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Search'
        end
        object lblCount: TLabel
          Left = 800
          Top = 14
          Width = 180
          Height = 21
          AutoSize = False
          Caption = 'Count'
          Font.Charset = ARABIC_CHARSET
          Font.Color = clHighlight
          Font.Height = -14
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object cbFClass: TComboBox
          Left = 76
          Top = 11
          Width = 140
          Height = 25
          Style = csDropDownList
          TabOrder = 0
          OnChange = edFSearchChange
        end
        object edFSearch: TEdit
          Left = 284
          Top = 11
          Width = 240
          Height = 25
          TabOrder = 1
          OnChange = edFSearchChange
        end
        object chkFActive: TCheckBox
          Left = 540
          Top = 13
          Width = 130
          Height = 21
          Caption = 'Active'
          Checked = True
          State = cbChecked
          TabOrder = 2
          OnClick = edFSearchChange
        end
        object btnFApply: TButton
          Left = 680
          Top = 10
          Width = 100
          Height = 28
          Caption = 'Refresh'
          TabOrder = 3
          OnClick = btnFApplyClick
        end
      end
      object pnlListBtn: TPanel
        Left = 0
        Top = 559
        Width = 992
        Height = 50
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        object btnNew: TButton
          Left = 12
          Top = 9
          Width = 100
          Height = 32
          Caption = 'New'
          TabOrder = 0
          OnClick = btnNewClick
        end
        object btnEdit: TButton
          Left = 120
          Top = 9
          Width = 100
          Height = 32
          Caption = 'Edit'
          TabOrder = 1
          OnClick = btnEditClick
        end
        object btnDelete: TButton
          Left = 228
          Top = 9
          Width = 100
          Height = 32
          Caption = 'Delete'
          TabOrder = 2
          OnClick = btnDeleteClick
        end
        object btnPrintList: TButton
          Left = 336
          Top = 9
          Width = 120
          Height = 32
          Caption = 'Print'
          TabOrder = 3
          OnClick = btnPrintListClick
        end
        object btnCloseList: TButton
          Left = 870
          Top = 9
          Width = 110
          Height = 32
          Caption = 'Close'
          TabOrder = 4
          OnClick = btnCloseListClick
        end
      end
    end
    object tabFile: TTabSheet
      Caption = 'File'
      ImageIndex = 1
      object scr: TScrollBox
        Left = 0
        Top = 0
        Width = 992
        Height = 559
        Align = alClient
        TabOrder = 0
    object lblMatricule: TLabel
      Left = 12
      Top = 19
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edMatricule: TEdit
      Left = 170
      Top = 16
      Width = 250
      Height = 25
      TabOrder = 0
    end
    object lblRegNo: TLabel
      Left = 12
      Top = 55
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edRegNo: TEdit
      Left = 170
      Top = 52
      Width = 250
      Height = 25
      TabOrder = 1
    end
    object lblLastName: TLabel
      Left = 12
      Top = 91
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edLastName: TEdit
      Left = 170
      Top = 88
      Width = 250
      Height = 25
      TabOrder = 2
    end
    object lblFirstName: TLabel
      Left = 12
      Top = 127
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edFirstName: TEdit
      Left = 170
      Top = 124
      Width = 250
      Height = 25
      TabOrder = 3
    end
    object lblGender: TLabel
      Left = 12
      Top = 163
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object cbGender: TComboBox
      Left = 170
      Top = 160
      Width = 250
      Height = 25
      Style = csDropDownList
      TabOrder = 4
    end
    object lblBirth: TLabel
      Left = 12
      Top = 199
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object dtBirth: TDateTimePicker
      Left = 170
      Top = 196
      Width = 250
      Height = 25
      Date = 40179.000000000000000000
      Format = 'dd/MM/yyyy'
      Time = 0.000000000000000000
      TabOrder = 5
    end
    object lblBirthPlace: TLabel
      Left = 12
      Top = 235
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edBirthPlace: TEdit
      Left = 170
      Top = 232
      Width = 250
      Height = 25
      TabOrder = 6
    end
    object lblClass: TLabel
      Left = 12
      Top = 271
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object cbClass: TComboBox
      Left = 170
      Top = 268
      Width = 250
      Height = 25
      Style = csDropDownList
      TabOrder = 7
    end
    object lblRegime: TLabel
      Left = 12
      Top = 307
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object cbRegime: TComboBox
      Left = 170
      Top = 304
      Width = 250
      Height = 25
      Style = csDropDownList
      TabOrder = 8
    end
    object lblEnroll: TLabel
      Left = 12
      Top = 343
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object dtEnroll: TDateTimePicker
      Left = 170
      Top = 340
      Width = 250
      Height = 25
      Date = 45000.000000000000000000
      Format = 'dd/MM/yyyy'
      Time = 0.000000000000000000
      TabOrder = 9
    end
    object lblFather: TLabel
      Left = 450
      Top = 19
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edFather: TEdit
      Left = 608
      Top = 16
      Width = 250
      Height = 25
      TabOrder = 10
    end
    object lblMother: TLabel
      Left = 450
      Top = 55
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edMother: TEdit
      Left = 608
      Top = 52
      Width = 250
      Height = 25
      TabOrder = 11
    end
    object lblSocial: TLabel
      Left = 450
      Top = 91
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object cbSocial: TComboBox
      Left = 608
      Top = 88
      Width = 250
      Height = 25
      Style = csDropDownList
      TabOrder = 12
    end
    object lblSiblings: TLabel
      Left = 450
      Top = 127
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edSiblings: TEdit
      Left = 608
      Top = 124
      Width = 250
      Height = 25
      TabOrder = 13
    end
    object lblSibSch: TLabel
      Left = 450
      Top = 163
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edSibSch: TEdit
      Left = 608
      Top = 160
      Width = 250
      Height = 25
      TabOrder = 14
    end
    object lblGuardian: TLabel
      Left = 450
      Top = 199
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edGuardian: TEdit
      Left = 608
      Top = 196
      Width = 250
      Height = 25
      TabOrder = 15
    end
    object lblGPhone: TLabel
      Left = 450
      Top = 235
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edGPhone: TEdit
      Left = 608
      Top = 232
      Width = 250
      Height = 25
      TabOrder = 16
    end
    object lblGEmail: TLabel
      Left = 450
      Top = 271
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edGEmail: TEdit
      Left = 608
      Top = 268
      Width = 250
      Height = 25
      TabOrder = 17
    end
    object lblGAddr: TLabel
      Left = 450
      Top = 307
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object edGAddr: TEdit
      Left = 608
      Top = 304
      Width = 250
      Height = 25
      TabOrder = 18
    end
    object chkActive: TCheckBox
      Left = 608
      Top = 342
      Width = 250
      Height = 21
      Caption = 'Active'
      Checked = True
      State = cbChecked
      TabOrder = 19
    end
    object lblNotes: TLabel
      Left = 12
      Top = 387
      Width = 150
      Height = 21
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'X'
    end
    object mmNotes: TMemo
      Left = 170
      Top = 382
      Width = 688
      Height = 90
      ScrollBars = ssVertical
      TabOrder = 20
    end
      end
      object pnlFileBtn: TPanel
        Left = 0
        Top = 559
        Width = 992
        Height = 50
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object btnSave: TButton
          Left = 12
          Top = 9
          Width = 110
          Height = 32
          Caption = 'Save'
          TabOrder = 0
          OnClick = btnSaveClick
        end
        object btnCancel: TButton
          Left = 130
          Top = 9
          Width = 110
          Height = 32
          Caption = 'Cancel'
          TabOrder = 1
          OnClick = btnCancelClick
        end
        object btnPrintFile: TButton
          Left = 248
          Top = 9
          Width = 130
          Height = 32
          Caption = 'Print'
          TabOrder = 2
          OnClick = btnPrintFileClick
        end
      end
    end
    object tabAbs: TTabSheet
      Caption = 'Absences'
      ImageIndex = 2
      object grdAbs: TDBGrid
        Left = 0
        Top = 70
        Width = 992
        Height = 539
        Align = alClient
        DataSource = dmMain.dsAbsences
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgCancelOnExit]
        ReadOnly = True
        TabOrder = 1
        TitleFont.Charset = ARABIC_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = [fsBold]
      end
      object pnlAbsTop: TPanel
        Left = 0
        Top = 0
        Width = 992
        Height = 70
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lblAbsStudent: TLabel
          Left = 12
          Top = 10
          Width = 800
          Height = 24
          AutoSize = False
          Caption = 'Student'
          Font.Charset = ARABIC_CHARSET
          Font.Color = clHighlight
          Font.Height = -17
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblAbsSummary: TLabel
          Left = 12
          Top = 40
          Width = 800
          Height = 22
          AutoSize = False
          Caption = 'Summary'
        end
        object btnAbsRefresh: TButton
          Left = 860
          Top = 20
          Width = 120
          Height = 32
          Caption = 'Refresh'
          TabOrder = 0
          OnClick = btnAbsRefreshClick
        end
      end
    end
  end
end
