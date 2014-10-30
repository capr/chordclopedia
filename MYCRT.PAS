unit mycrt;


{ I've made this simply cause borland's crt unit has the div/0 bug :)) }

interface

const Black=0;
      Blue=1;
      Green=2;
      Cyan=3;
      Red=4;
      Magenta=5;
      Brown=6;
      LightGray=7;
      DarkGray=8;
      LightBlue=9;
      LightGreen=10;
      LightCyan=11;
      LightRed=12;
      LightMagenta=13;
      Yellow=14;
      White=15;


const cursor_hi:byte=5;
      cursor_lo:byte=6;

var scrx,scry,mode,current_page:byte;
    textaddr,_colw:word;
    scrsize:word;
    key:char;
    scan:byte;

function colof(ink,paper:byte):byte;
procedure wr(x,y:byte;ch:char;col:byte);
procedure wro(x,y:byte;ch:char);
procedure wcol(x,y:byte;col:byte);

procedure wrs(x,y:byte;var sf:string;col:byte);
procedure wros(x,y:byte;var sf:string);
procedure c_wrs(y:byte;var sf:string;col:byte);
procedure r_wrs(x,y:byte;var sf:string;col:byte);

procedure _wrs(x,y:byte;sf:string;col:byte);
procedure _wros(x,y:byte;sf:string);
procedure _c_wrs(y:byte;sf:string;col:byte);
procedure _r_wrs(x,y:byte;sf:string;col:byte);

procedure trace(x,y,lenf,colf:byte);
procedure cls(cf:char;col:byte);
procedure border(x,y,xlen,ylen,col:byte);
procedure _border(x,y,xlen,ylen,col:byte);
procedure fill(x,y,xlen,ylen,col:byte);
procedure solidfill(x,y,xlen,ylen:byte;c:char;col:byte);

procedure chide(blinkf:byte);
procedure gotoxy(xf,yf:byte);
function  getx:byte;
function  gety:byte;

function getkey:char;
function getscan:byte;
procedure readkey;

PROCEDURE Delay(ms : Word);
function keypressed:boolean;
procedure WaitRetrace;

implementation

procedure ShortDelay(Interval: Word); assembler;
{ Interval = number of ticks
  Note: About 1193180 ticks/s }
  asm
    push ax
    push bx
    cmp  Interval,0FFFFh  { otherwise 0FFFFh will end in an infinite loop }
    jne  @start
    dec  Interval
    @start:
    in   al,040h          { save initial time in bx }
    mov  bl,al
    in   al,040h
    mov  bh,al
    @delayloop:
    in   al,040h          { get current time }
    xchg al,ah
    in   al,040h
    xchg al,ah
    sub  ax,bx            { calculate the difference }
    neg  ax
    cmp  ax,Interval      { are we done? }
    jb   @delayloop
    pop  bx
    pop  ax
    end;

procedure delay(ms: Word);
{ identical to the faulty Borland delay procedure }
var
A : Word;
begin
for A := 1 to ms do
 ShortDelay(1193);  { pause for 1 ms }
end;


function colof(ink,paper:byte):byte;
begin
     colof:=ink or (paper shl 4);
end;

procedure wr; begin
          memW[textaddr:(y*scrx+x) shl 1]:=byte(ch) or (col shl 8);
end;
procedure wro;
begin
     mem[textaddr:((y*scrx+x) shl 1)]:=byte(ch);
end;
procedure wcol;
begin
     mem[textaddr:((y*scrx+x) shl 1)+1]:=col;
end;
procedure wrs;
var f:byte;
begin     _colw:=col shl 8;
          for f:=1 to length(sf) do
              memW[textaddr:(y*scrx+x+f) shl 1]:=byte(sf[f]) or _colw;
end;
procedure wros;
var f:byte;
begin     for f:=1 to byte(sf[0]) do
              mem[textaddr:(y*scrx+x+f) shl 1]:=byte(sf[f]);
end;
procedure c_wrs;  begin wrs(((scrx-length(sf)) div 2)-1,y,sf,col); end;
procedure r_wrs; begin wrs(scrx-length(sf)-x-1,y,sf,col); end;

