unit Xml.Builder.Node;

{$IF DEFINED(FPC)}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  Xml.Builder.Node.Intf,
{$IF DEFINED(FPC)}
  Classes,
  Generics.Collections;
{$ELSE}
  System.Classes,
  System.Generics.Collections;
{$ENDIF}

type

  { TXmlNode }

  TXmlNode = class(TInterfacedObject, IXmlNode)
  strict private 
    function SpaceLines(const AText: string; const ASpaces: Integer): string;
    function GetSpaces(const ASpaces: Integer): string;
  private                        
    FName: string;
    FValue: string;
    FNodes: IXmlNodeList;
    FIsNode: Boolean;
    FAttributes: TDictionary<string, string>;
  protected
    function Build(const APretty: Boolean = False; const ASpaces: Integer = 2): string;
    function Name: string;
    function AddNode(const ANode: IXmlNode): IXmlNode;
    function AddElement(const AName: string): IXmlNode; overload;
    function AddElement(const AName, AValue: string): IXmlNode; overload;
    function AddAttribute(const AName, AValue: string): IXmlNode;
    function HasAttribute(const AName: string): Boolean;
    function Attribute(const AName: string): string;
    function FindByTagName(const AName: string; const ARecursive: Boolean = True): IXmlNodeList;
    function Value(const APretty: Boolean = False; const ASpaces: Integer = 2): string; overload;
    function Value(const AValue: string): IXmlNode; overload;
    function XPath(const APath: string; const ARecursive: Boolean = True): IXmlNodeList;
  public                                         
    constructor Create(const AName: string); reintroduce;
    destructor Destroy; override;
    class function Parse(const AText: string): IXmlNode;
    class function New(const AName: string): IXmlNode;
  end;

implementation

uses
{$IF DEFINED(FPC)}
  StrUtils,
  SysUtils;
{$ELSE}
  System.StrUtils,
  System.SysUtils;
{$ENDIF}

{ TXmlNode }

function TXmlNode.AddElement(const AName: string): IXmlNode;
begin                       
  FNodes.Add(TXmlNode.New(AName));
  FIsNode := FNodes.Count > 0; 
  Result := Self;
end;

function TXmlNode.AddAttribute(const AName, AValue: string): IXmlNode;
begin
  FAttributes.AddOrSetValue(AName, AValue);
  Result := Self;
end;

function TXmlNode.AddElement(const AName, AValue: string): IXmlNode;
begin
  FNodes.Add(TXmlNode.New(AName).Value(AValue));
  FIsNode := FNodes.Count > 0;
  Result := Self;
end;

function TXmlNode.AddNode(const ANode: IXmlNode): IXmlNode;
begin
  FNodes.Add(ANode);
  Result := Self;
end;

function TXmlNode.Attribute(const AName: string): string;
var
  LKey: string;
begin
  Result := '';
  for LKey in FAttributes.Keys.ToArray do
    if (LKey.ToLower.Equals(AName.ToLower)) then
      Exit(FAttributes.Items[LKey]);
end;

function TXmlNode.SpaceLines(const AText: string; const ASpaces: Integer
  ): string;
var
  LSpaces: string;
  LStringList: TStringList;
  I: Int64;
begin
  LSpaces := GetSpaces(ASpaces);
  LStringList := TStringList.Create;
  try
    LStringList.Text := AText;
    for I := 0 to Pred(LStringList.Count) do
      LStringList[I] := LSpaces + LStringList[I];
    Result := LStringList.Text;
  finally
    LStringList.Free;
  end;
end;

function TXmlNode.GetSpaces(const ASpaces: Integer): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to ASpaces do
    Result := Result + ' ';
end;

function TXmlNode.HasAttribute(const AName: string): Boolean;
var
  LKey: string;
begin
  Result := False;
  for LKey in FAttributes.Keys.ToArray do
    if (LKey.ToLower.Equals(AName.ToLower)) then
      Exit(True);
end;

constructor TXmlNode.Create(const AName: string);
begin
  FName := AName;
  FValue := '';
  FIsNode := False;
  FAttributes := TDictionary<string, string>.Create;
  FNodes := IXmlNodeList.Create;
end;

function TXmlNode.Build(const APretty: Boolean; const ASpaces: Integer): string;
var
  LPair: TPair<string, string>;
  LContent: string;
begin
  Result := '<' + FName;
  if FAttributes.Count > 0 then
    for LPair in FAttributes do
      Result := Result + Chr(32) + LPair.Key + '="' + LPair.Value + '"';
  LContent := Value(APretty, ASpaces);
  if not LContent.IsEmpty then
    Result := Result + '>' + LContent + '</' + FName + '>'
  else
    Result := Result + '/>';
end;

function TXmlNode.Name: string;
begin
  Result := FName;
end;

destructor TXmlNode.Destroy;
begin
  FNodes.Free;
  inherited;
end;

function TXmlNode.FindByTagName(const AName: string; const ARecursive: Boolean
  ): IXmlNodeList;
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

