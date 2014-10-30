      {
      ChordClopedia v0.9 source code
      ------------------------------
      software:      freeware, compiled in april 1999 with BPC v7.0
      author:        Apreutesei Cosmin
      e-mail:        cosmin.apreutesei@gmail.com
      license:       GPL General Public License
      }

{$V-}
uses windos, strings, mycrt;

const scale_namelen=20;
      MAXFORM=6;

type  Tscale=record
                name:string[scale_namelen];
                rd:array[0..6] of byte;  { rd = root distance }
      end;
      ATscale=array[1..2000] of Tscale;
      PATscale=^ATscale;
      Tabsnote=record       { an abstract note that is ... }
              note:integer; { (note number in a scale)-1; -1=not used }
              dist:integer; { distance in s-tones relative to that note }
      end;     { dist < 0 means flat, > 0 means sharp, so 0 means major }
      Tchord=array[1..MAXFORM] of Tabsnote;

const
      exit_s='Have a musical day.';
      title_s:string='TheอChordClopediaอv0.9อ(c)''99อbyอwoods';
      author_notice:array[1..5] of string=(
      'software:      freeware, compiled in april 1999 using bp7',
      'proramme:      cosmin apreutesei',
      'address:       str. marasesti 114/A/36, bacau, 5500',
      'phone:         (+40)034-184570',
      'e-mail:        woodsmailbox@yahoo.com');
      memerr_s='Error allocating memory.';

      stringnum=6;      { we're talking about a general 6 strings guitar }
                    {maj_scale:TScale=(name:'Major';rd:(0,2,4,5,7,9,11));}
      notes:array[0..11] of string[2] =
            ('A','A#','B','C','C#','D','D#','E','F','F#','G','G#');
      notes2:array[0..11] of string[2] =
            ('  ','Bb','  ','  ','Db','  ','Eb','  ','  ','Gb','  ','Ab');
      ncol:array[0..11] of byte = (12,12,13,14,14,10,10,11,9,9,8,8);

      main_num=5;     { number of options in the main menu }
      main_options:array[1..main_num] of string=(
          (' guitar chord formation for '+char(stringnum+byte('0'))+' string guitars '),
          (' musical and chord theory '),
          (' apendixes '),
          (' about the author '),
          (' quiT '));

      filename='scales.txt';

      r_key=77; l_key=75; u_key=72; d_key=80; F2_key=60; F3_key=61;
      enter_key=28; spc_key=57; esc_key=1; tab_key=15; pgup_key=73;
      pgdn_key=81;
      scale_key=F2_key;
      graph_key=F3_key;

var
    cstrings:array[1..stringnum] of byte;
  { the current guitar tunning in s-tones relative to the note A }
    inf:text;                   { the file containing the scales }
    scalenum,scale_p:integer;
    scales:PATscale;
    scale:Tscale;              { current scale intervals(key=scale[0]=0) }
    triads:array[1..7] of Tchord; { triads }
    chord:Tchord;                 { current chord }
    intervals:array[0..21] of integer;  { scale notes by semitons }
    form:array[0..21] of boolean; { intervals used in the current chord }

    oldexitproc:procedure;      { the exit/error handler }
    endmsg:string[80];          { writeln-ed on screen at program finish }
    path:string;      { program's directory: database files must be there }

    cmenu,lmenu:byte;           { last/current position on the main menu }
    ucol,mcol:byte;             { normal color, inverse color }
    tcol,acol:byte;             { title color, active-item color }
    rcol:byte;                  { relief color }

    f,ff:integer;               { contors }
    i,ii:integer;               { temps used in sub-sub..-procedures }
    s,ss:string;

{ completes a string with spaces until <tof> }
procedure tab(var sf:string;tof:byte);
begin
     for ii:=length(sf)+1 to tof do s[ii]:=' ';
     s[0]:=char(tof);
end;

function modnote(notef:integer):integer;          { modulo 12 }
begin    modnote:=(notef+12*5) mod 12;       end;

procedure myexit; far; begin                      { my own exitproc }
     exitproc:=@oldexitproc;
     cls(' ',7);
     gotoxy(0,0);
     writeln('ออออออออออออออออออออ'+title_s+'อออออออออออออออออออออ');
     for f:=1 to 5 do writeln(author_notice[f]);
     writeln(#13#10,endmsg);
     freemem(scales,scalenum*sizeof(TScale));
end;

procedure general_load;          { load scales and stuff from scales.txt }
begin
     endmsg:='Error in file <'+path+filename+'>';
     assign(inf,path+filename);
     reset(inf);
     for f:=1 to stringnum do
         read(inf,cstrings[f]);   { get the standard tunning }
     { get 7 triads }
     for f:=1 to 7 do begin
         for ff:=1 to MAXFORM do begin      { get notes }
             read(inf,i);
             triads[f,ff].note:=i-1;
         end;
         for ff:=1 to MAXFORM do            { get flat/sharps }
             read(inf,triads[f,ff].dist);
     end;
     readln(inf,scalenum);       { get the number of availible scales }
     endmsg:=memerr_s;
     getmem(scales,scalenum*sizeof(TScale));
     endmsg:='Error in file <'+path+filename+'>';
     for ff:=1 to scalenum do begin
         readln(inf,scales^[ff].name);
         for f:=1 to 6 do begin
             read(inf,scales^[ff].rd[f]);
             scales^[ff].rd[0]:=0;
         end;
         readln(inf);
     end;
     close(inf);
     scale:=scales^[scale_p];
     endmsg:=exit_s;
end;

{$I form.pas}
{$I fileview.pas}
{$I matrix.pas}

{-------------------------------main-code-----------------------------------}
label l1;
var _S,_dir,_name,_ext:array[0..255] of char;
begin
     exitproc:=@myexit;
     {scale:=maj_scale;}
     scale_p:=1;                       { no scale from file }
     { take the program's path }
     FileSplit(FileExpand(_S,GetArgStr(_S,0,255)),_dir,_name,_ext);
     path:=StrPas(_dir);
     f:=length(path);
     while path[f] <> '\' do dec(f);
     path[0]:=char(f);

     ucol:=colof(7,0);
     mcol:=colof(white,1);
     tcol:=colof(white,0);
     acol:=colof(lightcyan,0);
     rcol:=colof(yellow,0);

     cmenu:=1;
     ctab:=1;

     write('Loading..');
     general_load;

     chord:=triads[1];

     { load selected flags }
     for f:=1 to 6 do
         if chord[f].note >= 0 then
            form[scale.rd[chord[f].note]+chord[f].dist]:=true;

     cls(' ',ucol);

   l1:

     gotoxy(0,0);
     border(0,0,scrx,scry,ucol);
     _c_wrs(0,' '+title_s+' ',tcol);
     _c_wrs(3,' Main Menu ',tcol);
     for f:=1 to main_num do
         c_wrs(4+(f shl 1),main_options[f],ucol);
     c_wrs(4+(cmenu shl 1),main_options[cmenu],mcol);

     s:='F1=HelpออออESC=Exit';
     wrs(2,24,s,ucol);

     repeat
           lmenu:=cmenu;
           case getscan of
                72: if cmenu > 1 then dec(cmenu);     { up }
                80: if cmenu < main_num then inc(cmenu);
                 1: begin endmsg:=exit_s; exit; end;  { down }
                28: case cmenu of                     { enter }
                          1: begin chord_formation; goto l1; end;
                          2: begin view_file('theory.txt'); goto l1; end;
                          3: begin view_file('appendix.txt'); goto l1; end;
                          4: begin
                               matrix;
                               cls(' ',ucol);
                               goto l1;
                          end;
                          5: begin exit; end;
                    end;
           end;
           if lmenu <> cmenu then begin
              c_wrs(4+(lmenu shl 1),main_options[lmenu],ucol);
              c_wrs(4+(cmenu shl 1),main_options[cmenu],mcol);
           end;
     until false;
end.

