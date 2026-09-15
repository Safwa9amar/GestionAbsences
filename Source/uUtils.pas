unit uUtils;

{ =============================================================================
  وحدة الخدمات المساعدة
  Unite utilitaire : hachage, messages, RTL, generation des etats HTML.
  ============================================================================= }

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, Dialogs, StdCtrls, Graphics,
  ShellAPI, Variants, ComCtrls, ExtCtrls, Jpeg, PngImage, DB;

type
  TReportBuilder = class
  private
    FLines : TStringList;
    FTitle : string;
  public
    constructor Create(const ATitle: string);
    destructor  Destroy; override;
    procedure Header(const ASchool, ADirection, ASubTitle: string);
    procedure Paragraph(const AText: string);
    procedure OpenTable(const AColumns: array of string);
    procedure Row(const AValues: array of string);
    procedure RowClass(const AValues: array of string; const ACssClass: string);
    procedure CloseTable;
    procedure Signature(const ALeft, ARight: string);
    procedure PageBreak;
    procedure Raw(const AHtml: string);
    function  SaveAndOpen(const AFileName: string): string;
  end;

{ --- شعار وصورة المؤسسة / Logo et photo de l'etablissement ------------- }
var
  { مسار ملف الشعار المستعمل في ترويسة الوثائق. يضبطه dmMain بعد الاتصال. }
  ReportLogoFile : string = '';

function  MediaDir: string;
function  MediaPath(const AFileName: string): string;
function  ImportMediaFile(const ASourceFile, ABaseName: string): string;
procedure LoadImageInto(AImage: TImage; const AFileName: string);
procedure DrawCoverImage(AImage: TImage; const AFileName: string);
function  FileToBase64(const AFile: string): string;
function  FileToDataURI(const AFile: string): string;
function  ImageFilter: string;

{ --- تجزئة كلمة المرور (SHA-1) ----------------------------------------- }
function SHA1Hash(const AText: string): string;

{ --- رسائل ------------------------------------------------------------- }
procedure ShowInfo(const AMsg: string);
procedure ShowError(const AMsg: string);
function  AskYesNo(const AMsg: string): Boolean;

{ --- واجهة من اليمين إلى اليسار ---------------------------------------- }
procedure ApplyRTL(AForm: TForm);
procedure MirrorFormLayout(AForm: TForm);

{ --- أدوات عامة -------------------------------------------------------- }
function  NzStr(const AValue: Variant; const ADefault: string = ''): string;
function  NzInt(const AValue: Variant; ADefault: Integer = 0): Integer;
function  SqlDate(const ADate: TDateTime): string;
function  SqlStr(const AText: string): string;
function  BoolSql(AValue: Boolean): string;
function  IfThenStr(ACond: Boolean; const ATrue, AFalse: string): string;
function  AppDir: string;
function  ReportsDir: string;
function  HtmlEscape(const AText: string): string;
function  LocalDayName(const ADate: TDateTime): string;
function  LocalMonthName(AMonth: Integer): string;
function  FormatLongDate(const ADate: TDateTime): string;
procedure FillCombo(ACombo: TStrings; ADataSet: TDataSet;
                    const ADisplayField, AKeyField: string;
                    AKeys: TStrings; const AFirstItem: string = '');

implementation

uses uLang;

{ ==========================================================================
  SHA-1 : تنفيذ مختصر لخوارزمية التجزئة (RFC 3174)
  ========================================================================== }

(* خوارزمية SHA-1 تعتمد على حساب 32 بت يفيض عمدا (التفاف / wrap-around).
   في وضع Debug يكون فحص الفيض Q+ وفحص المدى R+ مفعّلين، فيتحول هذا
   الالتفاف المقصود إلى استثناء "Integer overflow".
   لذلك يُعطَّل الفحصان في هذا الجزء وحده، ثم يُستعاد وضعهما الأصلي بعده.
   ملاحظة : التعليق هنا بصيغة (* *) لأن تعليقات { } لا تتداخل مع التوجيهات. *)
{$IFOPT Q+}
  {$DEFINE SHA1_Q_WAS_ON}
  {$Q-}
{$ENDIF}
{$IFOPT R+}
  {$DEFINE SHA1_R_WAS_ON}
  {$R-}
{$ENDIF}

type
  TSHA1Digest = array[0..4] of LongWord;

function LRot(X: LongWord; N: Byte): LongWord;
begin
  Result := (X shl N) or (X shr (32 - N));
end;

function SwapEndian(X: LongWord): LongWord;
begin
  Result := ((X and $000000FF) shl 24) or ((X and $0000FF00) shl 8) or
            ((X and $00FF0000) shr 8) or ((X and $FF000000) shr 24);
end;

procedure SHA1Compress(var H: TSHA1Digest; const Block);
var
  W : array[0..79] of LongWord;
  A, B, C, D, E, T, F, K : LongWord;
  I : Integer;
begin
  Move(Block, W[0], 64);
  for I := 0 to 15 do
    W[I] := SwapEndian(W[I]);
  for I := 16 to 79 do
    W[I] := LRot(W[I-3] xor W[I-8] xor W[I-14] xor W[I-16], 1);

  A := H[0]; B := H[1]; C := H[2]; D := H[3]; E := H[4];

  for I := 0 to 79 do
  begin
    if I < 20 then
    begin
      F := (B and C) or ((not B) and D);
      K := $5A827999;
    end
    else if I < 40 then
    begin
      F := B xor C xor D;
      K := $6ED9EBA1;
    end
    else if I < 60 then
    begin
      F := (B and C) or (B and D) or (C and D);
      K := $8F1BBCDC;
    end
    else
    begin
      F := B xor C xor D;
      K := $CA62C1D6;
    end;
    T := LRot(A, 5) + F + E + K + W[I];
    E := D; D := C; C := LRot(B, 30); B := A; A := T;
  end;

  Inc(H[0], A); Inc(H[1], B); Inc(H[2], C); Inc(H[3], D); Inc(H[4], E);
end;

function SHA1Hash(const AText: string): string;
var
  H       : TSHA1Digest;
  Data    : UTF8String;
  Buf     : array[0..63] of Byte;
  Len, I  : Integer;
  BitLen  : Int64;
  Pos     : Integer;
begin
  H[0] := $67452301; H[1] := $EFCDAB89; H[2] := $98BADCFE;
  H[3] := $10325476; H[4] := $C3D2E1F0;

  Data   := UTF8Encode(AText);
  Len    := Length(Data);
  BitLen := Int64(Len) * 8;

  Pos := 1;
  while Len - Pos + 1 >= 64 do
  begin
    Move(Data[Pos], Buf[0], 64);
    SHA1Compress(H, Buf);
    Inc(Pos, 64);
  end;

  FillChar(Buf, SizeOf(Buf), 0);
  I := Len - Pos + 1;
  if I > 0 then
    Move(Data[Pos], Buf[0], I);
  Buf[I] := $80;

  if I >= 56 then
  begin
    SHA1Compress(H, Buf);
    FillChar(Buf, SizeOf(Buf), 0);
  end;

  for I := 0 to 7 do
    Buf[63 - I] := Byte((BitLen shr (8 * I)) and $FF);
  SHA1Compress(H, Buf);

  Result := '';
  for I := 0 to 4 do
    Result := Result + IntToHex(H[I], 8);
  Result := LowerCase(Result);
end;

{ استعادة وضع الفحص كما كان قبل كتلة SHA-1 }
{$IFDEF SHA1_R_WAS_ON}
  {$R+}
  {$UNDEF SHA1_R_WAS_ON}
{$ENDIF}
{$IFDEF SHA1_Q_WAS_ON}
  {$Q+}
  {$UNDEF SHA1_Q_WAS_ON}
{$ENDIF}

{ ==========================================================================
  شعار وصورة المؤسسة
  ========================================================================== }

function MediaDir: string;
begin
  Result := AppDir + 'Data\Media\';
  if not DirectoryExists(Result) then
    ForceDirectories(Result);
end;

function MediaPath(const AFileName: string): string;
begin
  if Trim(AFileName) = '' then
    Result := ''
  else
    Result := MediaDir + AFileName;
end;

function ImageFilter: string;
begin
  Result := 'Images (*.png;*.jpg;*.jpeg;*.bmp)|*.png;*.jpg;*.jpeg;*.bmp|' +
            'PNG (*.png)|*.png|JPEG (*.jpg;*.jpeg)|*.jpg;*.jpeg|' +
            'Bitmap (*.bmp)|*.bmp';
end;

{ تُنسخ الصورة المختارة إلى مجلد البرنامج حتى لا تضيع إذا نقل المستخدم
  الملف الأصلي. تُعيد اسم الملف المخزَّن بدون مسار. }
function ImportMediaFile(const ASourceFile, ABaseName: string): string;
var
  Ext, Dest : string;
  Old       : TSearchRec;
begin
  Result := '';
  if not FileExists(ASourceFile) then Exit;

  Ext := LowerCase(ExtractFileExt(ASourceFile));
  if (Ext <> '.png') and (Ext <> '.jpg') and
     (Ext <> '.jpeg') and (Ext <> '.bmp') then
  begin
    ShowError('صيغة الصورة غير مدعومة. استعمل PNG أو JPG أو BMP.');
    Exit;
  end;

  { حذف أي نسخة سابقة مهما كان امتدادها }
  if FindFirst(MediaDir + ABaseName + '.*', faAnyFile, Old) = 0 then
  begin
    repeat
      DeleteFile(PChar(MediaDir + Old.Name));
    until FindNext(Old) <> 0;
    FindClose(Old);
  end;

  Dest := MediaDir + ABaseName + Ext;
  if CopyFile(PChar(ASourceFile), PChar(Dest), False) then
    Result := ABaseName + Ext
  else
    ShowError('تعذر نسخ الصورة إلى مجلد البرنامج.');
end;

{ تحميل صورة في TImage مع تجاهل أي خطأ في الملف أو الصيغة }
procedure LoadImageInto(AImage: TImage; const AFileName: string);
var
  F : string;
begin
  if AImage = nil then Exit;
  AImage.Picture := nil;
  F := MediaPath(AFileName);
  if (F = '') or (not FileExists(F)) then Exit;
  try
    AImage.Picture.LoadFromFile(F);
  except
    AImage.Picture := nil;
  end;
end;

(* رسم صورة الواجهة بحيث تغطي كامل المساحة دون تشويه النِّسب :
   تُكبَّر الصورة بأكبر مقياس يغطي العرض والارتفاع معا، ثم يُقتطع الفائض
   من الجانبين. هو سلوك background-size: cover نفسه. *)
procedure DrawCoverImage(AImage: TImage; const AFileName: string);
var
  Src   : TPicture;
  Bmp   : TBitmap;
  F     : string;
  SW, SH, DW, DH, NW, NH, X, Y : Integer;
  Scale : Double;
begin
  if AImage = nil then Exit;
  AImage.Picture := nil;

  F := MediaPath(AFileName);
  if (F = '') or (not FileExists(F)) then Exit;

  DW := AImage.Width;
  DH := AImage.Height;
  if (DW <= 0) or (DH <= 0) then Exit;

  Src := TPicture.Create;
  try
    try
      Src.LoadFromFile(F);
    except
      Exit;
    end;
    SW := Src.Width;
    SH := Src.Height;
    if (SW <= 0) or (SH <= 0) then Exit;

    Scale := DW / SW;
    if (DH / SH) > Scale then
      Scale := DH / SH;

    NW := Round(SW * Scale);
    NH := Round(SH * Scale);
    X  := (DW - NW) div 2;
    Y  := (DH - NH) div 2;

    Bmp := TBitmap.Create;
    try
      Bmp.PixelFormat := pf24bit;
      Bmp.Width       := DW;
      Bmp.Height      := DH;
      Bmp.Canvas.StretchDraw(Rect(X, Y, X + NW, Y + NH), Src.Graphic);
      AImage.Picture.Assign(Bmp);
    finally
      Bmp.Free;
    end;
  finally
    Src.Free;
  end;
end;

{ ترميز Base64 : تُدرج الصورة داخل ملف التقرير نفسه، فلا يحتاج المتصفح
  إلى الوصول إلى ملف محلي عند الطباعة. }
function FileToBase64(const AFile: string): string;
const
  C = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
var
  MS      : TMemoryStream;
  Buf     : array of Byte;
  I, N, O : Integer;
  V       : Cardinal;
begin
  Result := '';
  if (AFile = '') or (not FileExists(AFile)) then Exit;

  MS := TMemoryStream.Create;
  try
    MS.LoadFromFile(AFile);
    N := MS.Size;
    if N <= 0 then Exit;
    SetLength(Buf, N);
    MS.Position := 0;
    MS.ReadBuffer(Buf[0], N);
  finally
    MS.Free;
  end;

  SetLength(Result, ((N + 2) div 3) * 4);
  O := 1;
  I := 0;
  while I + 2 < N do
  begin
    V := (Cardinal(Buf[I]) shl 16) or (Cardinal(Buf[I + 1]) shl 8) or
          Cardinal(Buf[I + 2]);
    Result[O]     := C[((V shr 18) and 63) + 1];
    Result[O + 1] := C[((V shr 12) and 63) + 1];
    Result[O + 2] := C[((V shr 6)  and 63) + 1];
    Result[O + 3] := C[( V         and 63) + 1];
    Inc(O, 4);
    Inc(I, 3);
  end;

  if N - I = 1 then
  begin
    V := Cardinal(Buf[I]) shl 16;
    Result[O]     := C[((V shr 18) and 63) + 1];
    Result[O + 1] := C[((V shr 12) and 63) + 1];
    Result[O + 2] := '=';
    Result[O + 3] := '=';
  end
  else if N - I = 2 then
  begin
    V := (Cardinal(Buf[I]) shl 16) or (Cardinal(Buf[I + 1]) shl 8);
    Result[O]     := C[((V shr 18) and 63) + 1];
    Result[O + 1] := C[((V shr 12) and 63) + 1];
    Result[O + 2] := C[((V shr 6)  and 63) + 1];
    Result[O + 3] := '=';
  end;
end;

function FileToDataURI(const AFile: string): string;
var
  Ext, Mime, B64 : string;
begin
  Result := '';
  B64 := FileToBase64(AFile);
  if B64 = '' then Exit;

  Ext := LowerCase(ExtractFileExt(AFile));
  if Ext = '.png' then
    Mime := 'image/png'
  else if (Ext = '.jpg') or (Ext = '.jpeg') then
    Mime := 'image/jpeg'
  else if Ext = '.bmp' then
    Mime := 'image/bmp'
  else
    Mime := 'application/octet-stream';

  Result := 'data:' + Mime + ';base64,' + B64;
end;

{ ==========================================================================
  رسائل الحوار
  ========================================================================== }

{ أعلام الاتجاه تُضاف فقط في اللغات التي تُكتب من اليمين إلى اليسار }
function DirFlags: Cardinal;
begin
  if IsRTL then
    Result := MB_RTLREADING or MB_RIGHT
  else
    Result := 0;
end;

procedure ShowInfo(const AMsg: string);
begin
  MessageBox(0, PChar(AMsg), PChar(R_MsgInfoTitle),
             MB_OK or MB_ICONINFORMATION or DirFlags);
end;

procedure ShowError(const AMsg: string);
begin
  MessageBox(0, PChar(AMsg), PChar(R_MsgErrTitle),
             MB_OK or MB_ICONERROR or DirFlags);
end;

function AskYesNo(const AMsg: string): Boolean;
begin
  Result := MessageBox(0, PChar(AMsg), PChar(R_MsgConfirmTitle),
              MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2 or DirFlags) = IDYES;
end;

{ ==========================================================================
  ضبط اتجاه الواجهة من اليمين إلى اليسار
  ========================================================================== }

(* خاصية BiDiMode في VCL تضبط اتجاه قراءة النص وجهة شريط التمرير فقط،
   ولا تعكس مواضع المكونات. لذلك تبقى التسمية يسار حقلها وتبقى أزرار
   الأسفل ملتصقة باليسار، وهو ما لا يناسب واجهة عربية.
   الإجراء التالي يعكس التخطيط فعليا. *)
procedure MirrorChildren(AParent: TWinControl);
var
  I, J, W : Integer;
  C       : TControl;
  A       : TAnchors;
  Kids    : TList;
begin
  W := AParent.ClientWidth;
  if W <= 0 then Exit;

  { تُجمع الأبناء أولا : تغيير Align أثناء المرور يعيد ترتيب القائمة }
  Kids := TList.Create;
  try
    for I := 0 to AParent.ControlCount - 1 do
      Kids.Add(AParent.Controls[I]);

    for I := 0 to Kids.Count - 1 do
    begin
      C := TControl(Kids[I]);

      { 1) الإرساء : يُبدَّل akLeft و akRight حتى يبقى المكون في جهته
           الجديدة عند تغيير حجم النافذة }
      A := C.Anchors;
      if (akLeft in A) <> (akRight in A) then
      begin
        if akLeft in A then
          A := A - [akLeft] + [akRight]
        else
          A := A - [akRight] + [akLeft];
        C.Anchors := A;
      end;

      { 2) الموضع أو المحاذاة }
      case C.Align of
        alNone  : C.Left  := W - C.Left - C.Width;
        alLeft  : C.Align := alRight;
        alRight : C.Align := alLeft;
      end;

      { 3) التسميات : تُبدَّل المحاذاة لأن VCL يعكسها تلقائيا في الوضع
           من اليمين إلى اليسار، فالتبديل هنا يعيدها إلى المقصود بصريا }
      if C is TLabel then
        case TLabel(C).Alignment of
          taLeftJustify  : TLabel(C).Alignment := taRightJustify;
          taRightJustify : TLabel(C).Alignment := taLeftJustify;
        end;

      { 4) ألسنة التبويب تُقلب ترتيبها ليبدأ التبويب الأول من اليمين }
      if C is TPageControl then
        with TPageControl(C) do
          for J := 0 to PageCount - 1 do
            Pages[PageCount - 1].PageIndex := J;

      { 5) نزول إلى الحاويات الداخلية }
      if (C is TWinControl) and (TWinControl(C).ControlCount > 0) then
        MirrorChildren(TWinControl(C));
    end;
  finally
    Kids.Free;
  end;
