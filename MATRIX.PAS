const
      DELETE_PROB=4;
      DROP_CONST=3;

var l,tm:longint;
    where,left,kind:array[0..79] of byte;

procedure about;
const sc:string='ﬂ';{'oﬂ‹ﬂ‹';}
var i,j:integer;
begin
     gotoxy(10,5);
     for j:=5 to 5+7 do
         for i:=10 to 10+58 do
             wr(i,j,
                  sc[1+((i) mod (byte(sc[0])))],
                  (i*j) and 8+(((i*j) and 127)shl 4));
     { title and stuff }
     border(10,5,60,8,lightblue);
     s:=main_options[cmenu];
     wrs(49,5,s,tcol);
     s:='ESC=Exit';
     wrs(11,12,s,white); s:='(c)1999 by woods - cosmin apreutesei';
     wrs(30,12,s,white);
end;


procedure matrix;
var i,j:integer;
begin

    for i:=0 to 79 do
        for j:=0 to 26 do
            wcol(i,j,2);
    for i:=0 to 79 do begin
         kind[i]:=random(DELETE_PROB);
         where[i]:=random(25);
         left[i]:=1+random(26-where[i]);
    end;
    tm:=1;
    while tm<30 do begin
      if keypressed then
         if getscan=esc_key then inc(tm);
      if tm>1 then inc(tm);
      about;
      Delay(150);
      waitretrace;
      {for l:=1 to 3000000 do begin end;
      }for i:=0 to 79 do begin
         if kind[i]=DROP_CONST then
           wcol(i,where[i],2)
         else
           wro(i,where[i],' ');
         inc(where[i]);
         dec(left[i]);
         if left[i]<2 then begin
           if tm>1 then kind[i]:=random(2) else
                   kind[i]:=random(DELETE_PROB);
           where[i]:=random(25);
           left[i]:=1+random(26-where[i]);
         end;
         if kind[i]=DROP_CONST then begin
           wro(i,where[i],char(byte('A')+random(26)));
           wcol(i,where[i],15);
         end;
      end;
    end;
end;