procedure _wrs;   begin     wrs(x,y,sf,col); end;
procedure _wros;  begin     wros(x,y,sf); end;
procedure _c_wrs; begin     c_wrs(y,sf,col); end;
procedure _r_wrs; begin     r_wrs(x,y,sf,col); end;

procedure trace;
var f:byte;
begin      for f:=1 to lenf do
              mem[textaddr:1+((y*scrx+x+f) shl 1)]:=colf;
end;
procedure border;
var f,ff:byte;
begin             {»…∂∑∏π∫ªºΩæø¿¡¬√ƒ≈∆«µ¥≥ºΩæπ ÀÃÕ◊ÿŸ⁄ÕŒœ–—“”‘’÷}
     for f:=1 to xlen-2 do begin
         wr(x+f,y,'Õ',col);
         wr(x+f,y+ylen-1,'Õ',col);
     end;
     for f:=1 to ylen-2 do begin
         wr(x,y+f,'∫',col);
         wr(x+xlen-1,y+f,'∫',col);
     end;
     wr(x,y,'…',col);
     wr(x,y+ylen-1,'»',col);
     wr(x+xlen-1,y,'ª',col);
     wr(x+xlen-1,y+ylen-1,'º',col);
end;
procedure _border;
var f,ff:byte;
begin             {»…∂∑∏π∫ªºΩæø¿¡¬√ƒ≈∆«µ¥≥ºΩæπ ÀÃÕ◊ÿŸ⁄ÕŒœ–—“”‘’÷}
     for f:=1 to xlen-2 do begin
         wr(x+f,y,'ƒ',col);
         wr(x+f,y+ylen-1,'ƒ',col);
     end;
     for f:=1 to ylen-2 do begin
         wr(x,y+f,'≥',col);
         wr(x+xlen-1,y+f,'≥',col);
     end;
     wr(x,y,'⁄',col);
     wr(x,y+ylen-1,'¿',col);
     wr(x+xlen-1,y,'ø',col);
     wr(x+xlen-1,y+ylen-1,'Ÿ',col);
end;
procedure fill;
var f,ff:byte;
begin
     for ff:=0 to ylen-1 do
         for f:=0 to xlen-1 do
             wr(x+f,y+ff,' ',col);
end;

procedure solidfill;
var f,ff:byte;
begin
     for ff:=0 to ylen-1 do
         for f:=0 to xlen-1 do
             wr(x+f,y+ff,c,col);
end;

procedure cls;assembler;
asm
   mov es,textaddr
   mov al,scry
   mov cl,scrx
   mul cl
   mov cx,ax
   xor di,di
   mov al,cf
   mov ah,col
   cld
   rep stosw
end;

procedure chide; assembler;
asm
           mov ah,15
           int 10h
           mov ch,blinkf
           mov cl,5
           shl ch,cl
           add ch,cursor_hi
           mov cl,cursor_lo
           mov ah,1
           int 10h
end;
procedure gotoxy; assembler;
asm
   mov bh,current_page
   mov dh,yf
   mov dl,xf
   mov ah,2
   int 10h
end;
function getx; assembler;
asm
   mov bh,current_page
   mov ah,3
   int 10h
   mov al,dl
   xor ah,ah
end;
function gety; assembler;
asm
   mov bh,current_page
   mov ah,3
   int 10h
   mov al,dh
   xor ah,ah
end;

function getkey:char; assembler;
asm
   xor ax,ax
   int 16h
   xor ah,ah
end;
function getscan:byte; assembler;
asm
   xor ax,ax
   int 16h
   mov al,ah
   xor ah,ah
end;

procedure readkey; assembler;
asm
   xor ax,ax
   int 16h
   mov key,al
   mov scan,ah
end;


procedure WaitRetrace; assembler;
label
  l1, l2;
asm
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
end;

function keypressed; assembler;
label okl,endl;
asm
   mov ah,01h
   int 16h
   jnz okl
   mov ax,0
   jmp endl
 okl: mov ax,1
 endl:
end;


begin
     textaddr:=$B800;
     scrx:=80;
     scry:=25;
     scrsize:=scrx*scry;
     mode:=2;
     current_page:=0;
end.
