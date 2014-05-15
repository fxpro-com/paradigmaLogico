/*
** 386-PROLOG Bitmap Exchange Program - (c) Brian D Steel - 12 Jan 94
** ==================================================================
**
** This program attempts to replace the large and small banner bitmap
** resources in a copy of the 386-PROLOG for Windows executable file,
** to enable users to customise the welcome and aboutbox banners.
**
** The replacement bitmap resources should be 16-colour, uncompressed
** device independent bitmaps (for example, .BMP files created within
** Windows PaintBrush). The larger and smaller bitmaps should have be
** of exactly the following dimensions:
**
**     BITMAP424:	424*320 pixels
**     BITMAP320:	320*240 pixels
**
** The new_bitmaps/4 predicate will fail if either one of the bitmaps
** is of the wrong format.
*/

/* add new bitmaps to a copy of 386-PROLOG */

new_bitmaps(NameOld,NameNew,Name424,Name320) :-
  cat([NameOld,'.EXE'],FileOld,_),	% prepare the full file names
  cat([NameNew,'.EXE'],FileNew,_),
  cat([Name424,'.BMP'],File424,_),
  cat([Name320,'.BMP'],File320,_),
  dir(FileOld,-39,DirOld),		% ensure this file exists
  (DirOld = [] ->
    (write(FileOld),
     write(' does not exist!'),
     nl,
     fail) ;
    (true)),
  dir(FileNew,-39,DirNew),		% ensure this file does not exist
  (DirNew = [_] ->
    (write(FileNew),
     write(' already exists!'),
     nl,
     fail) ;
    (true)),
  dir(File424,-39,Dir424),		% ensure this file exists
  (Dir424 = [] ->
    (write(File424),
     write(' does not exist!'),
     nl,
     fail) ;
    (true)),
  dir(File320,-39,Dir320),		% ensure this file exists
  (Dir320 = [] ->
    (write(File320),
     write(' does not exist!'),
     nl,
     fail) ;
    (true)),
  fopen(FileOld,FileOld,0),		% open the files
  fcreate(FileNew,FileNew,0),
  fopen(File424,File424,0),
  fopen(File320,File320,0),
  ((input(FileOld),			% check old file is a windows prog
    inpos(16'0018),
    getx(2,Dos),
    Dos >= 16'0040,
    inpos(16'003c),
    getx(2,Win),
    inpos(Win),
    getx(2,ID),
    ID = 16'454e) ->
      (inpos(0)) ;
      (input(0),
       write(FileOld),
       write(' is not a Windows executable'),
       nl,
       fail)),
  ((input(File424),			% check file is a 424*320 pixel bitmap
    inpos(16'0000),
    getx(2,B424),
    B424 = 16'4D42,
    inpos(16'0012),
    getx(4,W424),
    W424 = 424,
    inpos(16'0016),
    getx(4,H424),
    H424 = 320,
    inpos(16'001A),
    getx(4,P424),
    P424 = 16'00040001) ->
      (inpos(0)) ;
      (input(0),
       write(File424),
       write(' is not a 16-colour, 424*320 pixel device independent bitmap'),
       nl,
       fail)),
  ((input(File320),			% check file is a 320*240 pixel bitmap
    inpos(16'0000),
    getx(2,B320),
    B320 = 16'4D42,
    inpos(16'0012),
    getx(4,W320),
    W320 = 320,
    inpos(16'0016),
    getx(4,H320),
    H320 = 240,
    inpos(16'001A),
    getx(4,P320),
    P320 = 16'00040001) ->
      (inpos(0)) ;
      (input(0),
       write(File320),
       write(' is not a 16-colour, 320*240 pixel device independent bitmap'),
       nl,
       fail)),
  input(FileOld),			% copy old file to new
  output(FileNew),
  copy(-1,Bytes),
  output(0),				% write a status report
  write(FileOld),
  write(' copied to '),
  write(FileNew),
  write(': '),
  write(Bytes),
  write(' bytes'),
  nl,
  Tab is Win + 16'0024,			% compute the start of the resources
  inpos(Tab),
  getx(2,Off),
  Start is Win + Off,
  inpos(Start),
  getx(2,Shf),
  Factor is 2 ^ Shf,
  getx(2,Type),
  search_bitmap(Type,0,File,Start,Factor,[FileOld,FileNew,File424,File320]),
  fclose(FileOld),
  fclose(FileNew),
  fclose(File424),
  fclose(File320),
  output(0),				% write a final report
  write('Processing of '),
  write(FileNew),
  write(' complete.'),
  nl.

/* search for bitmap resources */

search_bitmap(16'0000,Num,File,_,_,_) :-
  write(Num),
  write(' bitmap(s) encountered'),
  nl,
  !.

search_bitmap(16'8002,Num,File,Start,Factor,Files) :-
  getx(2,Count),
  getx(4,_),
  write(Count),
  write(' bitmap(s) found...'),
  nl,
  substitute_bitmap(Count,Start,Factor,Files),
  New is Num + Count,
  getx(2,Type),
  !,
  search_bitmap(Type,New,File,Start,Factor,Files).

search_bitmap(_,Num,File,Start,Factor,Files) :-
  getx(2,Count),
  inpos(Current),
  Pos is Current + Count * 12 + 4,
  inpos(Pos),
  getx(2,Type),
  !,
  search_bitmap(Type,Num,File,Start,Factor,Files).

/* extract the given number of bitmaps */

substitute_bitmap(0,_,_,_) :-
  !.

substitute_bitmap(Count,Start,Factor,[FileOld,FileNew,File424,File320]) :-
  getx(2,Off),
  Offset is Off * Factor,
  getx(2,Sze),
  Size is Sze * Factor,
  getx(2,_),
  getx(2,Nam),
  getx(4,_),
  name_bitmap(Nam,Start,Name),
  inpos(Current),
  inpos(Offset),
  getx(4,Info),
  inpos(Offset),
  (Name = 'BITMAP424' ->
    (input(File424),
     inpos(16'000e),
     output(FileNew),
     outpos(Offset),
     copy(Size,_),
     input(FileOld),
     output(0),
     write('  substituted: ')) ;
  Name = 'BITMAP320' ->
    (input(File320),
     inpos(16'000e),
     output(FileNew),
     outpos(Offset),
     copy(Size,_),
     input(FileOld),
     output(0),
     write('  substituted: ')) ;
    (write('  not changed: '))),
  write(Name),
  write(', size: '),
  write(Size),
  write(' bytes'),
  nl,
  inpos(Current),
  Less is Count - 1,
  substitute_bitmap(Less,Start,Factor,[FileOld,FileNew,File424,File320]).

/* return the name of a resource */

name_bitmap(Nam,_,Name) :-
  Nam >= 16'8000,
  Int is Nam - 16'8000,
  output(Current),
  output((`BMP_`,-1)),
  fwrite(r,4,10,Int),
  output(Output),
  output(Current),
  Output = (String,_),
  stratm(String,Name),
  !.

name_bitmap(Nam,Start,Name) :-
  Offset is Nam + Start,
  inpos(Current),
  inpos(Offset),
  getx(1,Chars),
  fread(a,Chars,0,Name),
  inpos(Current).
