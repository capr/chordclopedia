
var cbar,cp:integer; { cursor/list-point on change_scale window }
    ckey,            { current/last key cursor }
    ctab,            { -""- activated tab }
    cform,           { cursor on intervals }
    ctriad,cadd1,cadd2 { cursor on triad, add1, add2 }
    :byte;
    goback:boolean;      { forced exit from two/more nested procedures }

     { ctab: 1:on_key, 2: on_interval, 3: on_scale,
             4: on_triad, 5: on_add1, 6: on_add2, 0: back to main window }

procedure update_all; forward;
procedure change_tab(tof:byte); forward;
procedure activate; forward;
procedure passivate; forward;
{$I chscale.pas}

procedure graphic;
begin
     passivate;
     gotoxy(3,10);
     fill(3,10,74,stringnum+2,ucol);
     border(3,10,74,stringnum+2,ucol);
     for f:=0 to 3 do
         wr(19+f*10,11+stringnum,char(byte('0')+f*2+3),ucol);
     _wrs(63,11+stringnum,'12',ucol);
     for f:=1 to stringnum do begin
         wrs(4,10+f,notes[modnote(cstrings[f])],ucol);
         for ff:=1 to 67 do
             _wrs(6+ff,10+f,'-',ucol);
         for i:=1 to 13 do
             _wrs(1+i*5,10+f,'|',ucol);
         for i:=0 to 21 do begin
             if form[i] then
                if modnote(ckey+i-cstrings[f])=0 then
                begin
                   wrs(4,10+f,notes[modnote(cstrings[f])],acol);
                   for ff:=1 to 67 do
                       _wrs(6+ff,10+f,'-',acol);
                   for i:=1 to 13 do
                       _wrs(1+i*5,10+f,'|',acol);
                end;
         end;
         for i:=0 to 21 do begin
             if form[i] then begin
                ii:=modnote(ckey+i-cstrings[f]);
                if ii <> 0 then
                   _wrs(3+ii*5,10+f,notes[modnote(ckey+i)],acol)
             end;
         end;
     end;
     getscan;
     fill(3,10,74,stringnum+2,ucol);
     update_all;
     activate;
end;

procedure pass_key; begin
     trace(27+ckey*4,4,4,ucol);
     trace(27+ckey*4,5,4,ucol);
end;

procedure act_key; begin
     trace(27+ckey*4,4,4,mcol);
     trace(27+ckey*4,5,4,mcol);
end;

procedure update_notes;    { update interval notes from key changing }
begin
     for f:=0 to 21 do
         _wrs(10,2+f,notes[modnote(ckey+f)]+' ',acol);
end;

procedure update_scale;    { update scale/intervals from key changing }
var iii:integer;
begin
     _wrs(27,7,notes[ckey]+' ',acol);
     for i:=0 to 6 do begin
         ii:=modnote(scale.rd[i]+ckey);
         _wrs(27+i*7,9,notes[ii]+' ',acol);
     end;
end;

procedure act_scalename; begin
          s:=' '+scale.name+' ';
          wrs(29,7,s,mcol);
end;
procedure pass_scalename; begin
          s:=' '+scale.name+' ';
          wrs(29,7,s,acol);
end;
procedure change_scalename;
begin
      repeat
          case getscan of
              esc_key: begin goback:=true; exit; end;
spc_key,enter_key,scale_key: change_scale;
              graph_key: graphic;
              tab_key: begin change_tab(ctab+1); break; end;
              u_key: begin change_tab(1); break; end;
              d_key: begin end;
              l_key: begin change_tab(2); break; end;
              r_key: begin end;
          end;
      until false;
end;

procedure act_intervals; begin
          trace(2,2+cform,15,mcol);
end;

procedure pass_intervals; begin
          trace(2,2+cform,15,ucol);
          wrs(10,2+cform,notes[modnote(ckey+cform)],acol);
end;