end;

procedure MirrorFormLayout(AForm: TForm);
begin
  MirrorChildren(AForm);
end;

procedure ApplyRTL(AForm: TForm);
begin
  if IsRTL then
  begin
    AForm.BiDiMode := bdRightToLeft;
    MirrorChildren(AForm);      { العكس يُطبَّق مرة واحدة عند إنشاء النافذة }
  end
  else
    AForm.BiDiMode := bdLeftToRight;
end;

{ ==========================================================================
  أدوات عامة
  ========================================================================== }

function NzStr(const AValue: Variant; const ADefault: string): string;
begin
  if VarIsNull(AValue) or VarIsEmpty(AValue) then
    Result := ADefault
  else
    Result := VarToStr(AValue);
end;

function NzInt(const AValue: Variant; ADefault: Integer): Integer;
begin
  if VarIsNull(AValue) or VarIsEmpty(AValue) then
    Result := ADefault
  else
    try
      Result := Integer(AValue);
    except
      Result := ADefault;
    end;
end;

function SqlDate(const ADate: TDateTime): string;
begin
  { صيغة التاريخ المقبولة في Jet / Access }
  Result := '#' + FormatDateTime('mm"/"dd"/"yyyy', ADate) + '#';
end;

function SqlStr(const AText: string): string;
begin
  Result := '''' + StringReplace(AText, '''', '''''', [rfReplaceAll]) + '''';
