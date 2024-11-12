unit Xml.Builder.Node;

{$IF DEFINED(FPC)}
  {$MODE DELPHI}{$H+}
{$ENDIF}

interface

uses
  Xml.Builder.Node.Intf,
{$IF DEFINED(FPC)}
  Generics.Collections;
{$ELSE}
  System.Generics.Collections;
{$ENDIF}

type
  TXmlNode = class(TInterfacedObject, IXmlNode)
  private
    FNodeName: string;
    FNodes: TList<IXmlNode>;
    FElements: TDictionary<string, string>;
    FAttributes: TDictionary<string, string>;
    function SpaceLines(const AText: string; const ASpaces: Integer): string;
    function GetSpaces(const ASpaces: Integer): string;
    function Build(const APretty: Boolean = False; const ASpaces: Integer = 2): string;
    function AddAttribute(const AName, AValue: string): IXmlNode;
    function AddNode(const ANode: IXmlNode): IXmlNode;
    function AddElement(const AName: string): IXmlNode; overload;
    function AddElement(const AName, AValue: string): IXmlNode; overload;
    function NodeName: string;
    constructor Create(const ANodeName: string); reintroduce;
  public
    class function Parse(const AText: string): IXmlNode;
    class function New(const ANodeName: string): IXmlNode;
    destructor Destroy; override;
  end;

implementation

{ TXmlNode }

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

function TXmlNode.AddAttribute(const AName, AValue: string): IXmlNode;
begin
  FAttributes.AddOrSetValue(AName, AValue);
  Result := Self;
end;

function TXmlNode.AddElement(const AName: string): IXmlNode;
begin
  Result := Self.AddElement(AName, EmptyStr);
end;

function TXmlNode.AddElement(const AName, AValue: string): IXmlNode;
begin
  FElements.AddOrSetValue(AName, AValue);
  Result := Self;
end;

function TXmlNode.AddNode(const ANode: IXmlNode): IXmlNode;
begin
  FNodes.Add(ANode);
  Result := Self;
end;

function TXmlNode.Build(const APretty: Boolean; const ASpaces: Integer): string;
var
  LNode: IXmlNode;
  LPair: TPair<string, string>;
  LContent: string;
begin
  Result := '<' + FNodeName;
  if FAttributes.Count > 0 then
    for LPair in FAttributes do
      Result := Result + Chr(32) + LPair.Key + '="' + LPair.Value + '"';
  if (FNodes.Count = 0) and (FElements.Count = 0) then
  begin
    Result := Result + '/>';
    Exit;
  end;
  Result := Result + '>' + IfThen(APretty, Char(10), EmptyStr);
  LContent := '';
  try
    for LPair in FElements do
    begin
      LContent := LContent + '<' + LPair.Key + IfThen(LPair.Value.IsEmpty, '/>', '>');
      if not LPair.Value.IsEmpty then
      begin
        LContent := LContent + LPair.Value;
        LContent := LContent + '</' + LPair.Key + '>';
      end;
      LContent := LContent + IfThen(APretty, Char(10), EmptyStr);
    end;
    for LNode in FNodes do
      LContent := LContent + LNode.Build(APretty, ASpaces);
  finally
    if (APretty) and (ASpaces > 0) then
      LContent := SpaceLines(LContent, ASpaces);
    Result := Result + LContent;
  end;
  Result := Result + '</' + FNodeName + '>';
end;

constructor TXmlNode.Create(const ANodeName: string);
begin
  FNodes := TList<IXmlNode>.Create;
  FElements := TDictionary<string, string>.Create();
  FAttributes := TDictionary<string, string>.Create();
  FNodeName := ANodeName;
end;

destructor TXmlNode.Destroy;
begin
  FNodes.Free;
  FElements.Free;
  FAttributes.Free;
  inherited;
end;

function TXmlNode.GetSpaces(const ASpaces: Integer): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to ASpaces do
    Result := Result + ' ';
end;

class function TXmlNode.New(const ANodeName: string): IXmlNode;
begin
  Result := TXmlNode.Create(ANodeName);
end;

function TXmlNode.NodeName: string;
begin
  Result := FNodeName;
end;

class function TXmlNode.Parse(const AText: string): IXmlNode;
var
  LTag: string;
  LLevel: Int64;
  LStart: Int64;
  LLength: Int64;
  LIsNode: Boolean;
  LTagName: string;
  LContent: string;
  LOpenTag: string;
  LCloseTag: string;
  LAttrName: string;
  LAttrValue: string;
  LStartContent: Int64;
  LStartElement: Int64;
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
  LStartElement := 0;
  LStartContent := Pos(LTag, AText) + Length(LTag);
  LIsNode := False;
  LLevel := 0;
  LStart := 1;
  LLength := 0;
  while LStart > 0 do
  begin
    LStart := Pos('<', AText, LStart + LLength);
    if LStart = 0 then Break;
    LLength := Pos('>', AText, LStart) - LStart + 1;
    LTag := Copy(AText, LStart, LLength);
    if (LTag = LCloseTag) and (LLevel = 2) then
    begin
      if LIsNode then
        Result.AddNode(TXmlNode.Parse(LOpenTag + Copy(AText, LStartElement, LStart - LStartElement).Trim + LCloseTag))
      else
        Result.AddElement(LTagName, Copy(AText, LStartElement, LStart - LStartElement));
    end;
    if (LTag.Contains(' ')) then
      LLength := Pos(' ', LTag);
    LTagName := Copy(LTag, 2, LLength - 2);
    if (LTag.EndsWith('/>')) then
    begin
      Result.AddElement(Copy(LTagName, 1, Length(LTagName) - 1));
      Continue;
    end;
    LIsNode := LLevel > 2;
    if LLevel = 1 then
    begin
      LOpenTag := LTag;
      LCloseTag := '</' + LTagName + '>';
    end;
    if (LTag.StartsWith('</')) then Dec(LLevel) else Inc(LLevel);
    if (LTag.StartsWith('</' + Result.NodeName)) and (LLevel = 0) then Break;
    if (LLevel = 2) and (not LIsNode) then LStartElement := LStart + Length(LTag);
  end;
  LContent := Copy(AText, LStartContent, LStart - LStartContent);
end;

function TXmlNode.SpaceLines(const AText: string; const ASpaces: Integer): string;
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

end.
