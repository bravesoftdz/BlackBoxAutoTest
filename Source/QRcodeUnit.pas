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

function DecodePictureFile(strFilePath: string): integer; stdcall; external'PsyQrDcd.dll'  //图像文件解码
function DecodePictureFileRect(strFilePath:string;lngLeftX:integer;lngTopY:integer;lngRightX:integer;lngBottomY:integer):integer;stdcall; external 'PsyQrDcd.dll'; //指定解码范围
function GetDecodeDataString(lngIndex: integer): PAnsiChar; stdcall; external'PsyQrDcd.dll'
procedure FreeAllocateMemory(); stdcall; external 'PsyQrDcd.dll'
procedure SetDecodeEffectLevel(lngLevel: integer); stdcall; external'PsyQrDcd.dll'
procedure SetBrightnessBorder(byBorder: pchar); stdcall; external 'PsyQrDcd.dll'

function DecodeFile(strFilePath: string): string;

//错误代码定义
const
  QRD_ERROR_SYMBLE_NOT_FOUND = 0; //未找到 QR 代码符号
  QRD_ERROR_FILE_NOT_FOUND = -1; //文件未找到！
  QRD_ERROR_READ_FAULT = -2; //读取文件时发生错误
  QRD_ERROR_BAD_FORMAT = -3; //无法读取此格式文件
  QRD_ERROR_SHARING_VIOLATION = -4; //共享冲突，无法读取文件
  QRD_ERROR_NOT_ENOUGH_MEMORY = -5; //内存不足
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
        strResult := '未找到 QR 代码符号';
      QRD_ERROR_FILE_NOT_FOUND:
        strResult := '文件未找到!';
      QRD_ERROR_READ_FAULT:
        strResult := '读取文件时发生错误';
      QRD_ERROR_BAD_FORMAT:
        strResult := '无法读取此格式文件';
      QRD_ERROR_SHARING_VIOLATION:
        strResult := '共享冲突，无法读取文件';
      QRD_ERROR_NOT_ENOUGH_MEMORY:
        strResult := '内存不足';
    end;
  end;
  Result := strResult;
end;

end.

