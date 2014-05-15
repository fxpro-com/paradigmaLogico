/*
  Predicates for "wgfx" Graphics - Brian D Steel - 30 Oct 96
  ------------------------------   -------------   ---------

  Following the move from a Win16 to a Win32 programming model in version
  3.400 of WIN-PROLOG, the "wgfx" family of graphics predicates has been
  dropped from the system. This library contains faithful implementations of
  the missing predicates, to enable existing graphics programs to run;
  however, it should be noted that there are considerably more powerful,
  flexible and efficient ways in which to perform graphics in the new system.
*/

% initialise resource handles

:- dynamic known_bitmap/2.
:- dynamic known_cursor/2.
:- dynamic known_icon/2.
:- dynamic known_metafile/2.
:- dynamic known_object/2.
:- dynamic known_hits/2.
:- dynamic known_mapping/7.
:- dynamic known_printer/9.

% perform unclipped graphics to a window - bds 30 oct 96

wgfx( Window, Grafix ) :-
   flag( Flag ),
   flag( 0 ),
   wndhdl( Window, Handle ),
   winapi( (user32,'GetDC'), [Handle], Device ),
   winapi( (gdi32,'SaveDC'), [Device], _ ),
   set_mapping( Device ),
   catch( Error, (forall(member(Pred(|Args),Grafix),Pred([],Device,Args)),!) ),
   winapi( (gdi32,'RestoreDC'), [Device,-1], _ ),
   winapi( (user32,'ReleaseDC'), [Handle,Device], _ ),
   forall( retract( known_object(_,Object) ),
           winapi( (gdi32,'DeleteObject'), [Object], _ )
         ),
   (  Error = 0
   -> flag( Flag )
   ;  throw( 13, wgfx(Window,Grafix) )
   ).

% perform clipped graphics to a window - bds 30 oct 96

wgfx( Window, Grafix, L, T, R, B ) :-
   flag( Flag ),
   flag( 0 ),
   wndhdl( Window, Handle ),
   winapi( (user32,'GetDC'), [Handle], Device ),
   winapi( (gdi32,'SaveDC'), [Device], _ ),
   set_mapping( Device ),
   winapi( (gdi32,'CreateRectRgn'), [L,T,R,B], Region ),
   winapi( (gdi32,'SelectClipRgn'), [Device,Region], _ ),
   winapi( (gdi32,'DeleteObject'), [Region], _ ),
   catch( Error, (forall(member(Pred(|Args),Grafix),Pred([],Device,Args)),!) ),
   winapi( (gdi32,'RestoreDC'), [Device,-1], _ ),
   winapi( (user32,'ReleaseDC'), [Handle,Device], _ ),
   forall( retract( known_object(_,Object) ),
           winapi( (gdi32,'DeleteObject'), [Object], _ )
         ),
   (  Error = 0
   -> flag( Flag )
   ;  throw( 13, wgfx(Window,Grafix,L,T,R,B) )
   ).

% perform graphics hit test in a window - bds 30 oct 96

wgfxtst( Window, Grafix, X, Y, Count ) :-
   flag( Flag ),
   flag( 0 ),
   dynamic( known_hits/1 ),
   assert( known_hits(0) ),
   wndhdl( Window, Handle ),
   winapi( (user32,'GetDC'), [Handle], Device ),
   winapi( (gdi32,'SaveDC'), [Device], _ ),
   set_mapping( Device ),
   catch( Error, (forall(member(Pred(|Args),Grafix),Pred((X,Y),Device,Args)),!) ),
   winapi( (gdi32,'RestoreDC'), [Device,-1], _ ),
   winapi( (user32,'ReleaseDC'), [Handle,Device], _ ),
   known_hits( Count ),
   (  Error = 0
   -> flag( Flag )
   ;  throw( 13, wgfx(Window,Grafix,L,T,R,B) )
   ).

% get or set mapping in a graphics window - bds 31 oct 96

wgfxmap( Window, Xw, Yw, Xv, Yv ) :-
   (  wclass( Window, grafix ),
      (  type( Xw, 0 )
      ;  type( Xw, 1 )
      ),
      (  type( Yw, 0 )
      ;  type( Yw, 1 )
      ),
      (  type( Xv, 0 )
      ;  type( Xv, 1 )
      ),
      (  type( Yv, 0 )
      ;  type( Yv, 1 )
      )
   -> wndhdl( Window, Handle ),
      winapi( (user32,'GetDC'), [Handle], Device ),
      (  retract( known_mapping(Device,Xo1,Yo1,Xw1,Yw1,Xv1,Yv1) )
      -> true
      ;  (Xo1,Yo1,Xw1,Yw1,Xv1,Yv1) = (0,0,0,0,0,0)
      ),
      (  type( Xw, 0 )
      -> Xw = Xw1,
         Xw2 = Xw1
      ;  Xw2 = Xw
      ),
      (  type( Yw, 0 )
      -> Yw = Yw1,
         Yw2 = Yw1
      ;  Yw2 = Yw
      ),
      (  type( Xv, 0 )
      -> Xv = Xv1,
         Xv2 = Xv1
      ;  Xv2 = Xv
      ),
      (  type( Yv, 0 )
      -> Yv = Yv1,
         Yv2 = Yv1
      ;  Yv2 = Yv
      ),
      assert( known_mapping(Device,Xo1,Yo1,Xw2,Yw2,Xv2,Yv2) ),
      (  (Xw1,Yw1,Xv1,Yv1) = (Xw2,Yw2,Xv2,Yv2)
      -> true
      ;  winapi( (user32,'InvalidateRect'), [Handle,0,1], _ )
      )
   ;  wclass( Window, grafix )
   -> throw( 23, wgfxmap(Window,Xw,Yw,Xv,Yv) )
   ;  throw( 10, wgfxmap(Window,Xw,Yw,Xv,Yv) )
   ).

% get or set viewport in a graphics window - bds 31 oct 96

