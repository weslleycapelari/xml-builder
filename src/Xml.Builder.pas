unit Xml.Builder;

{$IF DEFINED(FPC)}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
{$IF DEFINED(FPC)}
  DB,
  Generics.Collections,
{$ELSE}
  Data.DB,
  System.Generics.Collections,
{$ENDIF}
  Xml.Builder.Intf,
  Xml.Builder.Node.Intf,
  Xml.Builder.Node;

type
  IXmlNode = Xml.Builder.Node.Intf.IXmlNode;
  TXmlNode = Xml.Builder.Node.TXmlNode;
  IXmlNodeList = Xml.Builder.Node.Intf.IXmlNodeList;
  IXmlBuilder = Xml.Builder.Intf.IXmlBuilder;

  TXmlBuilder = class(TInterfacedObject, IXmlBuilder)
  private
    FVersion: string;
    FEncoding: string;
    FNodes: TList<IXmlNode>;
    function FindByTagName(const AName: string; const ARecursive: Boolean = True): IXmlNodeList;
    function Xml(const APretty: Boolean = False; const ASpaces: Integer = 2): string;
    function Build(const APretty: Boolean = False; const ASpaces: Integer = 2): string;
    function Version(const AValue: string): IXmlBuilder;
    function Encoding(const AValue: string): IXmlBuilder;
    function AddNode(const ANode: IXmlNode): IXMlBuilder;
    procedure SaveToFile(const APath: string; const APretty: Boolean = False; const ASpaces: Integer = 2);
    function XPath(const APath: string; const ARecursive: Boolean = True): IXmlNodeList;
  public                        
    constructor Create;
    destructor Destroy; override;
    class function Parse(const AText: string): IXMLBuilder;
    class function New: IXmlBuilder;
    class function Adapter(const ADataSet: TDataSet): IXmlBuilder;
  end;

implementation

{ TXmlBuilder }

uses
{$IF DEFINED(FPC)}
  SysUtils,
  StrUtils,
  Classes;
{$ELSE}
  System.SysUtils,
  System.StrUtils,
  System.Classes;
{$ENDIF}

class function TXmlBuilder.Adapter(const ADataSet: TDataSet): IXmlBuilder;
var
  I: Integer;
  LMainNode: IXmlNode;
begin
  LMainNode := TXmlNode.New(ADataSet.Name);
  for I := 0 to Pred(ADataSet.FieldCount) do
    LMainNode.AddElement(ADataSet.Fields[I].FieldName, ADataSet.Fields[I].AsString);
  Result := TXmlBuilder.Create;
  Result.AddNode(LMainNode);
end;

function TXmlBuilder.AddNode(const ANode: IXmlNode): IXMlBuilder;
begin
  Result := Self;
  FNodes.Add(ANode);
end;

function TXmlBuilder.Build(const APretty: Boolean; const ASpaces: Integer): string;
var
  LNode: IXmlNode;
begin
  Result := '<?xml';
  Result := Result + IfThen(FVersion.IsEmpty, EmptyStr, Chr(32) + 'version="' + FVersion + '"');
  Result := Result + IfThen(FEncoding.IsEmpty, EmptyStr, Chr(32) + 'encoding="' + FEncoding + '"');
  Result := Result + '?>' + IfThen(APretty, Char(10), EmptyStr);
  for LNode in FNodes do
    Result := Result + LNode.Build(APretty, ASpaces);
end;

constructor TXmlBuilder.Create;
begin
  FVersion := '1.0';
  FEncoding := 'UTF-8';
  FNodes := TList<IXmlNode>.Create;
end;

destructor TXmlBuilder.Destroy;
begin
  FNodes.Free;
  inherited;
end;

function TXmlBuilder.Encoding(const AValue: string): IXmlBuilder;
begin
  FEncoding := AValue;
  Result := Self;
end;

function TXmlBuilder.FindByTagName(const AName: string; const ARecursive: Boolean): IXmlNodeList;
var
  LNode: IXmlNode;
begin
  Result := IXmlNodeList.Create;
  for LNode in FNodes do
  begin
    if (LNode.Name.ToLower.Equals(AName.ToLower)) then
      Result.Add(LNode);

    if ARecursive then
      Result.AddRange(LNode.FindByTagName(AName, ARecursive));
  end;
end;

class function TXmlBuilder.New: IXmlBuilder;
begin
  Result := TXmlBuilder.Create;
end;

class function TXmlBuilder.Parse(const AText: string): IXMLBuilder;
var
  LXML: string;
  LStart: Int64;
  LLength: Int64;
  LContent: string;