end;

function BoolSql(AValue: Boolean): string;
begin
  if AValue then Result := 'True' else Result := 'False';
end;

function IfThenStr(ACond: Boolean; const ATrue, AFalse: string): string;
begin
  if ACond then Result := ATrue else Result := AFalse;
end;

function AppDir: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
end;

function ReportsDir: string;
begin
  Result := AppDir + 'Reports\';
  if not DirectoryExists(Result) then
    CreateDir(Result);
end;

function HtmlEscape(const AText: string): string;
begin
  Result := StringReplace(AText,   '&', '&amp;',  [rfReplaceAll]);
  Result := StringReplace(Result,  '<', '&lt;',   [rfReplaceAll]);
  Result := StringReplace(Result,  '>', '&gt;',   [rfReplaceAll]);
  Result := StringReplace(Result,  '"', '&quot;', [rfReplaceAll]);
end;

{ أسماء الأيام والأشهر بالتسمية المغاربية المستعملة في الجزائر }
function LocalDayName(const ADate: TDateTime): string;
const
  DaysAR : array[1..7] of string =
    ('الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت');
  DaysFR : array[1..7] of string =
    ('Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi');
begin
  if CurrentLang = langFR then
    Result := DaysFR[DayOfWeek(ADate)]
  else
    Result := DaysAR[DayOfWeek(ADate)];
