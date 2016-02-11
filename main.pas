unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  ExtCtrls, StdCtrls;

const m = 40; n = 40;

type

  { TForm1 }
  Field=array [0..m-1,0..n-1] of char;
  TForm1 = class(TForm)
    InTor: TCheckBox;
    SelectFile: TOpenDialog;
    StartPause: TButton;
    Button2: TButton;
    Button3: TButton;
    LoadFile: TButton;
    dg: TDrawGrid;
    Path: TLabeledEdit;
    tmr: TTimer;
    procedure PathClick(Sender: TObject);
    procedure StartPauseClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure LoadFileClick(Sender: TObject);
    procedure dgDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure dgSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure PathChange(Sender: TObject);
    procedure tmrTimer(Sender: TObject);
  private
    { private declarations }
  public
    procedure NextGeneration;
  end;

var
  Form1: TForm1;
  A: Field;
  counter: integer;
implementation

{$R *.lfm}

{ TForm1 }

procedure readField(var t: text; var A: Field);
var i, j: integer;
begin
  system.reset(t);
  for i := 0 to m - 1 do begin
    for j := 0 to n - 1 do read(t, A[i, j]);
    if (i <> m) then readln(t);
  end;
  system.close(t);
end;


function NeighborsInTor(var A: Field; i, j: integer): integer;
var sum, x, y, l: integer;
begin
  sum := 0;
  for l := 1 to 9 do begin
    x := i - 1 + (l - 1) div 3;
    y := j - 1 + (l + 2) mod 3;
    if (x = -1) then
      x := m - 1
    else if (x=m) then
      x := 0;
    if (y = -1) then
      y := n - 1
    else if (y = n) then
      y := 0;
    if (A[x, y] = '#') then
      sum := sum + 1;
  end;
  if A[i, j] = '#' then
    sum := sum - 1;
  NeighborsInTor := sum;
end;

function neighbors(var A: Field; i, j: integer; InTor: boolean): integer;
var sum, x, y, l: integer;
begin
  if  InTor then
    neighbors := NeighborsInTor(A, i, j)
  else begin
    sum := 0;
    for l := 1 to 9 do begin
      x := i - 1 + (l - 1) div 3;
      y := j - 1 + (l + 2) mod 3;
      if (x <> -1) and (x <> m) and (y <> - 1) and (y <> n) and (A[x, y] = '#')
      then sum := sum + 1;
    end;
  if A[i, j] = '#' then
    sum := sum - 1;
  neighbors := sum;
  end;
end;

procedure step(var A: Field; InTor: boolean);
var B: Field;
    i, j: integer;
begin
  B := A;
  for i := 0 to m - 1 do
    for j := 0 to n - 1 do
      if (A[i, j] = '#') and not(neighbors(B, i, j, InTor) in [2, 3]) then
        A[i, j] := '_'
      else if (A[i, j] <> '#') and (neighbors(B, i, j, InTor) = 3) then
        A[i, j] := '#';
end;


procedure TForm1.FormCreate(Sender: TObject);
var t: text;
begin
  system.assign(t, 'input3.txt');
  readField(t, A);
  counter := 0;
end;

procedure TForm1.dgDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
begin
  if (A[aRow, aCol] = '#') then
    dg.Canvas.Brush.Color := clWhite
  else
    dg.Canvas.Brush.Color := clBlack;
  dg.Canvas.Rectangle(aRect);
end;

procedure TForm1.dgSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  if (A[aRow, aCol] = '#') then
    A[aRow, aCol] := '_'
  else
    A[aRow, aCol] := '#';
end;

procedure TForm1.StartPauseClick(Sender: TObject);
begin
  tmr.Enabled := not tmr.Enabled;
  if tmr.Enabled
    then StartPause.Caption := 'Pause'
    else StartPause.Caption := 'Start';
end;

procedure TForm1.PathClick(Sender: TObject);
begin
  if SelectFile.Execute then
    Path.Text := SelectFile.FileName;
end;

procedure TForm1.NextGeneration;
begin
  step(A, InTor.Checked);
  dg.Repaint;
  counter := counter + 1; 
  Caption := 'Generation ' + IntToStr(counter);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  NextGeneration;
end;

procedure TForm1.Button3Click(Sender: TObject);
var i, j: integer;
begin
  for i := 0 to m - 1 do
    for j := 0 to n - 1 do
      A[i, j] := '_';
  dg.Repaint;
  counter := 0;
  Caption := 'Generation 0';
end;

procedure TForm1.LoadFileClick(Sender: TObject);
var t: text;
begin
  system.assign(t, Path.Text);
  readField(t, A);
  counter := 0;
  dg.Repaint;
end;

procedure TForm1.tmrTimer(Sender: TObject);
begin
  NextGeneration;
end;

end.