procedure change_intervals;
var lform:byte;
begin
          repeat
                lform:=cform;
                case getscan of
                esc_key: begin goback:=true; break; end;
                tab_key: begin change_tab(ctab+1); break; end;
              scale_key: change_scale;
              graph_key: graphic;
      enter_key,spc_key: begin
                             if form[cform] then form[cform]:=false else
                             form[cform]:=true;
                             if form[cform] then wr(15,2+cform,#13,mcol)
                             else wr(15,2+cform,' ',mcol);
                        end;
                 u_key: begin
                             pass_intervals;
                             if cform > 0 then dec(cform) else
                             cform:=21;
                             act_intervals;
                        end;
               d_key: begin
                             pass_intervals;
                             if cform < 21 then inc(cform) else
                             cform:=0;
                             act_intervals;
                        end;
               r_key: begin
                           if cform > 5 then change_tab(3)
                           else change_tab(1);
                           break;
                      end;
               l_key: begin end;
                end;
          until false;
end;

{ update intervals array/scale name from scale array and display it }
procedure update_intervals;
begin
     for f:=0 to 21 do begin
         str(f,s);
         wrs(4-length(s),2+f,s,ucol);
         intervals[f]:=-1;
     end;
     for f:=0 to 6 do
         intervals[scale.rd[f]]:=f+1;
     for ff:=7 to 12 do
         intervals[scale.rd[ff-7]+12]:=ff+1;
     { display intervals and their names }
     for f:=0 to 21 do begin
         if intervals[f] <> -1 then
                 str(intervals[f],s)
         else
         if intervals[f-1] <> -1 then begin
                 str(intervals[f-1],s);
                 wr(9,2+f,'#',ucol);
         end else begin
                       str(intervals[f+1],s);
                       wr(9,2+f,'b',ucol);
                  end;
         wrs(8-length(s),2+f,s,ucol);
         { form[f]:=false; }
     end;
     update_notes;
     { load flags from chord formula !!!!!! }
     { display selected flags }
     for f:=0 to 21 do
         if form[f] then wr(15,2+f,#13,ucol)
         else wr(15,2+f,' ',ucol);
     { update scale name }
     s:=scale.name; tab(s,scale_namelen);
     wrs(30,7,s,acol);
     { update scale notes }
     update_scale;
     { "graphical" display of distances between notes }
     for f:=0 to 5 do
         case scale.rd[f+1]-scale.rd[f] of
              1: _wrs(30+f*7,8,'--',rcol);
              2: _wrs(30+f*7,8,'==',rcol);
              3: _wrs(30+f*7,8,#240#240,rcol);
         end;
     f:=6;
     case 12-scale.rd[f] of
          1: _wrs(30+f*7,8,'--',rcol);
          2: _wrs(30+f*7,8,'==',rcol);
          3: _wrs(30+f*7,8,#240#240,rcol);
     end;
end;

procedure change_key;
begin
     repeat
           case getscan of
           tab_key: begin change_tab(ctab+1); break; end;
         scale_key: change_scale;
         graph_key: graphic;
             l_key: begin
                        pass_key;
                        if ckey < 1 then
                        ckey:=11 else dec(ckey);
                        act_key;
                        update_scale;
                        update_notes;
                   end;
           r_key: begin
                        pass_key;
                        if ckey > 10 then ckey:=0 else inc(ckey);
                        act_key;
                        update_scale;
                        update_notes;
                   end;
            u_key: begin end;
            d_key: begin change_tab(3); break; end;
          esc_key: begin
                        goback:=true;
                        exit;
                   end;
           end;
     until false;
end;

procedure update_all;
begin
     gotoxy(0,1);
     { title and stuff }
     border(0,1,scrx,scry-1,ucol);
     s:=main_options[1];
     c_wrs(1,s,tcol);
     s:='F1=HelpÍÍÍESC=BackÍÍÍF3=GraphicÍÍÍF2=Ch.Scale';
     wros(2,24,s);
     { key notes }
     s:='key:';
     wrs(20,4,s,ucol);
     for f:=0 to 11 do begin
         wros(28+f*4,4,notes[f]);
         wros(28+f*4,5,notes2[f]);
     end;
     { scale shape }
     _wrs(20,7,'scale: ',ucol);
     wrs(27,7,notes[ckey],acol);
     { Intervals, scale name and shape }
     s:='  1      2      3      4      5      6      7  ';
     wrs(25,8,s,ucol);
     update_intervals;
     { display chord formation dialog box }
     _wrs(40,12,'Triad    1st Add    2nd Add',ucol);
     _wrs(41,14,'Maj',ucol);
     _wrs(41,15,'Min',ucol);
     _wrs(41,16,'Sus2',ucol);
     _wrs(41,17,'Sus4',ucol);
     _wrs(40,18,'Sus2/4',ucol);
     _wrs(41,19,'Aug',ucol);
     _wrs(41,20,'Dim',ucol);

     _wrs(50,14,'min7th',ucol);
     _wrs(50,15,'maj7th',ucol);
     _wrs(51,16,'6th',ucol);

     _wrs(62,14,'9th',ucol);
     _wrs(62,15,'11th',ucol);
     _wrs(62,16,'13th',ucol);

     _wrs(21,12,'Chord Name:',ucol);
     {_border(22,13,17,4,ucol);}
     { ********** }
     activate;
end;

procedure passivate; begin       { passivate cuurent tab }
     case ctab of
          1: pass_key;
          2: pass_intervals;
          3: pass_scalename;
     end;
end;
procedure activate;  begin       { activate the current tab }
          case ctab of
               1: act_key;
               2: act_intervals;
               3: act_scalename;
          end;
end;
procedure change_tab(tof:byte); begin
     passivate;
     if tof > 3 then ctab:=1 else
     if tof < 1 then ctab:=3 else
     ctab:=tof;
     activate;
end;

procedure chord_formation;              { chord formation window }
label l1;
     var scan:byte;
begin
     fill(1,1,scrx-2,scry-2,ucol);
  l1:
     update_all;
     repeat
     if goback then
        begin
             fill(1,1,scrx-1,scry-1,ucol);
             goback:=false;
             exit;
        end
     else
     case ctab of
          1: change_key;
          2: change_intervals;
          3: change_scalename;
     end;
     until false;
end;