class function TXmlNode.New(const AName: string): IXmlNode;
begin
  Result := TXmlNode.Create(AName);
end;

class function TXmlNode.Parse(const AText: string): IXmlNode;
var
  LTag: string;
  LLevel: Int64;
  LStart: Int64;
  LLength: Int64;
  LTagName: string;
  LOpenTag: string;
  LCloseTag: string;
  LAttrName: string;
  LAttrValue: string;
  LStartContent: Int64;
begin
  LStart := Pos('<', AText);
  if (LStart = 0) then Exit;
  LLength := Pos('>', AText, LStart) - LStart + 1;
  LTag := Copy(AText, LStart, LLength);
  if (LTag.Contains(' ')) then
    LLength := Pos(' ', LTag);
  LTagName := Copy(LTag, 2, LLength - 2);
  Result := TXmlNode.New(LTagName);
  LStart := 1;
  while LStart > 0 do
  begin
    LStart := Pos(' ', LTag, LStart);
    if LStart = 0 then Break;
    Inc(LStart);
    LLength := Pos('=', LTag, LStart) - LStart;
    LAttrName := Copy(LTag, LStart, LLength);
    LAttrValue := '';
    LStart := Pos('"', LTag, LStart + LLength) + 1;
    if (LStart > 0) then
    begin
      LLength := Pos('"', LTag, LStart) - LStart;
      LAttrValue := Copy(LTag, LStart, LLength);
    end;
    Result.AddAttribute(LAttrName, LAttrValue);
  end;
  if LTag.EndsWith('/>') then Exit;
  LStartContent := Pos(LTag, AText) + Length(LTag);
  LLevel := 0;
  LStart := 1;
  LLength := 0;
  while LStart > 0 do
  begin
    LStart := Pos('<', AText, LStart + LLength);
    if LStart = 0 then Break;
    LLength := Pos('>', AText, LStart) - LStart + 1;
    if LLength <= 0 then Break;
    LTag := Copy(AText, LStart, LLength);
    if (LTag.Contains(' ')) then
      LLength := Pos(' ', LTag);
    LTagName := Copy(LTag, 2, LLength - 2);
    if (LTag.EndsWith('/>')) then Continue;
    if LLevel = 1 then
    begin
      LOpenTag := LTag;
      LCloseTag := '</' + LTagName + '>';
    end;
    if (LTag.StartsWith('</')) then Dec(LLevel) else Inc(LLevel);
    if (LTag.StartsWith('</' + Result.Name)) and (LLevel = 0) then Break;
  end;
  Result.Value(Trim(Copy(AText, LStartContent, LStart - LStartContent)));
end;

function TXmlNode.Value(const AValue: string): IXmlNode;
var
  LTag: string;
  LLevel: Int64;
  LStart: Int64;
  LLength: Int64;
  LIsNode: Boolean;
  LTagName: string;
  LOpenTag: string;
  LCloseTag: string;
  LStartElement: Int64;
begin
  Result := Self;
  LStartElement := 0;
  LIsNode := False;
  LLevel := 0;
  LStart := 1;
  LLength := 0;
  LCloseTag := '';
  LOpenTag := '';
  LTagName := '';
  while LStart > 0 do
  begin
    LStart := Pos('<', AValue, LStart + LLength);
    if LStart = 0 then Break;
    LLength := Pos('>', AValue, LStart) - LStart + 1;
    if LLength <= 0 then Break;
    LTag := Copy(AValue, LStart, LLength);
    if (LTag = LCloseTag) and (LLevel = 1) then
      AddNode(TXmlNode.Parse(LOpenTag + Copy(AValue, LStartElement, LStart - LStartElement) + LCloseTag));
    if (LTag.Contains(' ')) then
      LLength := Pos(' ', LTag);
    LTagName := Copy(LTag, 2, LLength - 2);
    if (LTag.EndsWith('/>')) then
    begin
      AddNode(TXmlNode.Parse(LTag));
      Continue;
    end;
    LIsNode := LLevel > 1;
    if LLevel = 0 then
    begin
      LOpenTag := LTag;
      LCloseTag := '</' + LTagName + '>';
    end;
    if (LTag.StartsWith('</')) then Dec(LLevel) else Inc(LLevel);
    if (LTag.StartsWith('</' + Name)) and (LLevel = -1) then Break;
    if (LLevel = 1) and (not LIsNode) then LStartElement := LStart + Length(LTag);
  end;
  FIsNode := FNodes.Count > 0;
  if FIsNode then FValue := '' else FValue := AValue;
end;

function TXmlNode.XPath(const APath: string;
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

function TXmlNode.Value(const APretty: Boolean; const ASpaces: Integer): string;
var
  LElement: IXmlNode;
begin
  if (not FIsNode) then Exit(FValue);
  Result := IfThen(APretty, Char(10), EmptyStr);
  for LElement in FNodes do
    Result := Result + LElement.Build(APretty, ASpaces) + IfThen(APretty, Char(10), EmptyStr);
  if APretty then Result := SpaceLines(Result, ASpaces);
end;

end.
