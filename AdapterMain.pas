unit AdapterMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  sgcWebSocket_Classes, sgcWebSocket_Client, sgcWebSocket, sgcWebSocket_Server,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Effects,
  FMX.Layouts, FMX.ListBox, FMX.ScrollBox, FMX.Memo,
  sgcWebSocket_Client_SocketIO, StrUtils, uJSON;

type
  TForm1 = class(TForm)
    processingListener: TsgcWebSocketServer;
    Image1: TImage;
    Button1: TButton;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    StyleBook1: TStyleBook;
    Memo1: TMemo;
    mainListener: TsgcWebSocketClient_SocketIO;
    Timer1: TTimer;
    procedure log(S: String);
    procedure processingListenerConnect(Connection: TsgcWSConnection);
    procedure processingListenerMessage(Connection: TsgcWSConnection;
      const Text: string);
    procedure MessageReceive(Event: String; MData: JSONObject);
    procedure Button1Click(Sender: TObject);
    procedure processingListenerDisconnect(Connection: TsgcWSConnection;
      Code: Integer);
    procedure mainListenerMessage(Connection: TsgcWSConnection;
      const Text: string);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.log(S: string);
begin
  Memo1.Lines.Append(S);
  //Memo1.VScrollBar.Value := Memo1.VScrollBar.Max;
end;

procedure TForm1.MessageReceive(Event: string; MData: JSONObject);
begin
  if Event = 'who_are_you' then begin
    Log('Succesfully informed to main server that I am an adapter.');
    mainListener.WriteData('42["iamadapter"]');
  end;
  if Event = 'data' then begin
    ProcessingListener.Broadcast(MData.toString);
  end;

  MData.Clean;
end;

procedure TForm1.mainListenerMessage(Connection: TsgcWSConnection;
  const Text: string);
var
  JSONArr : JSONArray;
  B : JSONObject;
  A: String;
begin
  if AnsiStartsStr('42', Text) then begin
    try
      JSONArr := JSONArray.create(Copy(Text,3,Length(Text)-2));
      A := JSONArr.getString(0);
      B := JSONArr.getJSONObject(1);
      MessageReceive(A,B);
      log('Raw data: ' + Copy(Text,3,Length(Text)-2));
    finally
      B.Clean;
      JSONArr.Clean;
    end;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  processingListener.Active := True;
  mainListener.Active := True;
  Timer1.Enabled := True;
  log('Adapting Service is started.');
end;

procedure TForm1.processingListenerConnect(Connection: TsgcWSConnection);
begin
  log('Processing PApplet is connected.');
end;

procedure TForm1.processingListenerDisconnect(Connection: TsgcWSConnection;
  Code: Integer);
begin
  log('Processing PApplet is disconnected.');
end;

procedure TForm1.processingListenerMessage(Connection: TsgcWSConnection;
  const Text: string);
begin
  log('PApplet said: ' + text);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if mainListener.Active = false then mainListener.Active := True;
  mainListener.WriteData('42["hb"]');
end;

end.