end;

function LocalMonthName(AMonth: Integer): string;
const
  MonthsAR : array[1..12] of string =
    ('جانفي', 'فيفري', 'مارس', 'أفريل', 'ماي', 'جوان',
     'جويلية', 'أوت', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر');
  MonthsFR : array[1..12] of string =
    ('janvier', 'février', 'mars', 'avril', 'mai', 'juin',
     'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre');
begin
  Result := '';
  if (AMonth < 1) or (AMonth > 12) then Exit;
  if CurrentLang = langFR then
    Result := MonthsFR[AMonth]
  else
    Result := MonthsAR[AMonth];
end;

function FormatLongDate(const ADate: TDateTime): string;
var
  Y, M, D : Word;
begin
  DecodeDate(ADate, Y, M, D);
  Result := Format('%s %d %s %d',
                   [LocalDayName(ADate), D, LocalMonthName(M), Y]);
end;

procedure FillCombo(ACombo: TStrings; ADataSet: TDataSet;
                    const ADisplayField, AKeyField: string;
                    AKeys: TStrings; const AFirstItem: string);
var
  Bm : TBookmark;
begin
  ACombo.BeginUpdate;
  try
    ACombo.Clear;
    if AKeys <> nil then AKeys.Clear;
    if AFirstItem <> '' then
    begin
      ACombo.Add(AFirstItem);
      if AKeys <> nil then AKeys.Add('0');
    end;
    if (ADataSet = nil) or (not ADataSet.Active) then Exit;
    Bm := ADataSet.GetBookmark;
    ADataSet.DisableControls;
    try
      ADataSet.First;
      while not ADataSet.Eof do
      begin
        ACombo.Add(ADataSet.FieldByName(ADisplayField).AsString);
        if AKeys <> nil then
          AKeys.Add(ADataSet.FieldByName(AKeyField).AsString);
        ADataSet.Next;
      end;
      if Bm <> nil then
      begin
        ADataSet.GotoBookmark(Bm);
        ADataSet.FreeBookmark(Bm);
      end;
    finally
      ADataSet.EnableControls;
    end;
  finally
    ACombo.EndUpdate;
  end;
end;

{ ==========================================================================
  TReportBuilder : بناء التقارير بصيغة HTML (دعم كامل للعربية والطباعة)
  ========================================================================== }

constructor TReportBuilder.Create(const ATitle: string);
begin
  inherited Create;
  FTitle  := ATitle;
  FLines  := TStringList.Create;
  FLines.Add('<!DOCTYPE html>');
  if IsRTL then
    FLines.Add('<html dir="rtl" lang="ar"><head><meta charset="utf-8">')
  else
    FLines.Add('<html dir="ltr" lang="fr"><head><meta charset="utf-8">');
  FLines.Add('<title>' + HtmlEscape(ATitle) + '</title><style>');
  FLines.Add('@page { size: A4; margin: 12mm; }');
  FLines.Add('body { font-family: "Traditional Arabic","Simplified Arabic",' +
             '"Arial",sans-serif; font-size: 14pt; color:#000; margin:0; }');
  FLines.Add('.hdr { text-align:center; border-bottom:2px solid #000;' +
             ' padding-bottom:6px; margin-bottom:10px; }');
  FLines.Add('.hdr .logo { height:78px; margin-bottom:4px; }');
  FLines.Add('.hdr .l1 { font-size:13pt; }');
  FLines.Add('.hdr .l2 { font-size:12pt; }');
  FLines.Add('.hdr .ttl { font-size:18pt; font-weight:bold; margin-top:8px;' +
             ' border:1px solid #000; display:inline-block; padding:4px 22px; }');
  FLines.Add('table { width:100%; border-collapse:collapse; margin:10px 0; }');
  FLines.Add('th,td { border:1px solid #444; padding:4px 6px; text-align:center; }');
  FLines.Add('th { background:#dce6f1; font-weight:bold; }');
  FLines.Add('tr:nth-child(even) td { background:#f6f8fb; }');
  FLines.Add('tr.warn td { background:#fde9e9; }');
  FLines.Add('tr.ok   td { background:#eaf7ea; }');
  FLines.Add('p { line-height:1.9; text-align:justify; }');
  FLines.Add('.sign { width:100%; margin-top:28px; }');
  FLines.Add('.sign td { border:none; }');
  FLines.Add('.brk { page-break-after: always; }');
  FLines.Add('@media print { .noprint { display:none; } }');
  FLines.Add('</style></head><body>');
end;

destructor TReportBuilder.Destroy;
begin
  FLines.Free;
  inherited;
end;

procedure TReportBuilder.Header(const ASchool, ADirection, ASubTitle: string);
begin
  FLines.Add('<div class="hdr">');
  if ReportLogoFile <> '' then
    FLines.Add('<img class="logo" src="' + FileToDataURI(ReportLogoFile) + '">');
  FLines.Add('<div class="l1">' + HtmlEscape(R_RepHdrRepublic) + '</div>');
  FLines.Add('<div class="l1">' + HtmlEscape(R_RepHdrMinistry) + '</div>');
  if ADirection <> '' then
    FLines.Add('<div class="l2">' + HtmlEscape(ADirection) + '</div>');
  if ASchool <> '' then
    FLines.Add('<div class="l2">' + HtmlEscape(ASchool) + '</div>');
  FLines.Add('<div class="ttl">' + HtmlEscape(FTitle) + '</div>');
  if ASubTitle <> '' then
    FLines.Add('<div class="l2" style="margin-top:6px">' +
               HtmlEscape(ASubTitle) + '</div>');
  FLines.Add('</div>');
end;

procedure TReportBuilder.Paragraph(const AText: string);
begin
  FLines.Add('<p>' + AText + '</p>');
end;

procedure TReportBuilder.OpenTable(const AColumns: array of string);
var
  I : Integer;
  S : string;
begin
  S := '<table><thead><tr>';
  for I := Low(AColumns) to High(AColumns) do
    S := S + '<th>' + HtmlEscape(AColumns[I]) + '</th>';
  FLines.Add(S + '</tr></thead><tbody>');
end;

procedure TReportBuilder.Row(const AValues: array of string);
begin
  RowClass(AValues, '');
end;

procedure TReportBuilder.RowClass(const AValues: array of string;
  const ACssClass: string);
var
  I : Integer;
  S : string;
begin
  if ACssClass = '' then
    S := '<tr>'
  else
    S := '<tr class="' + ACssClass + '">';
  for I := Low(AValues) to High(AValues) do
    S := S + '<td>' + HtmlEscape(AValues[I]) + '</td>';
  FLines.Add(S + '</tr>');
end;

procedure TReportBuilder.CloseTable;
begin
  FLines.Add('</tbody></table>');
end;

procedure TReportBuilder.Signature(const ALeft, ARight: string);
begin
  FLines.Add('<table class="sign"><tr>' +
    '<td style="text-align:right;width:50%">' + HtmlEscape(ARight) + '</td>' +
    '<td style="text-align:left;width:50%">'  + HtmlEscape(ALeft)  + '</td>' +
    '</tr></table>');
end;

procedure TReportBuilder.PageBreak;
begin
  FLines.Add('<div class="brk"></div>');
end;

procedure TReportBuilder.Raw(const AHtml: string);
begin
  FLines.Add(AHtml);
end;

function TReportBuilder.SaveAndOpen(const AFileName: string): string;
var
  FS  : TFileStream;
  Utf : UTF8String;
  Bom : array[0..2] of Byte;
begin
  FLines.Add('<div class="noprint" style="text-align:center;margin:18px">' +
             '<button onclick="window.print()">' + HtmlEscape(R_Print) +
             '</button></div>');
  FLines.Add('</body></html>');

  Result := ReportsDir + AFileName;
  Utf    := UTF8Encode(FLines.Text);
  Bom[0] := $EF; Bom[1] := $BB; Bom[2] := $BF;

  FS := TFileStream.Create(Result, fmCreate);
  try
    FS.WriteBuffer(Bom, 3);
    if Length(Utf) > 0 then
      FS.WriteBuffer(Utf[1], Length(Utf));
  finally
    FS.Free;
  end;

  ShellExecute(0, 'open', PChar(Result), nil, nil, SW_SHOWNORMAL);
end;

end.