wgfxorg( Window, Xo, Yo ) :-
   (  wclass( Window, grafix ),
      (  type( Xo, 0 )
      ;  type( Xo, 1 )
      ),
      (  type( Yo, 0 )
      ;  type( Yo, 1 )
      )
   -> wndhdl( Window, Handle ),
      winapi( (user32,'GetDC'), [Handle], Device ),
      (  retract( known_mapping(Device,Xo1,Yo1,Xw1,Yw1,Xv1,Yv1) )
      -> true
      ;  (Xo1,Yo1,Xw1,Yw1,Xv1,Yv1) = (0,0,0,0,0,0)
      ),
      (  type( Xo, 0 )
      -> Xo = Xo1,
         Xo2 = Xo1
      ;  Xo2 = Xo
      ),
      (  type( Yo, 0 )
      -> Yo = Yo1,
         Yo2 = Yo1
      ;  Yo2 = Yo
      ),
      assert( known_mapping(Device,Xo2,Yo2,Xw1,Yw1,Xv1,Yv1) ),
      Xd is Xo2 - Xo1,
      Yd is Yo2 - Yo1,
      (  (Xo1,Yo1) = (Xo2,Yo2)
      -> true
      ;  winapi( (user32,'ScrollWindow'), [Handle,Xd,Yd,0,0], _ )
      )
   ;  wclass( Window, grafix )
   -> throw( 23, wgfxorg(Window,Xo,Yo) )
   ;  throw( 10, wgfxorg(Window,Xo,Yo) )
   ).

% add to the dirty rectangle of a graphics window - bds 31 oct 96

wgfxadd( Window, L, T, R, B ) :-
   (  wclass( Window, grafix ),
      type( L, 1 ),
      type( T, 1 ),
      type( R, 1 ),
      type( B, 1 )
   -> wndhdl( Window, Handle ),
      winapi( (user32,'GetWindowLongA'), [Handle,4], Clip ),
      winapi( (gdi32,'CreateRectRgn'), [L,T,R,B], Region ),
      winapi( (gdi32,'CombineRgn'), [Clip,Clip,Region,2], _ ),
      winapi( (gdi32,'DeleteObject'), [Region], _ )
   ;  wclass( Window, grafix )
   -> (  (  type( L, 0 )
         ;  type( T, 0 )
         ;  type( R, 0 )
         ;  type( B, 0 )
         )
      -> throw( 22, wgfxadd(Window,L,T,R,B) )
      ;  throw( 23, wgfxadd(Window,L,T,R,B) )
      )
   ;  throw( 10, wgfxadd(Window,L,T,R,B) )
   ).

% subtract from the dirty rectangle of a graphics window - bds 31 oct 96

wgfxsub( Window, L, T, R, B ) :-
   (  wclass( Window, grafix ),
      type( L, 1 ),
      type( T, 1 ),
      type( R, 1 ),
      type( B, 1 )
   -> wndhdl( Window, Handle ),
      winapi( (user32,'GetWindowLongA'), [Handle,4], Clip ),
      winapi( (gdi32,'CreateRectRgn'), [L,T,R,B], Region ),
      winapi( (gdi32,'CombineRgn'), [Clip,Clip,Region,4], _ ),
      winapi( (gdi32,'DeleteObject'), [Region], _ )
   ;  wclass( Window, grafix )
   -> (  (  type( L, 0 )
         ;  type( T, 0 )
         ;  type( R, 0 )
         ;  type( B, 0 )
         )
      -> throw( 22, wgfxsub(Window,L,T,R,B) )
      ;  throw( 23, wgfxsub(Window,L,T,R,B) )
      )
   ;  throw( 10, wgfxsub(Window,L,T,R,B) )
   ).

% get or check the dirty rectangle of a graphics window - bds 31 oct 96

wgfxget( Window, L, T, R, B ) :-
   (  wclass( Window, grafix ),
      (  type( L, 0 )
      ;  type( L, 1 )
      ),
      (  type( T, 0 )
      ;  type( T, 1 )
      ),
      (  type( R, 0 )
      ;  type( R, 1 )
      ),
      (  type( B, 0 )
      ;  type( B, 1 )
      )
   -> wndhdl( Window, Handle ),
      winapi( (user32,'GetDC'), [0], Device ),
      winapi( (user32,'GetWindowLongA'), [Handle,4], Clip ),
      winapi( (gdi32,'SelectClipRgn'), [Device,Clip], _ ),
      btext( [], -1, Text ),
      btext( [], 16, `` ),
      winapi( (gdi32,'GetClipBox'), [Device,[]], _ ),
      btext( [], -1, Data ),
      btext( [], -1, Text ),
      (  getx( 4, L1 ),
         getx( 4, T1 ),
         getx( 4, R1 ),
         getx( 4, B1 )
      )  <~ Data,
      winapi( (user32,'ReleaseDC'), [0,Device], _ ),
      L = L1,
      T = T1,
      R = R1,
      B = B1
   ;  wclass( Window, grafix )
   -> throw( 23, wgfxget(Window,L,T,R,B) )
   ;  throw( 10, wgfxget(Window,L,T,R,B) )
   ).

% force painting of the dirty rectangle of a graphics window - bds 31 oct 96

wgfxpnt( Window ) :-
   (  wclass( Window, grafix )
   -> wndhdl( Window, Handle ),
      winapi( (user32,'GetWindowLongA'), [Handle,4], Clip ),
      winapi( (user32,'InvalidateRgn'), [Handle,Clip,1], _ )
   ;  throw( 10, wgfxpnt(Window) )
   ).

% get or set the cursor (not stored in graphics window) - bds 31 oct 96

wgfxcur( Window, Cursor ) :-
   (  type( Cursor, 0 )
   -> curhdl( Cursor, 5 )
   ;  wndhdl( Window, _ ),
      curhdl( Cursor, Data )
   -> winapi( (user32,'SetCursor'), [Data], _ )
   ;  throw( 23, wcursor(Window,Cursor) )
   ).

% set up mapping for the given device context - bds 31 oct 96

set_mapping( Device ) :-
   (  known_mapping( Device, Xo, Yo, Xw, Yw, Xv, Yv )
   -> winapi( (gdi32,'SetViewportOrgEx'), [Device,Xo,Yo,0], _ ),
      winapi( (gdi32,'SetWindowExtEx'), [Device,Xw,Yw,0], _ ),
      winapi( (gdi32,'SetViewportExtEx'), [Device,Xv,Yv,0], _ )
   ;  true
   ).

% draw an arc through the given arguments - bds 30 oct 96

arc( [], Device, Coords ) :-
   len( Coords, 8 ),
   winapi( (gdi32,'Arc'), [Device|Coords], _ ).

% test an arc through the given arguments - bds 30 oct 96

arc( (X,Y), Device, Coords ).

% select a background colour with the given arguments - bds 30 oct 96

