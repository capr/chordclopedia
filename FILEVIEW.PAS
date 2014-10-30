{ fileview contains each file-line seek }
{ sorry but max line-num=4000 }
var fileview_lines:array[1..4000] of longint;
    fileview_linenum:integer;
    fileview_recip:array[1..512] of char;
  {temp to store one line, read 512bytes at a time to gain max. read speed}
    fileview_name:string; { charge this when using init_fileview/view_file }
    fileview_cfile:file of char;
    fileview_file:file;

procedure open_fileview;
var c:char;
begin
    endmsg:='Error in file <'+path+fileview_name+'>';
    assign(fileview_cfile,fileview_name);
    reset(fileview_cfile);
    {$I-}
    fileview_linenum:=2;
    fileview_lines[2]:=0;
    read(fileview_cfile,c);
    while not Eof(fileview_cfile) do begin
          if c=#10 then begin
             fileview_lines[fileview_linenum]:=filepos(fileview_cfile);
             inc(fileview_linenum);
          end;
          read(fileview_cfile,c);
    end;
    fileview_lines[fileview_linenum]:=fileview_lines[fileview_linenum-1];
    {$I+}
    close(fileview_cfile);
    assign(fileview_file,fileview_name);
    reset(fileview_file,1);
end;

procedure close_fileview; begin
    close(fileview_file);
end;

{view_file displays a file then returns the number of lines shown}
function review(_line:integer):integer;
var i,j,k,ret:integer;
    linenum,cpos,l:longint;
begin
    linenum:=22;

    if _line<1 then _line:=1 else
    if _line>fileview_linenum-linenum then
       _line:=fileview_linenum-linenum;
    for i:=2 to linenum do begin
        cpos:=fileview_lines[_line+i-1];
        seek(fileview_file,cpos);
        blockread(fileview_file,fileview_recip,
                  fileview_lines[_line+i]-cpos,ret);
        if ret>78 then ret:=78;
        for j:=1 to 78 do
            wr(j,i,' ',white);
        k:=0;
        for j:=1 to ret-2 do begin
            inc(k);
            if fileview_recip[j]=#9 then
               k:=(k and 248)+7
            else
               wr(k,i,fileview_recip[j],white);
        end;
    end;
    l:=100*longint(_line); l:=l div fileview_linenum; str(l,s); s:=s+'%';
    if length(s)=2 then s:=s+'Í';
    wros(2,1,s);
    review:=_line;
end;

procedure view_file(const namef:string);
var k:byte;
    cline,lline:integer;
begin
     fileview_name:=namef;
     fill(1,1,scrx-2,scry-2,ucol);
     gotoxy(0,1);
     { title and stuff }
     border(0,1,scrx,scry-1,ucol);
     s:=main_options[cmenu];
     c_wrs(1,s,tcol);
     s:='F1=HelpÍÍÍPgUp-PgDown,Up-Down=ReadÍÍÍESC=ExitÍÍÍÍÍÍÍÍÍÍÍÍ';
     wros(2,24,s);
     open_fileview;
     str(fileview_linenum,s);
     s:='count: '+s+' lines';
     wros(60,1,s);
     cline:=1; review(1);
     repeat
          lline:=cline;
          k:=getscan;
          if k=u_key then dec(cline) else
          if k=d_key then inc(cline) else
          if k=pgup_key then dec(cline,22) else
          if k=pgdn_key then inc(cline,22);
          if cline<>lline then
             cline:=review(cline);
     until k=esc_key;
     close_fileview;
     fill(1,1,scrx-1,scry-1,ucol);
end;
