program CastAdapterProject;

uses
  System.StartUpCopy,
  FMX.Forms,
  AdapterMain in 'AdapterMain.pas' {Form1},
  uJSON in 'uJSON.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
