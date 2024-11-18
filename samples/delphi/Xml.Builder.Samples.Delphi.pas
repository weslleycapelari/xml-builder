unit Xml.Builder.Samples.Delphi;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, VCL.Graphics, VCL.Controls, VCL.Forms,
  VCL.Dialogs, VCL.ExtCtrls, Vcl.StdCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  System.Generics.Collections;

type
  TFrmSamples = class(TForm)
    Panel1: TPanel;
    btnExample1: TButton;
    mmXml: TMemo;
    btnExample2: TButton;
    mtDeveloper: TFDMemTable;
    btnExample3: TButton;
    mtDeveloperfirstName: TStringField;
    mtDeveloperlastName: TStringField;
    mtDevelopermvp: TBooleanField;
    btnExample4: TButton;
    btnExample5: TButton;
    btnExample6: TButton;
    procedure btnExample1Click(Sender: TObject);
    procedure btnExample2Click(Sender: TObject);
    procedure btnExample3Click(Sender: TObject);
    procedure btnExample4Click(Sender: TObject);
    procedure btnExample5Click(Sender: TObject);
    procedure btnExample6Click(Sender: TObject);
  end;

var
  FrmSamples: TFrmSamples;

implementation

{$R *.dfm}

uses Xml.Builder;

procedure TFrmSamples.btnExample1Click(Sender: TObject);
begin
  mmXml.Lines.Text := TXmlBuilder.New
    .AddNode(TXmlNode.New('developer')
      .AddAttribute('mvp', 'true')
      .AddElement('firstName', 'Vinicius')
      .AddElement('lastName', 'Sanchez')
      .AddElement('age')
      .AddNode(TXmlNode.New('projects')
        .AddElement('Horse', 'yes')
        .AddElement('Boss', 'yes')
        .AddElement('RESTRequest4Delphi', 'yes')
        .AddElement('DataSet-Serialize', 'yes')
        .AddElement('BCrypt', 'yes')))
    .Xml(True);
end;

procedure TFrmSamples.btnExample2Click(Sender: TObject);
var
  LDeveloperNode, LProjectsNode: IXmlNode;
begin
  LProjectsNode := TXmlNode.New('projects')
    .AddElement('Horse', 'yes')
    .AddElement('Boss', 'yes')
    .AddElement('RESTRequest4Delphi', 'yes')
    .AddElement('DataSet-Serialize', 'yes')
    .AddElement('BCrypt', 'yes');

  LDeveloperNode := TXmlNode.New('developer')
    .AddAttribute('mvp', 'true')
    .AddElement('firstName', 'Vinicius')
    .AddElement('lastName', 'Sanchez')
    .AddElement('age')
    .AddNode(LProjectsNode);

  mmXml.Lines.Text := TXmlBuilder.New
    .AddNode(LDeveloperNode)
    .Xml;
end;

procedure TFrmSamples.btnExample3Click(Sender: TObject);
begin
  if not mtDeveloper.Active then
  begin
    mtDeveloper.Active := True;
    mtDeveloper.Insert;
    mtDeveloperfirstName.AsString := 'Vinicius';
    mtDeveloperlastName.AsString := 'Sanchez';
    mtDevelopermvp.AsBoolean := True;
    mtDeveloper.Post;
  end;
  mmXml.Lines.Text := TXmlBuilder.Adapter(mtDeveloper).Xml;
end;

procedure TFrmSamples.btnExample4Click(Sender: TObject);
begin
  mmXml.Lines.Text :=
    '<?xml version="1.0" encoding="UTF-8"?>' + #10 +
    '<developer mvp="true">' + #10 +
    '  <firstName>Vinicius</firstName>' + #10 +
    '  <lastName>Sanchez</lastName>' + #10 +
    '  <age/>' + #10 +
    '  <projects>' + #10 +
    '    <Boss>yes</Boss>' + #10 +
    '    <DataSet-Serialize>yes</DataSet-Serialize>' + #10 +
    '    <RESTRequest4Delphi>yes</RESTRequest4Delphi>' + #10 +
    '    <BCrypt>yes</BCrypt>' + #10 +
    '    <Horse>yes</Horse>' + #10 +
    '  </projects>' + #10 +
    '</developer>';

  mmXml.Lines.Text := TXmlBuilder.Parse(mmXml.Lines.Text).Xml(True);
end;

procedure TFrmSamples.btnExample5Click(Sender: TObject);
var
  LXML: IXmlBuilder;
  LFound: IXmlNodeList;
  LCount: Integer;
begin
  mmXml.Lines.Text := '';
  LXML := TXmlBuilder.Parse(
    '<?xml version="1.0" encoding="UTF-8"?>' + #10 +
    '<developer mvp="true">' + #10 +
    '  <firstName>Vinicius</firstName>' + #10 +
    '  <lastName>Sanchez</lastName>' + #10 +
    '  <BCrypt>teste</BCrypt>' + #10 +
    '  <age/>' + #10 +
    '  <projects>' + #10 +
    '    <Boss>yes</Boss>' + #10 +
    '    <DataSet-Serialize>yes</DataSet-Serialize>' + #10 +
    '    <RESTRequest4Delphi>yes</RESTRequest4Delphi>' + #10 +
    '    <BCrypt>yes</BCrypt>' + #10 +
    '    <Horse>yes</Horse>' + #10 +
    '  </projects>' + #10 +
    '</developer>');
  LFound := LXML.FindByTagName('BCrypt');
  if (LFound.Count = 0) then
  begin
    mmXml.Lines.Add('No Matches.');
    Exit;
  end;
  for LCount := 0 to LFound.Count - 1 do
  begin
    mmXml.Lines.Add('Match ' + IntToStr(LCount) + ':');
    mmXml.Lines.Add(LFound[LCount].Build(True) + Char(32));
  end;
end;

procedure TFrmSamples.btnExample6Click(Sender: TObject);
var
  LXML: IXmlBuilder;
  LFound: IXmlNodeList;
  LCount: Integer;
begin
  mmXml.Lines.Text := '';
  LXML := TXmlBuilder.Parse(
    '<?xml version="1.0" encoding="UTF-8"?>' + #10 +
    '<developer mvp="true">' + #10 +
    '  <firstName>Vinicius</firstName>' + #10 +
    '  <lastName>Sanchez</lastName>' + #10 +
    '  <BCrypt>teste</BCrypt>' + #10 +
    '  <age/>' + #10 +
    '  <projects>' + #10 +
    '    <Boss>yes</Boss>' + #10 +
    '    <DataSet-Serialize>yes</DataSet-Serialize>' + #10 +
    '    <RESTRequest4Delphi>yes</RESTRequest4Delphi>' + #10 +
    '    <BCrypt tipo="teste">yes-teste</BCrypt>' + #10 +
    '    <BCrypt tipo="oficial">yes-oficial</BCrypt>' + #10 +
    '    <BCrypt tipo="teste">no-teste</BCrypt>' + #10 +
    '    <Horse>yes</Horse>' + #10 +
    '  </projects>' + #10 +
    '</developer>');
  LFound := LXML.XPath('//developer[@mvp="true"]/projects/bcrypt[@tipo="teste"]');
  if (LFound.Count = 0) then
  begin
    mmXml.Lines.Add('No Matches.');
    Exit;
  end;
  for LCount := 0 to LFound.Count - 1 do
  begin
    mmXml.Lines.Add('Match ' + IntToStr(LCount) + ':');
    mmXml.Lines.Add(LFound[LCount].Build(True) + Char(32));
  end;
end;

end.
