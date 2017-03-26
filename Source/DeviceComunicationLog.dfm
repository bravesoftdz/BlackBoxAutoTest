object COMMLogForm: TCOMMLogForm
  Left = 724
  Top = 240
  BorderStyle = bsDialog
  Caption = #25171#24320#20018#21475
  ClientHeight = 267
  ClientWidth = 316
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 13
    Top = 13
    Width = 188
    Height = 163
    Caption = 'Com option'
    TabOrder = 0
    object Label1: TLabel
      Left = 13
      Top = 26
      Width = 30
      Height = 13
      Caption = 'Port : '
    end
    object Label2: TLabel
      Left = 13
      Top = 52
      Width = 60
      Height = 13
      Caption = 'Baud Rate : '
    end
    object Label3: TLabel
      Left = 13
      Top = 78
      Width = 38
      Height = 13
      Caption = 'Parity : '
    end
    object Label4: TLabel
      Left = 13
      Top = 104
      Width = 53
      Height = 13
      Caption = 'Data Bits : '
    end
    object Label5: TLabel
      Left = 13
      Top = 130
      Width = 42
      Height = 13
      Caption = 'Stop Bits'
    end
    object cbPort: TComboBox
      Left = 78
      Top = 20
      Width = 79
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
    end
    object cbBaudRate: TComboBox
      Left = 78
      Top = 46
      Width = 79
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 13
      TabOrder = 1
      Text = '19200'
      Items.Strings = (
        '50'
        '75'
        '110'
        '134.5'
        '150'
        '300'
        '600'
        '1200'
        '1800'
        '2400'
        '4800'
        '7200'
        '9600'
        '19200'
        '38400'
        '57600'
        '115200'
        '230400'
        '460800'
        '921600')
    end
    object cbParity: TComboBox
      Left = 78
      Top = 72
      Width = 79
      Height = 21
      Style = csDropDownList
      Enabled = False
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 2
      Text = 'None'
      Items.Strings = (
        'None'
        'Odd'
        'Even'
        'Mark'
        'Space')
    end
    object cbByteSize: TComboBox
      Left = 78
      Top = 98
      Width = 79
      Height = 21
      Style = csDropDownList
      Enabled = False
      ItemHeight = 13
      ItemIndex = 3
      TabOrder = 3
      Text = '8'
      Items.Strings = (
        '5'
        '6'
        '7'
        '8')
    end
    object cbStopBits: TComboBox
      Left = 78
      Top = 124
      Width = 79
      Height = 21
      Style = csDropDownList
      Enabled = False
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 4
      Text = '1'
      Items.Strings = (
        '1'
        '2')
    end
    object btn1: TButton
      Left = 160
      Top = 24
      Width = 17
      Height = 17
      Caption = 'R'
      TabOrder = 5
      OnClick = btn1Click
    end
  end
  object GroupBox2: TGroupBox
    Left = 13
    Top = 189
    Width = 176
    Height = 65
    Caption = 'Flow Control'
    TabOrder = 1
    object chHw: TCheckBox
      Left = 13
      Top = 20
      Width = 144
      Height = 13
      Caption = 'RTS/CTS'
      Enabled = False
      TabOrder = 0
    end
    object chSw: TCheckBox
      Left = 13
      Top = 39
      Width = 144
      Height = 20
      Caption = 'XON/XOFF'
      Enabled = False
      TabOrder = 1
    end
  end
  object CfgOK: TButton
    Left = 215
    Top = 39
    Width = 65
    Height = 20
    Caption = 'OK'
    TabOrder = 2
    OnClick = CfgOKClick
  end
  object CfgCancel: TButton
    Left = 215
    Top = 85
    Width = 65
    Height = 20
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = CfgCancelClick
  end
  object GroupBox3: TGroupBox
    Left = 195
    Top = 189
    Width = 105
    Height = 65
    Caption = 'Output State'
    TabOrder = 4
    object chDtr: TCheckBox
      Left = 13
      Top = 20
      Width = 79
      Height = 13
      Caption = 'DTR'
      Enabled = False
      TabOrder = 0
    end
    object chRts: TCheckBox
      Left = 13
      Top = 39
      Width = 79
      Height = 20
      Caption = 'RTS'
      Enabled = False
      TabOrder = 1
    end
  end
end
