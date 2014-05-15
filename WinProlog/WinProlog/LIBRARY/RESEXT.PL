/* Resource Extraction Program - Brian D Steel - 02 Jul 93
** =======================================================
**
** This program searches Windows 3.1 executable files and extracts certain
** resources from them. It was written to find and remove the playing card
** bitmaps from SOL.EXE, but should be adaptable to other purposes.
*/

/* open the file, check its format, and find the resource table */

extract(File) :-
  fopen(File,File,0),
  input(File),
  inpos(16'0018),
  getx(2,Dos),
  Dos >= 16'0040,
  inpos(16'003c),
  getx(2,Win),
  inpos(Win),
  getx(2,ID),
  ID = 16'454e,
  Tab is Win + 16'0024,
  inpos(Tab),
  getx(2,Off),
  Start is Win + Off,
  inpos(Start),
  getx(2,Shf),
  Factor is 2 ^ Shf,
  getx(2,Type),
  gofer(Type,0,File,Start,Factor).

extract(File) :-
  fclose(File),
  write('File is not a Windows Executable'),
  fail,
  nl.

/* go for it! */

gofer(16'0000,Num,File,_,_) :-
  fclose(File),
  write(Num),
  write(' resource(s) processed'),
  nl,
  !.

gofer(16'8002,Num,File,Start,Factor) :-
  getx(2,Count),
  getx(4,_),
  write(Count),
  write(' bitmap(s) found...'),
  nl,
  bitmap(Count,Start,Factor),
  New is Num + Count,
  getx(2,Type),
  !,
  gofer(Type,New,File,Start,Factor).

gofer(16'8003,Num,File,Start,Factor) :-
  getx(2,Count),
  getx(4,_),
  write(Count),
  write(' icon(s) found...'),
  nl,
  icon(Count,Start,Factor),
  New is Num + Count,
  getx(2,Type),
  !,
  gofer(Type,New,File,Start,Factor).

gofer(16'8001,Num,File,Start,Factor) :-
  getx(2,Count),
  getx(4,_),
  write(Count),
  write(' cursor(s) found...'),
  nl,
  cursor(Count,Start,Factor),
  New is Num + Count,
  getx(2,Type),
  !,
  gofer(Type,New,File,Start,Factor).

gofer(_,Num,File,Start,Factor) :-
  getx(2,Count),
  inpos(Current),
  Pos is Current + Count * 12 + 4,
  inpos(Pos),
  getx(2,Type),
  !,
  gofer(Type,Num,File,Start,Factor).

/* fetch the given number of bitmaps */

bitmap(0,_,_) :-
  !.

bitmap(Count,Start,Factor) :-
  getx(2,Off),
  Offset is Off * Factor,
  getx(2,Sze),
  Size is Sze * Factor,
  getx(2,_),
  getx(2,Nam),
  getx(4,_),
  name(Nam,'BMP',Start,Name),
  write('  bitmap: '),
  write(Name),
  write(', size: '),
  write(Size),
  Bytes is Size + 16'000e,
  cat([Name,'.BMP'],File,_),
  fcreate(File,File,0),
  output(File),
  inpos(Current),
  inpos(Offset),
  getx(4,Info),
  bitmap(Info,Bits),
  inpos(Offset),
  write('BM'),
  putx(4,Bytes),
  putx(4,0),
  putx(4,Bits),
  copy(Size,Copied),
  inpos(Current),
  fclose(File),
  Size = Copied,
  write(' OK'),
  nl,
  Less is Count - 1,
  bitmap(Less,Start,Factor).

/* compute the offset of the start of bits in a bitmap */

bitmap(16'000c,Bits) :-
  getx(4,_),
  getx(2,Pln),
  getx(2,Bit),
  Bits is 3 * 2 ^ (Pln * Bit) + 16'000e + 16'000c.

bitmap(16'0028,Bits) :-
  getx(4,_),
  getx(4,_),
  getx(2,Pln),
  getx(2,Bit),
  Bits is 4 * 2 ^ (Pln * Bit) + 16'000e + 16'0028.

/* fetch the given number of icons */

icon(0,_,_) :-
  !.

icon(Count,Start,Factor) :-
  getx(2,Off),
  Offset is Off * Factor,
  getx(2,Sze),
  Size is Sze * Factor,
  getx(2,_),
  getx(2,Nam),
  getx(4,_),
  name(Nam,'ICO',Start,Name),
  write('  icon: '),
  write(Name),
  write(', size: '),
  write(Size),
  nl,
  Less is Count - 1,
  icon(Less,Start,Factor).

/* fetch the given number of cursors */

cursor(0,_,_) :-
  !.

cursor(Count,Start,Factor) :-
  getx(2,Off),
  Offset is Off * Factor,
  getx(2,Sze),
  Size is Sze * Factor,
  getx(2,_),
  getx(2,Nam),
  getx(4,_),
  name(Nam,'CUR',Start,Name),
  write('  cursor: '),
  write(Name),
  write(', size: '),
  write(Size),
  nl,
  Less is Count - 1,
  cursor(Less,Start,Factor).

/* return the name of a resource */

name(Nam,Prefix,_,Name) :-
  Nam >= 16'8000,
  Int is Nam - 16'8000,
  output(Current),
  output((``,0)),
  write(Prefix),
  write('_'),
  fwrite(r,4,10,Int),
  output(Output),
  output(Current),
  Output = (String,_),
  stratm(String,Name),
  !.

name(Nam,_,Start,Name) :-
  Offset is Nam + Start,
  inpos(Current),
  inpos(Offset),
  getx(1,Chars),
  fread(a,Chars,0,Name),
  inpos(Current).
