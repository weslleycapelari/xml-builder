unit Xml.Builder.Node.Intf;

interface

uses
{$IF DEFINED(FPC)}
  Generics.Collections;
{$ELSE}
  System.Generics.Collections;
{$ENDIF}

type
  IXmlNode = interface;

  {$IF DEFINED(FPC)}
  IXmlNodeList = specialize TList<IXmlNode>;
  {$ELSE}
  IXmlNodeList = TList<IXmlNode>;
  {$ENDIF}

  IXmlNode = interface
    ['{83EC1878-082C-475D-9E9B-F158BDCA6E07}']
    function FindByTagName(const AName: string; const ARecursive: Boolean = True): IXmlNodeList;
    function Build(const APretty: Boolean = False; const ASpaces: Integer = 2): string;
    function AddNode(const ANode: IXmlNode): IXmlNode;
    function AddElement(const AName: string): IXmlNode; overload;
    function AddElement(const AName, AValue: string): IXmlNode; overload;  
    function AddAttribute(const AName, AValue: string): IXmlNode;
    function HasAttribute(const AName: string): Boolean;
    function Attribute(const AName: string): string;
    function Value(const APretty: Boolean = False; const ASpaces: Integer = 2): string; overload;
    function Value(const AValue: string): IXmlNode; overload;
    function Name: string;
    function XPath(const APath: string; const ARecursive: Boolean = True): IXmlNodeList;
  end;

implementation

end.