back( [], Device, [R,G,B] ) :-
   RGB is ((B /\ 16'FF) << 16) \/ ((G /\ 16'FF) << 8) \/ (R /\ 16'FF),
   winapi( (gdi32,'SetBkColor'), [Device,RGB], _ ).

% test a background colour with the given arguments - bds 30 oct 96

back( (X,Y), Device, [R,G,B] ).

% draw a bitmap with the given arguments - bds 12 dec 96

bits( [], Device, [X1,Y1,X2,Y2,X3,Y3,Bitmap] ) :-
   bithdl( Bitmap, Handle ),
   winapi( (gdi32,'CreateCompatibleDC'), [Device], Compat ),
   winapi( (gdi32,'SelectObject'), [Compat,Handle], _ ),
   Xd is X2 - X1,
   Yd is Y2 - Y1,
   winapi( (gdi32,'BitBlt'), [Device,X1,Y1,Xd,Yd,Compat,X3,Y3,16'CC0020], _ ),
   winapi( (gdi32,'DeleteDC'), [Compat], _ ).

% test a bitmap with the given arguments - bds 12 dec 96

bits( (X,Y), Device, [X1,Y1,X2,Y2|_] ) :-
   Coords = [X1,Y1,X2,Y2],
   forall( member(Coord,Coords), putx(4,Coord) ) ~> Data,
   btext( [], -1, Text ),
   btext( [], -1, Data ),
   winapi( (gdi32,'LPtoDP'), [Device,[],2], _ ),
   btext( [], -1, Info ),
   btext( [], -1, Text ),
   findall( Value, (member(_,Coords),getx(4,Value)), Values ) <~Info,
   winapi( (gdi32,'CreateRectRgn'), Values, Region ),
   winapi( (gdi32,'PtInRegion'), [Region,X,Y], Hit ),
   winapi( (gdi32,'DeleteObject'), [Region], _ ),
   (  Hit = 0
   -> true
   ;  retract( known_hits(Hits) )
   -> More is Hits + 1,
      assert( known_hits(More) )
   ).

% draw a box through the given arguments - bds 30 oct 96

box( [], Device, Coords ) :-
   len( Coords, 6 ),
   winapi( (gdi32,'RoundRect'), [Device|Coords], _ ).

% test a box through the given arguments - bds 30 oct 96

box( (X,Y), Device, Coords ) :-
   len( Coords, 6 ),
   forall( member(Coord,Coords), putx(4,Coord) ) ~> Data,
   btext( [], -1, Text ),
   btext( [], -1, Data ),
   winapi( (gdi32,'LPtoDP'), [Device,[],3], _ ),
   btext( [], -1, Info ),
   btext( [], -1, Text ),
   findall( Value, (member(_,Coords),getx(4,Value)), Values ) <~Info,
   winapi( (gdi32,'CreateRoundRectRgn'), Values, Region ),
   winapi( (gdi32,'PtInRegion'), [Region,X,Y], Hit ),
   winapi( (gdi32,'DeleteObject'), [Region], _ ),
   (  Hit = 0
   -> true
   ;  retract( known_hits(Hits) )
   -> More is Hits + 1,
      assert( known_hits(More) )
   ).

% create and select a brush with the given arguments - bds 30 oct 96

brsh( [], Device, [R,G,B,Style] ) :-
   RGB is ((B /\ 16'FF) << 16) \/ ((G /\ 16'FF) << 8) \/ (R /\ 16'FF),
   (  Style < 0
   -> Value is -1 - Style,
      winapi( (gdi32,'CreateHatchBrush'), [Value,RGB], Brush )
   ;  winapi( (gdi32,'CreateSolidBrush'), [RGB], Brush )
   ),
   winapi( (gdi32,'SelectObject'), [Device,Brush], _ ),
   (  retract( known_object(brush,Object) )
   -> winapi( (gdi32,'DeleteObject'), [Object], _ )
   ;  true
   ),
   assert( known_object(brush,Brush) ).

% test a brush with the given arguments - bds 30 oct 96

brsh( (X,Y), Device, [R,G,B,Style] ).

% draw an ellipse through the given arguments - bds 30 oct 96

elip( [], Device, Coords ) :-
   len( Coords, 4 ),
   winapi( (gdi32,'Ellipse'), [Device|Coords], _ ).

% test an ellipse through the given arguments - bds 30 oct 96

elip( (X,Y), Device, Coords ) :-
   len( Coords, 4 ),
   forall( member(Coord,Coords), putx(4,Coord) ) ~> Data,
   btext( [], -1, Text ),
   btext( [], -1, Data ),
   winapi( (gdi32,'LPtoDP'), [Device,[],2], _ ),
   btext( [], -1, Info ),
   btext( [], -1, Text ),
   findall( Value, (member(_,Coords),getx(4,Value)), Values ) <~Info,
   winapi( (gdi32,'CreateEllipticRgn'), Values, Region ),
   winapi( (gdi32,'PtInRegion'), [Region,X,Y], Hit ),
   winapi( (gdi32,'DeleteObject'), [Region], _ ),
   (  Hit = 0
   -> true
   ;  retract( known_hits(Hits) )
   -> More is Hits + 1,
      assert( known_hits(More) )
   ).

% draw a fill from the given arguments - bds 30 oct 96

fill( [], Device, [X1,Y1,R,G,B] ) :-
   RGB is ((B /\ 16'FF) << 16) \/ ((G /\ 16'FF) << 8) \/ (R /\ 16'FF),
   winapi( (gdi32,'FloodFill'), [Device,X1,Y1,RGB], _ ).

% test a fill from the given arguments - bds 30 oct 96

fill( (X,Y), Device, [X1,Y1,R,G,B] ).

% select a font with the given arguments - bds 30 oct 96

font( _, Device, [Font] ) :-
   fnthdl( Font, Handle ),
   winapi( (gdi32,'SelectObject'), [Device,Handle], _ ).

% select a foreground colour with the given arguments - bds 30 oct 96

fore( [], Device, [R,G,B] ) :-
   RGB is ((B /\ 16'FF) << 16) \/ ((G /\ 16'FF) << 8) \/ (R /\ 16'FF),
   winapi( (gdi32,'SetTextColor'), [Device,RGB], _ ).

% test a foreground colour with the given arguments - bds 30 oct 96

fore( (X,Y), Device, [R,G,B] ).

% draw an icon with the given arguments - bds 01 nov 96

icon( [], Device, [X1,Y1,Icon] ) :-
   icohdl( Icon, Handle ),
   winapi( (user32,'DrawIcon'), [Device,X1,Y1,Handle], _ ).

% test an icon with the given arguments - bds 01 nov 96

icon( (X,Y), Device, [X1,Y1,Icon] ) :-
   X2 is X1 + 32,
   Y2 is Y1 + 32,
   Coords = [X1,Y1,X2,Y2],
   forall( member(Coord,Coords), putx(4,Coord) ) ~> Data,
   btext( [], -1, Text ),
   btext( [], -1, Data ),
   winapi( (gdi32,'LPtoDP'), [Device,[],2], _ ),
   btext( [], -1, Info ),
   btext( [], -1, Text ),
   findall( Value, (member(_,Coords),getx(4,Value)), Values ) <~Info,
   winapi( (gdi32,'CreateRectRgn'), Values, Region ),
   winapi( (gdi32,'PtInRegion'), [Region,X,Y], Hit ),
   winapi( (gdi32,'DeleteObject'), [Region], _ ),
   (  Hit = 0
   -> true
   ;  retract( known_hits(Hits) )
   -> More is Hits + 1,
      assert( known_hits(More) )
   ).

% draw a polyline through the given arguments - bds 30 oct 96

line( [], Device, Coords ) :-
   len( Coords, Length ),
   Points is Length / 2,
   type( Points, 1 ),
   forall( member(Coord,Coords), putx(4,Coord) ) ~> Data,
   btext( [], -1, Text ),
   btext( [], -1, Data ),
   winapi( (gdi32,'Polyline'), [Device,[],Points], _ ),
   btext( [], -1, Text ).

% test a polyline through the given arguments - bds 30 oct 96

line( (X,Y), Device, Coords ).

% draw a metafile with the given arguments - bds 01 nov 96

meta( [], Device, [X1,Y1,X2,Y2,Meta] ) :-
   methdl( Meta, Handle ),
   winapi( (gdi32,'SaveDC'), [Device], _ ),
   Xd is X2 - X1,
   Yd is Y2 - Y1,
   btext( [], -1, Text ),
   btext( [], 16, `` ),
   winapi( (gdi32,'SetWindowOrgEx'), [Device,0,0,([],0)], _ ),
   winapi( (gdi32,'SetViewportOrgEx'), [Device,0,0,([],8)], _ ),
   btext( [], -1, Data ),
   (  getx( 4, Xw ),
      getx( 4, Yw ),
      getx( 4, Xv ),
      getx( 4, Yv )
   )  <~ Data,
   Xs is X1 + Xw,
   Ys is Y1 + Yw,
   (  putx( 4, Xs ),
      putx( 4, Ys ),
      putx( 4, Xd ),
      putx( 4, Yd )
   )  ~> More,
   btext( [], -1, More ),
   winapi( (gdi32,'LPtoDP'), [Device,[],2], _ ),
   btext( [], -1, Info ),
   btext( [], -1, Text ),
   (  getx( 4, Xx ),
      getx( 4, Yx ),
      getx( 4, Xe ),
      getx( 4, Ye )
   )  <~ Info,
   Xo is Xx + Xv,
   Yo is Yx + Yv,
   winapi( (gdi32,'SetViewportOrgEx'), [Device,Xo,Yo,0], _ ),
   winapi( (gdi32,'SetViewportExtEx'), [Device,Xe,Ye,0], _ ),
   winapi( (gdi32,'PlayMetaFile'), [Device,Handle], _ ),
   winapi( (gdi32,'RestoreDC'), [Device,-1], _ ).

% test a metafile with the given arguments - bds 01 nov 96

meta( (X,Y), Device, Coords ).

% select a drawing mode with the given arguments - bds 30 oct 96

mode( [], Device, [Mode] ) :-
   winapi( (gdi32,'SetROP2'), [Device,Mode], _ ).

% test a drawing mode with the given arguments - bds 30 oct 96

mode( (X,Y), Device, [Mode] ).

% set the origin with the given arguments - bds 30 oct 96

org( _, Device, [X1,Y1] ) :-
   X2 is -X1,
   Y2 is -Y1,
   winapi( (gdi32,'SetWindowOrgEx'), [Device,X2,Y2,0], _ ).

% create and select a pen with the given arguments - bds 30 oct 96

pen( [], Device, [R,G,B,Style] ) :-
   RGB is ((B /\ 16'FF) << 16) \/ ((G /\ 16'FF) << 8) \/ (R /\ 16'FF),
   (  Style < 0
   -> Value is - Style,
      winapi( (gdi32,'CreatePen'), [Value,0,RGB], Pen )
   ;  winapi( (gdi32,'CreatePen'), [0,Style,RGB], Pen )
   ),
   winapi( (gdi32,'SelectObject'), [Device,Pen], _ ),
   (  retract( known_object(pen,Object) )
   -> winapi( (gdi32,'DeleteObject'), [Object], _ )
   ;  true
   ),
   assert( known_object(pen,Pen) ).

% test a pen with the given arguments - bds 30 oct 96

pen( (X,Y), Device, [R,G,B,Style] ).

% draw a pie through the given arguments - bds 30 oct 96

pie( [], Device, Coords ) :-
   len( Coords, 8 ),
   winapi( (gdi32,'Pie'), [Device|Coords], _ ).

% test a pie through the given arguments - bds 30 oct 96

pie( (X,Y), Device, Coords ).

% draw a polygon through the given arguments - bds 30 oct 96

poly( [], Device, Coords ) :-
   len( Coords, Length ),
   Points is Length / 2,
   type( Points, 1 ),
   forall( member(Coord,Coords), putx(4,Coord) ) ~> Data,
   btext( [], -1, Text ),
   btext( [], -1, Data ),
   winapi( (gdi32,'Polygon'), [Device,[],Points], _ ),
   btext( [], -1, Text ).

% test a polygon through the given arguments - bds 30 oct 96

poly( (X,Y), Device, Coords ) :-
   len( Coords, Length ),
   Points is Length / 2,
   type( Points, 1 ),
   forall( member(Coord,Coords), putx(4,Coord) ) ~> Data,
   btext( [], -1, Text ),
   btext( [], -1, Data ),
   winapi( (gdi32,'LPtoDP'), [Device,[],Points], _ ),
   winapi( (gdi32,'CreatePolygonRgn'), [[],Points,1], Region ),
   btext( [], -1, Text ),
   winapi( (gdi32,'PtInRegion'), [Region,X,Y], Hit ),
   winapi( (gdi32,'DeleteObject'), [Region], _ ),
   (  Hit = 0
   -> true
   ;  retract( known_hits(Hits) )
   -> More is Hits + 1,
      assert( known_hits(More) )
   ).

% draw a rectangle through the given arguments - bds 30 oct 96

rect( [], Device, Coords ) :-
   len( Coords, 4 ),
   winapi( (gdi32,'Rectangle'), [Device|Coords], _ ).

% test a rectangle through the given arguments - bds 30 oct 96

rect( (X,Y), Device, Coords ) :-
   len( Coords, 4 ),
   forall( member(Coord,Coords), putx(4,Coord) ) ~> Data,
   btext( [], -1, Text ),
   btext( [], -1, Data ),
   winapi( (gdi32,'LPtoDP'), [Device,[],2], _ ),
   btext( [], -1, Info ),
   btext( [], -1, Text ),
   findall( Value, (member(_,Coords),getx(4,Value)), Values ) <~Info,
   winapi( (gdi32,'CreateRectRgn'), Values, Region ),
   winapi( (gdi32,'PtInRegion'), [Region,X,Y], Hit ),
   winapi( (gdi32,'DeleteObject'), [Region], _ ),
   (  Hit = 0
   -> true
   ;  retract( known_hits(Hits) )
   -> More is Hits + 1,
      assert( known_hits(More) )
   ).

% draw a segment through the given arguments - bds 30 oct 96

seg( [], Device, Coords ) :-
   len( Coords, 8 ),
   winapi( (gdi32,'Chord'), [Device|Coords], _ ).

% test a segment through the given arguments - bds 30 oct 96

seg( (X,Y), Device, Coords ).

% draw text at the given arguments - bds 30 oct 96

text( [], Device, [X1,Y1,String] ) :-
   type( String, 4 ),
   len( String, Length ),
   btext( [], -1, Text ),
   btext( [], -1, `` ),
   winapi( (gdi32,'TextOutA'), [Device,X1,Y1,String,Length], _ ),
   btext( [], -1, Text ).

% test text at the given arguments - bds 30 oct 96

text( (X,Y), Device, [X1,Y1,String] ) :-
   type( String, 4 ),
   len( String, Length ),
   btext( [], -1, Text ),
   btext( [], 8, `` ),
   winapi( (gdi32,'GetTextExtentPointA'), [Device,String,Length,[]], _ ),
   btext( [], -1, Size ),
   (  getx( 4, Width ),
      getx( 4, Depth )
   )  <~ Size,
   X2 is X1 + Width,
   Y2 is Y1 + Depth,
   Coords = [X1,Y1,X2,Y2],
   forall( member(Coord,Coords), putx(4,Coord) ) ~> Data,
   btext( [], -1, Data ),
   winapi( (gdi32,'LPtoDP'), [Device,[],2], _ ),
   btext( [], -1, Info ),
   btext( [], -1, Text ),
   findall( Value, (member(_,Coords),getx(4,Value)), Values ) <~Info,
   winapi( (gdi32,'CreateRectRgn'), Values, Region ),
   winapi( (gdi32,'PtInRegion'), [Region,X,Y], Hit ),
   winapi( (gdi32,'DeleteObject'), [Region], _ ),
   (  Hit = 0
   -> true
   ;  retract( known_hits(Hits) )
   -> More is Hits + 1,
      assert( known_hits(More) )
   ).

% select a transparency mode with the given arguments - bds 30 oct 96

trns( [], Device, [Trans] ) :-
   winapi( (gdi32,'SetBkMode'), [Device,Trans], _ ).

% test a transparency mode with the given arguments - bds 30 oct 96

trns( (X,Y), Device, [Trans] ).

% initialise the printer - bds 10 dec 96

wprnini( Document, Printer, Driver, Port ) :-
   (  type( Document, 3 ),
      type( Printer, 3 ),
      type( Driver, 3 ),
      type( Port, 3 )
   -> (  \+ known_printer( _, _, _, _, _, _, _, _, _ ),
         stratm( String1, Document ),
         stratm( String2, Printer ),
         stratm( String3, Driver ),
         stratm( String4, Port ),
         winapi( (gdi32,'CreateDCA'),[String3,String2,String4,0], Device ),
         Device \= 0
      -> assert( known_printer(Device,0,0,0,1,1,1,1,0) ),
         len( Document, Length ),
         Slot1 is 12,
         Slot2 is Slot1 + Length + 1,
         bdata( ([],Slot1), Address1, _ ),
         bdata( ([],Slot2), Address2, _ ),
         (  putx( 4, 12 ),
            putx( 4, Address1 ),
            putx( 4, Address2 )
         ) ~> Data,
         btext( [], -1, Text ),
         btext( [], -1, Data ),
         btext( ([],Slot1), 0, String1 ),
         btext( ([],Slot2), 0, String4 ),
         winapi( (gdi32,'StartDocA'), [Device,[]], Result ),
         btext( [], -1, Text ),
         (  member( Result, [0,-1] )
         -> dynamic( known_printer/9 ),
            winapi( (gdi32,'EndDoc'), [Device], _ ),
            throw( 10, wprnini(Document,Printer,Driver,Port) )
         ;  true
         )
      ;  throw( 10, wprnini(Document,Printer,Driver,Port) )
      )
   ;  (  type( Document, 0 )
      ;  type( Printer, 0 )
      ;  type( Driver, 0 )
      ;  type( Port, 0 )
      )
   -> throw( 22, wprnini(Document,Printer,Driver,Port) )
   ;  throw( 23, wprnini(Document,Printer,Driver,Port) )
   ).

% finish or abort a print job - bds 10 dec 96

wprnend( Code ) :-
   (  type( Code, 1 ),
      member( Code, [0,1] )
   -> (  known_printer( Device, _, _, _, _, _, _, _, Flg ),
         (  Code = 0
         -> (  Flg = 1
            -> winapi( (gdi32,'EndPage'), [Device], _ )
            ;  true
            ),
            winapi( (gdi32,'EndDoc'), [Device], _ )
         ;  winapi( (gdi32,'AbortDoc'), [Device], _ )
         ),
         winapi( (gdi32,'DeleteDC'), [Device], _ ),
         dynamic( known_printer/9 )
      ;  throw( 10, wprnend(Code) )
      )
   ;  type( Code, 0 )
   -> throw( 22, wprnend(Code) )
   ;  type( Code, 1 )
   -> throw( 24, wprnend(Code) )
   ;  throw( 23, wprnend(Code) )
   ).

% get or check the resolution of a print job - bds 10 dec 96

wprnres( Wid, Dep, Hor, Ver ) :-
   (  (  type( Wid, 0 )
      ;  type( Wid, 1 )
      ),
      (  type( Dep, 0 )
      ;  type( Dep, 1 )
      ),
      (  type( Hor, 0 )
      ;  type( Hor, 1 )
      ),
      (  type( Ver, 0 )
      ;  type( Ver, 1 )
      )
   -> (  known_printer( Device, _, _, _, _, _, _, _, _ ),
         winapi( (gdi32,'GetDeviceCaps'), [Device,08], Wid1 ),
         winapi( (gdi32,'GetDeviceCaps'), [Device,10], Dep1 ),
         winapi( (gdi32,'GetDeviceCaps'), [Device,88], Hor1 ),
         winapi( (gdi32,'GetDeviceCaps'), [Device,90], Ver1 ),
         Wid = Wid1,
         Dep = Dep1,
         Hor = Hor1,
         Ver = Ver1
      ;  throw( 10, wprnres(Wid,Dep,Hor,Ver) )
      )
   ;  throw( 23, wprnres(Wid,Dep,Hor,Ver) )
   ).

% set or get viewport in a print job - bds 10 dec 96

wprnorg( Xg, Yg ) :-
   (  (  type( Xg, 0 )
      ;  type( Xg, 1 )
      ),
      (  type( Yg, 0 )
      ;  type( Yg, 1 )
      )
   -> (  known_printer( Device, Pag, Xrg, Yrg, Xew, Yew, Xev, Yev, Flg ),
         Pag = 0
      -> (  type( Xg, 0 )
         -> Xg = Xrg,
            Xrg1 = Xrg
         ;  Xrg1 = Xg
         ),
         (  type( Yg, 0 )
         -> Yg = Yrg,
            Yrg1 = Yrg
         ;  Yrg1 = Yg
         ),
         dynamic( known_printer/9 ),
         assert( known_printer(Device,Pag,Xrg1,Yrg1,Xew,Yew,Xev,Yev,Flg) )
      ;  throw( 10, wprnorg(Xg,Yg) )
      )
   ;  throw( 23, wprnorg(Xg,Yg) )
   ).

% set or get mapping in a print job - bds 10 dec 96

wprnmap( Xw, Yw, Xv, Yv ) :-
   (  (  type( Xw, 0 )
      ;  type( Xw, 1 )
      ),
      (  type( Yw, 0 )
      ;  type( Yw, 1 )
      ),
      (  type( Xv, 0 )
      ;  type( Xv, 1 )
      ),
      (  type( Yv, 0 )
      ;  type( Yv, 1 )
      )
   -> (  known_printer( Device, Pag, Xrg, Yrg, Xew, Yew, Xev, Yev, Flg ),
         Pag = 0
      -> (  type( Xw, 0 )
         -> Xw = Xew,
            Xew1 = Xew
         ;  Xew1 = Xw
         ),
         (  type( Yw, 0 )
         -> Yw = Yew,
            Yew1 = Yew
         ;  Yew1 = Yw
         ),
         (  type( Xv, 0 )
         -> Xv = Xev,
            Xev1 = Xev
         ;  Xev1 = Xv
         ),
         (  type( Yv, 0 )
         -> Yv = Yev,
            Yev1 = Yev
         ;  Yev1 = Yv
         ),
         dynamic( known_printer/9 ),
         assert( known_printer(Device,Pag,Xrg,Yrg,Xew1,Yew1,Xev1,Yev1,Flg) )
      ;  throw( 10, wprnmap(Xw,Yw,Xv,Yv) )
      )
   ;  throw( 23, wprnmap(Xw,Yw,Xv,Yv) )
   ).

% start a new page in a print job - bds 10 dec 96

wprnpag( Page ) :-
   (  type( Page, 0 )
   -> (  known_printer( Device, Pag, Xrg, Yrg, Xew, Yew, Xev, Yev, Flg )
      -> (  (  Pag = 0
            ;  Flg = 1
            )
         -> Pag1 is Pag + 1,
            Flg1 is 0,
            dynamic( known_printer/9 ),
            assert( known_printer(Device,Pag1,Xrg,Yrg,Xew,Yew,Xev,Yev,Flg1) ),
            (  Pag \= 0
            -> winapi( (gdi32,'EndPage'), [Device], Result )
            ;  Result = 1
            )
         ;  Pag1 is Pag,
            Flg1 is Flg,
            Result = 1
         ),
         (  Result \= 1
         -> wprnend( 1 ),
            throw( 10, wprnpag(Page) )
         ;  true
         ),
         Page = Pag1
      ;  throw( 10, wprnpag(Page) )
      )
   ;  throw( 23, wprnpag(Page) )
   ).

% check status of a print job - bds 10 dec 96

wprnstt( Status ) :-
   (  (  type( Status, 0 )
      ;  type( Status, 1 )
      )
   -> (  known_printer( Device, Pag, _, _, _, _, _, _, Flg )
      -> (  Pag = 0
         -> Status = 1
         ;  Status is Flg + 2
         )
      ;  Status = 0
      )
   ;  throw( 23, wprnstt(Status) )
   ).

% perform unclipped graphics to a print job - bds 10 dec 96

wprngfx( Grafix ) :-
   (  set_printer( Device )
   -> forall( member(Pred(|Args),Grafix), Pred([],Device,Args) ),
      forall( retract( known_object(_,Object) ),
              winapi( (gdi32,'DeleteObject'), [Object], _ )
            )
   ;  throw( 10, wprngfx(Grafix) )
   ).

% perform clipped graphics to a print job - bds 10 dec 96

wprngfx( Grafix, L, T, R, B ) :-
   (  set_printer( Device )
   -> winapi( (gdi32,'CreateRectRgn'), [L,T,R,B], Region ),
      winapi( (gdi32,'SelectClipRgn'), [Device,Region], _ ),
      winapi( (gdi32,'DeleteObject'), [Region], _ ),
      forall( member(Pred(|Args),Grafix), Pred([],Device,Args) ),
      forall( retract( known_object(_,Object) ),
              winapi( (gdi32,'DeleteObject'), [Object], _ )
            )
   ;  throw( 10, wprngfx(Grafix,L,T,R,B) )
   ).

% set up mapping for the printer device context - bds 10 dec 96

set_printer( Device ) :-
   known_printer( Device, Pag, Xrg, Yrg, Xew, Yew, Xev, Yev, Flg ),
   Pag \= 0,
   (  Flg = 0
   -> winapi( (gdi32,'StartPage'), [Device], Result ),
      Result = 1,
      Flg1 is 1,
      dynamic( known_printer/9 ),
      assert( known_printer(Device,Pag,Xrg,Yrg,Xew,Yew,Xev,Yev,Flg1) )
   ;  true
   ),
   winapi( (gdi32,'SetMapMode'), [Device,8], _ ),
   winapi( (gdi32,'SetViewportOrgEx'), [Device,Xrg,Yrg,0], _ ),
   winapi( (gdi32,'SetWindowExtEx'), [Device,Xew,Yew,0], _ ),
   winapi( (gdi32,'SetViewportExtEx'), [Device,Xev,Yev,0], _ ).

% open a bitmap - bds 12 dec 96

wbopen( Bitmap, Name ) :-
   (  type( Bitmap, 3 ),
      type( Name, 3 )
   -> (  known_bitmap( Bitmap, _ )
      -> wbclose( Bitmap )
      ;  true
      ),
      wndhdl( -1, Instance ),
      stratm( String, Name ),
      winapi( (user32,'LoadBitmapA'), [Instance,String], Data ),
      assert( known_bitmap(Bitmap,Data) )
   ;  (  type( Bitmap, 0 )
      ;  type( Name, 0 )
      )
   -> throw( 22, wbopen(Bitmap,Name) )
   ;  throw( 23, wbopen(Bitmap,Name) )
   ).

% load a bitmap - bds 12 dec 96

wbload( Bitmap, File ) :-
   (  type( Bitmap, 3 ),
      type( File, 3 )
   -> (  known_bitmap( Bitmap, _ )
      -> wbclose( Bitmap )
      ;  true
      ),
      fopen( File, File, 0 ),
      input( Input ),
      input( File ),
      fread( s, 2, 0, Type ),
      getx( 4, Size ),
      input( Input ),
      fclose( File ),
      BfSize is Size - 14,
      (  Type = `BM`
      -> bcreate( bitmap, BfSize ),
         fopen( File, File, 0 ),
         input( File ),
         inpos( 14 ),
         repeat,
         inpos( Position ),
         copy( 16384, Count ) ~> String,
         Offset is Position - 14,
         btext( (bitmap,Offset), Count, String ),
         Count < 16384,
         input( Input ),
         fclose( File ),
         !,
         btext( (bitmap,0), 4, Data0 ),
         getx( 4, BiSize ) <~ Data0,
         (  (  BiSize < 12
            ;  BiSize > 12,
               BiSize < 18
            )
         -> bclose( bitmap ),
            throw( 10, wbload(Bitmap,File) )
         ;  (  BiSize = 12
            -> btext( (bitmap,10), 4, Data1 ),
               getx( 4, BcBits ) <~ Data1,
               (  BcBits \= 24
               -> Colour is ( 1 << BcBits ) * 3
               ;  Colour is 0
               )
            ;  btext( (bitmap,14), 2, Data2 ),
               getx( 2, BiBits ) <~ Data2,
               btext( (bitmap,32), 4, Data3 ),
               getx( 4, BiUsed ) <~ Data3,
               (  BiSize >= 36
               -> Temp is BiUsed * 4
               ;  Temp is 0
               ),
               (  Temp = 0,
                  BiBits \= 24
               -> Colour is ( 1 << BiBits ) * 4
               ;  Colour = Temp
               )
            )
         ),
         Bits is BiSize + Colour,
         winapi( (user32,'GetDC'), [0], Device ),
         winapi( (gdi32,'CreateDIBitmap'),
                 [Device,bitmap,4,(bitmap,Bits),bitmap,0],
                 Data
               ),
         winapi( (user32,'ReleaseDC'), [0,Device], _ ),
         bclose( bitmap ),
         assert( known_bitmap(Bitmap,Data) )
      ;  throw( 10, wbload(Bitmap,File) )
      )
   ;  (  type( Bitmap, 0 )
      ;  type( File, 0 )
      )
   -> throw( 22, wbload(Bitmap,File) )
   ;  throw( 23, wbload(Bitmap,File) )
   ).

% close an bitmap - bds 12 dec 96

wbclose( Bitmap ) :-
   (  type( Bitmap, 3 )
   -> (  retract( known_bitmap(Bitmap,Data) )
      -> winapi( (gdi32,'DeleteObject'), [Data], _ )
      )
   ;  type( Bitmap, 0 )
   -> throw( 22, wbclose(Bitmap) )
   ;  throw( 23, wbclose(Bitmap) )
   ).

% return a dictionary of bitmap names - bds 12 dec 96

wbdict( Bitmaps ) :-
   findall( Bitmap, known_bitmap(Bitmap,_), Bitmaps ).

% open an icon - bds 31 oct 96

wiopen( Icon, Name ) :-
   (  type( Icon, 3 ),
      type( Name, 3 )
   -> (  known_icon( Icon, _ )
      -> wiclose( Icon )
      ;  true
      ),
      wndhdl( -1, Instance ),
      stratm( String, Name ),
      winapi( (user32,'LoadIconA'), [Instance,String], Data ),
      assert( known_icon(Icon,Data) )
   ;  (  type( Icon, 0 )
      ;  type( Name, 0 )
      )
   -> throw( 22, wiopen(Icon,Name) )
   ;  throw( 23, wiopen(Icon,Name) )
   ).

% load an icon - bds 31 oct 96

wiload( Icon, File, Index ) :-
   (  type( Icon, 3 ),
      type( File, 3 ),
      type( Index, 1 )
   -> (  known_icon( Icon, _ )
      -> wiclose( Icon )
      ;  true
      ),
      wndhdl( -1, Instance ),
      stratm( String, File ),
      winapi( (shell32,'ExtractIconA'), [Instance,String,Index], Data ),
      assert( known_icon(Icon,Data) )
   ;  (  type( Icon, 0 )
      ;  type( File, 0 )
      ;  type( Index, 0 )
      )
   -> throw( 22, wiload(Icon,File,Index) )
   ;  throw( 23, wiload(Icon,File,Index) )
   ).

% close an icon - bds 31 oct 96

wiclose( Icon ) :-
   (  type( Icon, 3 )
   -> (  retract( known_icon(Icon,Data) )
      -> winapi( (user32,'DestroyIcon'), [Data], _ )
      )
   ;  type( Icon, 0 )
   -> throw( 22, wiclose(Icon) )
   ;  throw( 23, wiclose(Icon) )
   ).

% return a dictionary of icon names - bds 31 oct 96

widict( Icons ) :-
   findall( Icon, known_icon(Icon,_), Icons ).

% create a metafile - bds 11 dec 96

wxcreate( Meta, Grafix, L, T, R, B ) :-
   (  type( Meta, 3 ),
      type( L, 1 ),
      type( T, 1 ),
      type( R, 1 ),
      type( B, 1 )
   -> (  known_metafile( Meta, _ )
      -> wxclose( Meta )
      ;  true
      ),
      winapi( (gdi32,'CreateMetaFileA'), [0], Device ),
      winapi( (gdi32,'SetMapMode'), [Device,8], _ ),
      winapi( (gdi32,'SetWindowOrgEx'), [Device,L,T,0], _ ),
      winapi( (gdi32,'SetWindowExtEx'), [Device,R,B,0], _ ),
      forall( member(Pred(|Args),Grafix), Pred([],Device,Args) ),
      winapi( (gdi32,'CloseMetaFile'), [Device], Data ),
      assert( known_metafile(Meta,Data) )
   ;  (  type( Meta, 0 )
      ;  type( L, 0 )
      ;  type( T, 0 )
      ;  type( R, 0 )
      ;  type( B, 0 )
      )
   -> throw( 22, wxcreate(Meta,Grafix,L,T,R,B) )
   ;  throw( 23, wxcreate(Meta,Grafix,L,T,R,B) )
   ).

% load a metafile - bds 31 oct 96

wxload( Meta, File ) :-
   (  type( Meta, 3 ),
      type( File, 3 )
   -> (  known_metafile( Meta, _ )
      -> wxclose( Meta )
      ;  true
      ),
      stratm( String, File ),
      winapi( (gdi32,'GetMetaFileA'), [String], Data ),
      assert( known_metafile(Meta,Data) )
   ;  (  type( Meta, 0 )
      ;  type( File, 0 )
      )
   -> throw( 22, wxload(Meta,File) )
   ;  throw( 23, wxload(Meta,File) )
   ).

% save a metafile - bds 31 oct 96

wxsave( Meta, File ) :-
   (  type( Meta, 3 ),
      type( File, 3 )
   -> methdl( Meta, Data ),
      stratm( String, File ),
      winapi( (gdi32,'CopyMetaFileA'), [Data,String], Info ),
      (  Info = 0
      -> throw( 10, wxsave(Meta,File) )
      ;  winapi( (gdi32,'DeleteMetaFile'), [Info], _ )
      )
   ;  (  type( Meta, 0 )
      ;  type( File, 0 )
      )
   -> throw( 22, wxsave(Meta,File) )
   ;  throw( 23, wxsave(Meta,File) )
   ).

% close a metafile - bds 31 oct 96

wxclose( Meta ) :-
   (  type( Meta, 3 )
   -> (  retract( known_metafile(Meta,Data) )
      -> winapi( (gdi32,'DeleteMetaFile'), [Data], _ )
      )
   ;  type( Meta, 0 )
   -> throw( 22, wxclose(Meta) )
   ;  throw( 23, wxclose(Meta) )
   ).

% return a dictionary of meta names - bds 31 oct 96

wxdict( Metas ) :-
   findall( Meta, known_metafile(Meta,_), Metas ).

% convert between an bitmap descriptor and its data handle - bds 12 dec 96

bithdl( Bitmap, Data ) :-
   (  type( Bitmap, 0 ),
      type( Data, 1 )
   -> (  known_bitmap( Bitmap, Data )
      -> true
      ;  Bitmap = bitmap(Data)
      )
   ;  type( Bitmap, 3 )
   -> known_bitmap( Bitmap, Data )
   ;  Bitmap = bitmap(Data),
      type( Data, 1 )
   -> true
   ;  type( Bitmap, 0 ),
      type( Data, 0 )
   -> throw( 22, bithdl(Bitmap,Data) )
   ;  throw( 23, bithdl(Bitmap,Data) )
   ).

% convert between a cursor descriptor and its data handle - bds 31 oct 96

curhdl( Cursor, Data ) :-
   (  type( Cursor, 0 ),
      type( Data, 1 )
   -> (  member( Cursor, [0,1,2,3,4,5,6,7,8,9,10,11,12] ),
         curhdl( Cursor, Test ),
         Test = Data
      -> true
      ;  known_cursor( Cursor, Data )
      -> true
      ;  Cursor = cursor(Data)
      )
   ;  member( (Cursor,Stock), [(0,32512),
                               (1,32514),
                               (2,32512),
                               (3,32513),
                               (4,32514),
                               (5,32515),
                               (6,32516),
                               (7,32640),
                               (8,32641),
                               (9,32642),
                               (10,32643),
                               (11,32644),
                               (12,32645)
                              ]
            )
   -> winapi( (user32,'LoadCursorA'), [0,Stock], Data )
   ;  type( Cursor, 3 )
   -> known_cursor( Cursor, Data )
   ;  Cursor = cursor(Data),
      type( Data, 1 )
   -> true
   ;  type( Cursor, 0 ),
      type( Data, 0 )
   -> throw( 22, curhdl(Cursor,Data) )
   ;  throw( 23, curhdl(Cursor,Data) )
   ).

% convert between an icon descriptor and its data handle - bds 31 oct 96

icohdl( Icon, Data ) :-
   (  type( Icon, 0 ),
      type( Data, 1 )
   -> (  member( Icon, [0,1,2,3,4,5,6] ),
         icohdl( Icon, Test ),
         Test = Data
      -> true
      ;  known_icon( Icon, Data )
      -> true
      ;  Icon = icon(Data)
      )
   ;  member( (Icon,Stock), [(0,32512),
                             (1,32514),
                             (2,32512),
                             (3,32513),
                             (4,32514),
                             (5,32515),
                             (6,32516)
                            ]
            )
   -> winapi( (user32,'LoadIconA'), [0,Stock], Data )
   ;  type( Icon, 3 )
   -> known_icon( Icon, Data )
   ;  Icon = icon(Data),
      type( Data, 1 )
   -> true
   ;  type( Icon, 0 ),
      type( Data, 0 )
   -> throw( 22, icohdl(Icon,Data) )
   ;  throw( 23, icohdl(Icon,Data) )
   ).

% convert between a metafile descriptor and its data handle - bds 31 oct 96

methdl( Meta, Data ) :-
   (  type( Meta, 0 ),
      type( Data, 1 )
   -> (  known_metafile( Meta, Data )
      -> true
      ;  Meta = meta(Data)
      )
   ;  type( Meta, 3 )
   -> known_metafile( Meta, Data )
   ;  Meta = meta(Data),
      type( Data, 1 )
   -> true
   ;  type( Meta, 0 ),
      type( Data, 0 )
   -> throw( 22, methdl(Meta,Data) )
   ;  throw( 23, methdl(Meta,Data) )
   ).
