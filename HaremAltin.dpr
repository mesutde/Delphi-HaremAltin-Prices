program HaremAltin;

uses
  Vcl.Forms,
  frmMainForm in 'frmMainForm.pas' {Form1},
  HaremDataUnit in 'HaremDataUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