begin
  Result := TXmlBuilder.New;

  LStart := Pos('<?xml', AText);
  if LStart > 0 then
  begin
    LLength := Pos('?>', AText, LStart) - LStart + 2;
    LXML := Copy(AText, LStart, LLength);

    if Pos('version', LXML) > 0 then
      Result.Version(Copy(LXML, Pos('version', LXML) + 9, Pos('"', LXML, Pos('version', LXML) + 9) - (Pos('version', LXML) + 9)));

    if Pos('encoding', LXML) > 0 then
      Result.Encoding(Copy(LXML, Pos('encoding', LXML) + 10, Pos('"', LXML, Pos('encoding', LXML) + 10) - (Pos('encoding', LXML) + 10)));
  end;

  LContent := AText.Replace(LXML, '', [rfIgnoreCase]);
  if not LContent.Trim.IsEmpty then
    Result.AddNode(TXmlNode.Parse(LContent));
end;

procedure TXmlBuilder.SaveToFile(const APath: string; const APretty: Boolean; const ASpaces: Integer);
var
  LStringList: TStringList;
begin
  LStringList := TStringList.Create;
  try
    LStringList.Text := Self.Build(APretty, ASpaces);
    LStringList.SaveToFile(APath);
  finally
    LStringList.Free;
  end;
end;

function TXmlBuilder.Version(const AValue: string): IXmlBuilder;
begin
  FVersion := AValue;
  Result := Self;
end;

function TXmlBuilder.Xml(const APretty: Boolean; const ASpaces: Integer): string;
begin
  Result := Self.Build(APretty, ASpaces);
end;

function TXmlBuilder.XPath(const APath: string;
  const ARecursive: Boolean): IXmlNodeList;
var
  LNode: IXmlNode;
  LRule: string;
  LPath: string;
  LList: IXmlNodeList;
  LCount: Int64;
  LStart: Int64;
  LLength: Int64;
  LTagName: string;
  LAttrRule: string;
  LAttrValue: string;
  LAttrStart: Int64;
begin
  Result := IXmlNodeList.Create;
  LStart := Pos('/', APath);
  if LStart = 0 then Exit;
  Inc(LStart);
  LLength := Pos('/', APath, LStart);
  if (LLength = 2) then
  begin
    Inc(LStart);
    LLength := Pos('/', APath, LStart);
  end;
  if (LLength <= 0) then LLength := Length(APath) + 1;
  LLength := LLength - LStart;
  LRule := Copy(APath, LStart, LLength);
  LPath := Copy(APath, LStart + LLength);
  LStart := Pos('[', LRule);
  if LStart = 0 then
    LTagName := Copy(LRule, 1)
  else
    LTagName := Copy(LRule, 1, LStart - 1);

  for LNode in FNodes do
  begin
    if (LTagName.Equals('*')) or (LNode.Name.ToLower.Equals(LTagName.ToLower)) then
      Result.Add(LNode);
  end;

  try
    if LStart = 0 then Exit;

    LStart := 1;
    while LStart > 0 do
    begin
      LStart := Pos('[@', LRule, LStart);
      if LStart = 0 then Exit;
      Inc(LStart, 2);
      LLength := Pos(']', LRule, LStart) - LStart;
      LAttrRule := Copy(LRule, LStart, LLength);
      LAttrStart := Pos('=', LAttrRule);
      if LAttrStart = 0 then
      begin
        for LCount := Result.Count - 1 downto 0 do
          if (not Result.Items[LCount].HasAttribute(LAttrRule)) then Result.Delete(LCount);
        Continue;
      end;
      Inc(LAttrStart, 1);
      LAttrValue := Copy(LAttrRule, LAttrStart);
      if LAttrValue.StartsWith('''') or LAttrValue.StartsWith('"') then LAttrValue := Copy(LAttrValue, 2);
      if LAttrValue.EndsWith('''') or LAttrValue.EndsWith('"') then LAttrValue := Copy(LAttrValue, 1, Length(LAttrValue) - 1);
      LAttrRule := Copy(LAttrRule, 1, LAttrStart - 2);
      for LCount := Result.Count - 1 downto 0 do
        if (not Result.Items[LCount].HasAttribute(LAttrRule)) or
          (not Result.Items[LCount].Attribute(LAttrRule).ToLower.Equals(LAttrValue.ToLower)) then
          Result.Delete(LCount);
    end;

  finally
    LList := IXmlNodeList.Create;
    if (ARecursive) and (not LPath.IsEmpty) then
    begin
      for LCount := Result.Count - 1 downto 0 do
      begin
        if ARecursive then
          LList.AddRange(LNode.XPath(LPath, ARecursive));
        Result.Delete(LCount);
      end;
    end;
    Result.AddRange(LList);
  end;
end;

end.
