unit uUtils;

{ =============================================================================
  وحدة الخدمات المساعدة
  Unite utilitaire : hachage, messages, RTL, generation des etats HTML.
  ============================================================================= }

interface

uses
  Windows, SysUtils, Classes, Controls, Forms, Dialogs, StdCtrls, Graphics,
  ShellAPI, Variants, DB;

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

{ --- تجزئة كلمة المرور (SHA-1) ----------------------------------------- }
function SHA1Hash(const AText: string): string;

{ --- رسائل ------------------------------------------------------------- }
procedure ShowInfo(const AMsg: string);
procedure ShowError(const AMsg: string);
function  AskYesNo(const AMsg: string): Boolean;

{ --- واجهة من اليمين إلى اليسار ---------------------------------------- }
procedure ApplyRTL(AForm: TForm);

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
function  ArabicDayName(const ADate: TDateTime): string;
function  ArabicMonthName(AMonth: Integer): string;
function  FormatArabicDate(const ADate: TDateTime): string;
procedure FillCombo(ACombo: TStrings; ADataSet: TDataSet;
                    const ADisplayField, AKeyField: string;
                    AKeys: TStrings; const AFirstItem: string = '');

implementation

uses uLang;

{ ==========================================================================
  SHA-1 : تنفيذ مختصر لخوارزمية التجزئة (RFC 3174)
  ========================================================================== }

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

{ ==========================================================================
  رسائل الحوار
  ========================================================================== }

procedure ShowInfo(const AMsg: string);
begin
  MessageBox(0, PChar(AMsg), PChar(R_MsgInfoTitle),
             MB_OK or MB_ICONINFORMATION or MB_RTLREADING or MB_RIGHT);
end;

procedure ShowError(const AMsg: string);
begin
  MessageBox(0, PChar(AMsg), PChar(R_MsgErrTitle),
             MB_OK or MB_ICONERROR or MB_RTLREADING or MB_RIGHT);
end;

function AskYesNo(const AMsg: string): Boolean;
begin
  Result := MessageBox(0, PChar(AMsg), PChar(R_MsgConfirmTitle),
              MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2
              or MB_RTLREADING or MB_RIGHT) = IDYES;
end;

{ ==========================================================================
  ضبط اتجاه الواجهة من اليمين إلى اليسار
  ========================================================================== }

procedure ApplyRTL(AForm: TForm);
begin
  { يكفي ضبط اتجاه النافذة : الخاصية ParentBiDiMode مفعّلة افتراضيا في كل
    المكونات، فتتلقى تلقائيا الرسالة CM_PARENTBIDIMODECHANGED وترث الاتجاه.
    (ParentBiDiMode خاصية محمية في TControl ولا يمكن ضبطها من خارج الصنف). }
  AForm.BiDiMode := bdRightToLeft;
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

function ArabicDayName(const ADate: TDateTime): string;
const
  Days : array[1..7] of string =
    ('الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت');
begin
  Result := Days[DayOfWeek(ADate)];
end;

function ArabicMonthName(AMonth: Integer): string;
const
  Months : array[1..12] of string =
    ('جانفي', 'فيفري', 'مارس', 'أفريل', 'ماي', 'جوان',
     'جويلية', 'أوت', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر');
begin
  if (AMonth >= 1) and (AMonth <= 12) then
    Result := Months[AMonth]
  else
    Result := '';
end;

function FormatArabicDate(const ADate: TDateTime): string;
var
  Y, M, D : Word;
begin
  DecodeDate(ADate, Y, M, D);
  Result := Format('%s %d %s %d', [ArabicDayName(ADate), D, ArabicMonthName(M), Y]);
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
  FLines.Add('<html dir="rtl" lang="ar"><head><meta charset="utf-8">');
  FLines.Add('<title>' + HtmlEscape(ATitle) + '</title><style>');
  FLines.Add('@page { size: A4; margin: 12mm; }');
  FLines.Add('body { font-family: "Traditional Arabic","Simplified Arabic",' +
             '"Arial",sans-serif; font-size: 14pt; color:#000; margin:0; }');
  FLines.Add('.hdr { text-align:center; border-bottom:2px solid #000;' +
             ' padding-bottom:6px; margin-bottom:10px; }');
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
  FLines.Add('<div class="l1">الجمهورية الجزائرية الديمقراطية الشعبية</div>');
  FLines.Add('<div class="l1">وزارة التربية الوطنية</div>');
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
             '<button onclick="window.print()">طباعة</button></div>');
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
