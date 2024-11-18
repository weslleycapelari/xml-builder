unit Xml.Builder.Samples.Lazarus;

{$mode objfpc}{$H+}

interface

uses Classes, SysUtils, memds, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFrmSamples }

  TFrmSamples = class(TForm)
    btnExample1: TButton;
    btnExample2: TButton;
    btnExample3: TButton;
    btnExample4: TButton;
    btnExample5: TButton;
    mtDeveloper: TMemDataset;
    mmXml: TMemo;
    procedure btnExample1Click(Sender: TObject);
    procedure btnExample2Click(Sender: TObject);
    procedure btnExample3Click(Sender: TObject);
    procedure btnExample4Click(Sender: TObject);
    procedure btnExample5Click(Sender: TObject);
  end;

var
  FrmSamples: TFrmSamples;

implementation

{$R *.lfm}

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
    mtDeveloper.FieldByName('firstName').AsString := 'Vinicius';
    mtDeveloper.FieldByName('lastName').AsString := 'Sanchez';
    mtDeveloper.FieldByName('mvp').AsBoolean := True;
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

  mmXml.Lines.Text := TXmlBuilder.Parse(mmXml.Lines.Text).Xml;
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
  if (LFound.Count = 0) then Exit;
  for LCount := 0 to LFound.Count - 1 do
  begin
    mmXml.Lines.Add('Match ' + IntToStr(LCount) + ':');
    mmXml.Lines.Add(LFound[LCount].Build(True) + Char(32));
  end;
end;

end.
