unit facedetectUnit;

interface
function facedetect_frontal_extern (imagepath:PChar;scale:Single;min_neighbors:Integer;min_size,max_size:Integer):PInteger; stdcall; external'facedetect.dll'
function facedetect_multiview_reinforce_extern (imagepath:PChar;scale:Single;min_neighbors:Integer;min_size,max_size:Integer):PInteger; stdcall; external'facedetect.dll'
function facedetect_frontal(imagepath:PChar;scale:Single;min_neighbors:Integer;min_size,max_size:Integer):Integer;

implementation

function facedetect_frontal(imagepath:PChar;scale:Single;min_neighbors:Integer;min_size,max_size:Integer):Integer;
var
  P:PInteger;
begin
   P:=  facedetect_multiview_reinforce_extern (imagepath, scale, min_neighbors, min_size, max_size) ;
  Result:=(P^) ;
end;   

end.
