unit QRcodeUnit;

interface

//////////QR

{function DecodePictureFile(strFilePath:string):integer;stdcall; external 'PsyQrDcd.dll';
function DecodePictureFileRect(strFilePath:string;lngLeftX:integer;lngTopY:integer;lngRightX:integer;lngBottomY:integer):integer;stdcall; external 'PsyQrDcd.dll';
function DecodeGrayScaleArray(byData:pchar;lngWidth,lngHeight:integer):integer;stdcall;external 'PsyQrDcd.dll';
function DecodeBinaryArray(byData:pchar;lngWidth,lngHeight:integer):integer;stdcall; external 'PsyQrDcd.dll';
function GetDecodeDataString(lngIndex:integer):string;stdcall; external 'PsyQrDcd.dll';
function GetDecodeDataByteArray(lngIndex:integer):integer;stdcall; external 'PsyQrDcd.dll';
function GetDecodeVersion(lngIndex:integer):integer;stdcall; external 'PsyQrDcd.dll';
function GetDecodeLevel(lngIndex:integer):integer;stdcall; external 'PsyQrDcd.dll';
function GetDecodeMaskingNo(lngIndex:integer):integer;stdcall; external 'PsyQrDcd.dll';
function GetConcatenationInfo(lngIndex:integer;lngSeqNo:integer;byCheckDigit:pchar):integer;stdcall; external 'PsyQrDcd.dll';
function GetSymbolePosition(lngIndex,lngPosition:integer):integer;stdcall; external 'PsyQrDcd.dll'
procedure SetDecodeSymbolCount(lngCount:integer);stdcall; external 'PsyQrDcd.dll'
procedure SetDecodeEffectLevel(lngLevel:integer);stdcall; external 'PsyQrDcd.dll'

procedure SetMinimumModuleSize (byBorder:pchar);stdcall; external 'PsyQrDcd.dll'
procedure FreeAllocateMemory ();stdcall; external 'PsyQrDcd.dll'

 }

function DecodePictureFile(strFilePath: string): integer; stdcall; external'PsyQrDcd.dll'  //ͼ���ļ�����
function DecodePictureFileRect(strFilePath:string;lngLeftX:integer;lngTopY:integer;lngRightX:integer;lngBottomY:integer):integer;stdcall; external 'PsyQrDcd.dll'; //ָ�����뷶Χ
function GetDecodeDataString(lngIndex: integer): PAnsiChar; stdcall; external'PsyQrDcd.dll'
procedure FreeAllocateMemory(); stdcall; external 'PsyQrDcd.dll'
procedure SetDecodeEffectLevel(lngLevel: integer); stdcall; external'PsyQrDcd.dll'
procedure SetBrightnessBorder(byBorder: pchar); stdcall; external 'PsyQrDcd.dll'

function DecodeFile(strFilePath: string): string;

//������붨��
const
  QRD_ERROR_SYMBLE_NOT_FOUND = 0; //δ�ҵ� QR �������
  QRD_ERROR_FILE_NOT_FOUND = -1; //�ļ�δ�ҵ���
  QRD_ERROR_READ_FAULT = -2; //��ȡ�ļ�ʱ��������
  QRD_ERROR_BAD_FORMAT = -3; //�޷���ȡ�˸�ʽ�ļ�
  QRD_ERROR_SHARING_VIOLATION = -4; //�����ͻ���޷���ȡ�ļ�
  QRD_ERROR_NOT_ENOUGH_MEMORY = -5; //�ڴ治��
implementation

function DecodeFile(strFilePath: string): string;
var
  lngResult, i: Integer;
  strResult: string;
begin
  SetDecodeEffectLevel(3);
  SetBrightnessBorder(0);
  lngResult := DecodePictureFile(strFilePath);
  if lngResult >= 1 then
  begin
    for i := 0 to lngResult - 1 do
    begin
      strResult := GetDecodeDataString(i);
      FreeAllocateMemory();
    end;
  end
  else
  begin
    case lngResult of
      QRD_ERROR_SYMBLE_NOT_FOUND:
        strResult := 'δ�ҵ� QR �������';
      QRD_ERROR_FILE_NOT_FOUND:
        strResult := '�ļ�δ�ҵ�!';
      QRD_ERROR_READ_FAULT:
        strResult := '��ȡ�ļ�ʱ��������';
      QRD_ERROR_BAD_FORMAT:
        strResult := '�޷���ȡ�˸�ʽ�ļ�';
      QRD_ERROR_SHARING_VIOLATION:
        strResult := '�����ͻ���޷���ȡ�ļ�';
      QRD_ERROR_NOT_ENOUGH_MEMORY:
        strResult := '�ڴ治��';
    end;
  end;
  Result := strResult;
end;

end.

