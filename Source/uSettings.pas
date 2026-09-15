unit uSettings;

{ إعدادات المؤسسة / Parametres de l'etablissement }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrmSettings = class(TForm)
    pnlMain    : TPanel;
    lblDir     : TLabel;  edDir      : TEdit;
    lblSchool  : TLabel;  edSchool   : TEdit;
    lblAddr    : TLabel;  edAddr     : TEdit;
    lblPhone   : TLabel;  edPhone    : TEdit;
    lblFax     : TLabel;  edFax      : TEdit;
    lblEmail   : TLabel;  edEmail    : TEdit;
    lblDirector: TLabel;  edDirector : TEdit;
    lblAdvisor : TLabel;  edAdvisor  : TEdit;
    gbThr      : TGroupBox;
    lblThr1    : TLabel;  edThr1     : TEdit;
    lblThr2    : TLabel;  edThr2     : TEdit;
    lblThr3    : TLabel;  edThr3     : TEdit;
    lblThrHint : TLabel;
    pnlBottom  : TPanel;
    btnSave    : TButton;
    btnClose   : TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    procedure ApplyCaptions;
    procedure LoadSettings;
  end;

procedure ShowSettingsForm;

implementation

{$R *.dfm}

uses uLang, uUtils, dmMain, uDB;

procedure ShowSettingsForm;
var
  F : TfrmSettings;
begin
  F := TfrmSettings.Create(nil);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

{ ------------------------------------------------------------------------ }

procedure TfrmSettings.ApplyCaptions;
begin
  Caption            := R_SetTitle;
  lblDir.Caption     := R_SetDirection;
  lblSchool.Caption  := R_SetSchool;
  lblAddr.Caption    := R_SetAddress;
  lblPhone.Caption   := R_SetPhone;
  lblFax.Caption     := R_SetFax;
  lblEmail.Caption   := R_SetEmail;
  lblDirector.Caption:= R_SetDirector;
  lblAdvisor.Caption := R_SetAdvisor;
  gbThr.Caption      := R_SetThresholds;
  lblThr1.Caption    := R_SetThr1;
  lblThr2.Caption    := R_SetThr2;
  lblThr3.Caption    := R_SetThr3;
  lblThrHint.Caption :=
    'عدد الغيابات غير المبررة التي يقترح عندها البرنامج تحرير الوثيقة.';
  btnSave.Caption    := R_Save;
  btnClose.Caption   := R_Close;
end;

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
  ApplyCaptions;
  LoadSettings;
  ApplyRTL(Self);
end;

procedure TfrmSettings.LoadSettings;
begin
  edDir.Text      := dm.GetSetting('DIRECTION', '');
  edSchool.Text   := dm.GetSetting('SCHOOL_NAME', R_SchoolDefault);
  edAddr.Text     := dm.GetSetting('ADDRESS', R_PlaceDefault);
  edPhone.Text    := dm.GetSetting('PHONE', '');
  edFax.Text      := dm.GetSetting('FAX', '');
  edEmail.Text    := dm.GetSetting('EMAIL', '');
  edDirector.Text := dm.GetSetting('DIRECTOR', '');
  edAdvisor.Text  := dm.GetSetting('ADVISOR', '');
  edThr1.Text     := IntToStr(dm.GetSettingInt('THRESHOLD_1', DEF_THRESHOLD_1));
  edThr2.Text     := IntToStr(dm.GetSettingInt('THRESHOLD_2', DEF_THRESHOLD_2));
  edThr3.Text     := IntToStr(dm.GetSettingInt('THRESHOLD_3', DEF_THRESHOLD_3));
end;

procedure TfrmSettings.btnSaveClick(Sender: TObject);
var
  T1, T2, T3 : Integer;
begin
  T1 := StrToIntDef(edThr1.Text, DEF_THRESHOLD_1);
  T2 := StrToIntDef(edThr2.Text, DEF_THRESHOLD_2);
  T3 := StrToIntDef(edThr3.Text, DEF_THRESHOLD_3);

  if (T1 <= 0) or (T2 <= T1) or (T3 <= T2) then
  begin
    ShowError('يجب أن تكون العتبات متزايدة : العتبة 1 < العتبة 2 < العتبة 3.');
    Exit;
  end;

  try
    dm.SetSetting('DIRECTION',   Trim(edDir.Text));
    dm.SetSetting('SCHOOL_NAME', Trim(edSchool.Text));
    dm.SetSetting('ADDRESS',     Trim(edAddr.Text));
    dm.SetSetting('PHONE',       Trim(edPhone.Text));
    dm.SetSetting('FAX',         Trim(edFax.Text));
    dm.SetSetting('EMAIL',       Trim(edEmail.Text));
    dm.SetSetting('DIRECTOR',    Trim(edDirector.Text));
    dm.SetSetting('ADVISOR',     Trim(edAdvisor.Text));
    dm.SetSetting('THRESHOLD_1', IntToStr(T1));
    dm.SetSetting('THRESHOLD_2', IntToStr(T2));
    dm.SetSetting('THRESHOLD_3', IntToStr(T3));
    ShowInfo(R_MsgSaved);
    Close;
  except
    on E: Exception do
      ShowError(E.Message);
  end;
end;

procedure TfrmSettings.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
