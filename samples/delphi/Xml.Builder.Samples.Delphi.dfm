object FrmSamples: TFrmSamples
  Left = 0
  Top = 0
  Caption = 'XML Builder'
  ClientHeight = 456
  ClientWidth = 699
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 699
    Height = 456
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object mmXml: TMemo
      AlignWithMargins = True
      Left = 3
      Top = 36
      Width = 693
      Height = 417
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Consolas'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      ExplicitLeft = 24
      ExplicitTop = 56
      ExplicitWidth = 649
      ExplicitHeight = 377
    end
    object pnlButtons: TPanel
      Left = 0
      Top = 0
      Width = 699
      Height = 33
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object btnExample1: TButton
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 75
        Height = 27
        Align = alLeft
        Caption = 'Example 1'
        TabOrder = 0
        OnClick = btnExample1Click
        ExplicitLeft = 24
        ExplicitTop = 16
        ExplicitHeight = 25
      end
      object btnExample2: TButton
        AlignWithMargins = True
        Left = 84
        Top = 3
        Width = 75
        Height = 27
        Align = alLeft
        Caption = 'Example 2'
        TabOrder = 1
        OnClick = btnExample2Click
        ExplicitLeft = 105
        ExplicitTop = 16
        ExplicitHeight = 25
      end
      object btnExample3: TButton
        AlignWithMargins = True
        Left = 165
        Top = 3
        Width = 75
        Height = 27
        Align = alLeft
        Caption = 'Example 3'
        TabOrder = 2
        OnClick = btnExample3Click
        ExplicitLeft = 186
        ExplicitTop = 16
        ExplicitHeight = 25
      end
      object btnExample4: TButton
        AlignWithMargins = True
        Left = 246
        Top = 3
        Width = 75
        Height = 27
        Align = alLeft
        Caption = 'Example 4'
        TabOrder = 3
        OnClick = btnExample4Click
        ExplicitLeft = 267
        ExplicitTop = 16
        ExplicitHeight = 25
      end
      object btnExample5: TButton
        AlignWithMargins = True
        Left = 327
        Top = 3
        Width = 75
        Height = 27
        Align = alLeft
        Caption = 'Example 5'
        TabOrder = 4
        OnClick = btnExample5Click
        ExplicitLeft = 348
        ExplicitTop = 16
        ExplicitHeight = 25
      end
      object btnExample6: TButton
        AlignWithMargins = True
        Left = 408
        Top = 3
        Width = 75
        Height = 27
        Align = alLeft
        Caption = 'Example 6'
        TabOrder = 5
        OnClick = btnExample6Click
        ExplicitLeft = 429
        ExplicitTop = 16
        ExplicitHeight = 25
      end
    end
  end
  object mtDeveloper: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 272
    Top = 248
    object mtDeveloperfirstName: TStringField
      FieldName = 'firstName'
      Size = 100
    end
    object mtDeveloperlastName: TStringField
      FieldName = 'lastName'
      Size = 100
    end
    object mtDevelopermvp: TBooleanField
      FieldName = 'mvp'
    end
  end
end
