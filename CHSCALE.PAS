
procedure ch_scale(np:integer);
var t:integer;
begin
     t:=scalenum; if scalenum > 19 then t:=19;
     for i:=1 to t do begin
         s:=scales^[np+i].name;
         tab(s,scale_namelen);
         wros(4,i+3,s);
     end;
end;

procedure change_scale;                    { change scale (F2) window }
const l=40;
var t,lbar,lp:integer;
begin
     passivate;
     fill(3,3,l,21,ucol);
     border(3,3,l,21,ucol);
     _wrs(17,3,' Scales ',tcol);
     gotoxy(3,3);
     for i:=2 to 60 do wr(i,24,'Í',ucol);
     s:='F1=HelpÍÍÍÍESC=BackÍÍÍÍENTER=Accept';
     wros(5,23,s);
     ch_scale(cp);
     trace(4,cbar+4,l-3,mcol);

     t:=18; if scalenum <= t then t:=scalenum-1;
     repeat
           lbar:=cbar;
           lp:=cp;
           case getscan of
             u_key: if cbar > 0 then dec(cbar) else
                    if cp > 0 then dec(cp);

             d_key: if cbar < t then inc(cbar) else
                    if cp < scalenum-19 then inc(cp);
          pgup_key: if cbar > 0 then cbar:=0 else
                    if cp > 18 then dec(cp,18) else
                    if cp > 0 then cp:=0;
          pgdn_key:
                    if cbar < t then cbar:=t else
                    if scalenum-19 < 19 then
                       cp:=scalenum-19
                    else inc(cp,19);
           esc_key: break;
         enter_key: begin
                         scale:=scales^[cp+cbar+1];
                         scale_p:=cp+cbar+1;
                         break;
                    end;
           end;
           if cbar <> lbar then begin
              trace(4,lbar+4,l-3,ucol);
              trace(4,cbar+4,l-3,mcol);
           end else
           if cp <> lp then ch_scale(cp);
     until false;
     fill(3,3,40,21,ucol);
     update_all;
end;
