/*
    An emulation for the Quintus Prolog format/2 predicate
    -------------------------------------------------------

    Note that this emulation uses the ª character (ASCII 170)
    as an escape instead of the ~ character (ASCII 126) which
    is used at a lower level to denote DOS control characters.

    The formats supported by this emulation are:
	ªc
	ªe
	ªE
	ªf
	ªg
	ªG
	ªd
	ªD
	ªr
	ªR
	ªs
	ªn
	ª|
	ª+
	ªt

    Please refer to Quintus Prolog documentation for the
    details of how to use format/2.
*/

format( Ctrl, Output ) :-
   type( Ctrl, Type ),
   fmt_control( Type, Ctrl, Ctrls ),
   (  type( Output, 6 )
   -> Outputs = Output
   ;  Outputs = [Output] ),
   fmt_newline( Ctrls, Outputs ),
   !.

format( Ctrl, Output ) :-
   throw( 24, format(Ctrl,Output) ).

% check the control characters

fmt_control( 3, Ctrl, Ctrls ) :-
   atmbyt( Ctrl, Ctrls ).

fmt_control( 4, Ctrl, Ctrls ) :-
   strbyt( Ctrl, Ctrls ).

fmt_control( 6, Ctrls, Ctrls ) :-
   catch( 0, strbyt( _, Ctrls ) ),
   !.

% recursive format procedure

fmt_newline( Ctrls, Output ) :-
   fmt_line( Ctrls, Output, 1, 0, 32 ).

fmt_line( [], _, _, _, _ ).

fmt_line( [Ctrl1|Ctrls1], Output, LinePosn, NextTab, FillTab ) :-
   (  Ctrl1 = 170
   -> fmt_tilde_count( Ctrls1, Ctrls2, Ctrl2, N ),
      fmt_tilde( Ctrl2, N, Ctrls2, Output, LinePosn, NextTab, FillTab )
   ;  putx( 1, Ctrl1 ),
      NextPosn is LinePosn + 1,
      fmt_line( Ctrls1, Output, NextPosn, NextTab, FillTab ) ).

% is there <n> before the control character ?

fmt_tilde_count( [Ctrl1,Ctrl2|Ctrls1], Ctrls2, Ctrl3, N2 ) :-
   cmp(  1, Ctrl1, 47 ),
   cmp( -1, Ctrl1, 58 ),
   !,
   N1 is Ctrl1 - 48,
   fmt_tilde_count( Ctrls1, Ctrls2, Ctrl2, Ctrl3, N1, N2 ).

fmt_tilde_count( [Ctrl|Ctrls], Ctrls, Ctrl, N ) :-
   fmt_tilde_count( Ctrl, N ),
   !.

fmt_tilde_count( [Ctrl|Ctrls], Ctrls, Ctrl, -1 ).

fmt_tilde_count( [Ctrl2|Ctrls1], Ctrls2, Ctrl1, Ctrl3, N1, N3 ) :-
   cmp(  1, Ctrl1, 47 ),
   cmp( -1, Ctrl1, 58 ),
   !,
   rpn( [10,N1,*,Ctrl1,48,-,+], N2 ),
   fmt_tilde_count( Ctrls1, Ctrls2, Ctrl2, Ctrl3, N2, N3 ).

fmt_tilde_count( Ctrls, Ctrls, Ctrl, Ctrl, N, N ).

fmt_tilde_count( 099,  1 ).   % ªc
fmt_tilde_count( 101,  6 ).   % ªe
fmt_tilde_count( 069,  6 ).   % ªE
fmt_tilde_count( 102,  6 ).   % ªf
fmt_tilde_count( 103,  6 ).   % ªg
fmt_tilde_count( 071,  6 ).   % ªG
fmt_tilde_count( 100,  0 ).   % ªd
fmt_tilde_count( 068,  0 ).   % ªD
fmt_tilde_count( 114,  8 ).   % ªr
fmt_tilde_count( 082,  8 ).   % ªR
fmt_tilde_count( 115,  0 ).   % ªs
fmt_tilde_count( 110,  1 ).   % ªn
fmt_tilde_count( 124,  0 ).   % ª|
fmt_tilde_count( 043,  8 ).   % ª+
fmt_tilde_count( 116, 32 ).   % ªt

% user supplied counter
% ª*

fmt_tilde( 042, -1, Ctrls, [N,Ctrl|Output], LinePosn, NextTab, FillTab ) :-
   fmt_tilde( Ctrl, N, Ctrls, Output, LinePosn, NextTab, FillTab ).

% atom
% ªa

fmt_tilde( 097, -1, Ctrls, [Atom|Output], LinePosn, NextTab, FillTab ) :-
   atom( Atom ),
   len( Atom, Size ),
   ewrite( Atom ),
   NextPosn is LinePosn + Size,
   fmt_line( Ctrls, Output, NextPosn, NextTab, FillTab ).

% character
% ª<n>c

fmt_tilde( 099, N, Ctrls, [Char|Output], LinePosn, NextTab, FillTab ) :-
   char( Char ),
   repeat( N, putx(1,Char) ),
   NextPosn is LinePosn + N,
   fmt_line( Ctrls, Output, NextPosn, NextTab, FillTab ).

% exponential number
% ª<n>e

fmt_tilde( 101, N, Ctrls, [Number|Output], LinePosn, NextTab, FillTab ) :-
   fmt_tilde_exponential( Number, N, `e`, String, Size ),
   ewrite( String ),
   NextPosn is LinePosn + Size,
   fmt_line( Ctrls, Output, NextPosn, NextTab, FillTab ).

% ª<n>E

fmt_tilde( 069, N, Ctrls, [Number|Output], LinePosn, NextTab, FillTab ) :-
   fmt_tilde_exponential( Number, N, `E`, String, Size ),
   ewrite( String ),
   NextPosn is LinePosn + Size,
   fmt_line( Ctrls, Output, NextPosn, NextTab, FillTab ).

fmt_tilde_exponential( Number, Precision, E, String, Size ) :-
   number( Number ),
   fmt_tilde_exponent( Number, AbsFloat, ExpSign, Exp ),
   Digit is ip( AbsFloat ),
   Fraction is ip((AbsFloat - Digit) * (10 ^ Precision)),
   output( Home ),
   output( (``,0) ),
   (  cmp( -1, Number, 0 )
   -> ewrite( `-` )
   ;  true ),
   ewrite( Digit ),
   ewrite( `.` ),
   ewrite( Fraction ),
   ewrite( E ),
   ewrite( ExpSign ),
   fwrite( r, 2, -10, Exp ),
   output( Data ),
   output( Home ),
   Data = (String, Size).

fmt_tilde_exponent( Number, AbsFloat, ExpSign, Exp ) :-
   AbsNumber is abs(Number),
   (  cmp( -1, AbsNumber, 1 )
   -> ExpSign = `-`,
      fmt_tilde_neg_exponent( AbsNumber, AbsFloat, 0, Exp )
   ;  ExpSign = `+`,
      fmt_tilde_pos_exponent( AbsNumber, AbsFloat, 0, Exp ) ).

fmt_tilde_pos_exponent( Number, Float, Exp1, Exp3 ) :-
   (  cmp( -1, Number, 10 )
   -> Number = Float,
      Exp1 = Exp3
   ;  Number10 is Number / 10,
      Exp2 is Exp1 + 1,
      fmt_tilde_pos_exponent( Number10, Float, Exp2, Exp3 ) ).

fmt_tilde_neg_exponent( Number, Float, Exp1, Exp3 ) :-
   (  cmp( -1, Number, 1 )
   -> Number10 is Number * 10,
      Exp2 is Exp1 + 1,
      fmt_tilde_neg_exponent( Number10, Float, Exp2, Exp3 )
   ;  Number = Float,
      Exp1 = Exp3 ).

% fixed-point number
% ª<n>f

fmt_tilde( 102, N, Ctrls, [Number|Output], LinePosn, NextTab, FillTab ) :-
   fmt_tilde_fixed_point( Number, N, String, Size ),
   ewrite( String ),
   NextPosn is LinePosn + Size,
   fmt_line( Ctrls, Output, NextPosn, NextTab, FillTab ).

fmt_tilde_fixed_point( Number, Precision, String, Size ) :-
   AbsNumber is abs(Number),
   IntegerPart is ip(AbsNumber),
   output( Home ),
   output( (``,0) ),
   ewrite( IntegerPart ),
   (  Precision = 0
   -> true
   ;  DecimalPart is ip((AbsNumber-IntegerPart) * (10^Precision)),
      ewrite( `.` ),
      fwrite( r, Precision, -10, DecimalPart ) ),
   output( Data ),
   output( Home ),
   Data = (String, Size).

%  precision number
% ª<n>g

fmt_tilde( 103, N, Ctrls, [Number|Output], LinePosn, NextTab, FillTab ) :-
   fmt_tilde_precision( Number, N, `e`, String, Size ),
   ewrite( String ),
   NextPosn is LinePosn + Size,
   fmt_line( Ctrls, Output, NextPosn, NextTab, FillTab ).

% ª<n>G

fmt_tilde( 071, N, Ctrls, [Number|Output], LinePosn, NextTab, FillTab ) :-
   fmt_tilde_precision( Number, N, `E`, String, Size ),
   ewrite( String ),
   NextPosn is LinePosn + Size,
   fmt_line( Ctrls, Output, NextPosn, NextTab, FillTab ).

fmt_tilde_precision( Number, N, E, String, Size ) :-
   fmt_tilde_exponential( Number, N, E, String1, Size1 ),
   fmt_tilde_fixed_point( Number, N, String2, Size2 ),
   (  cmp( -1, Size2, Size1 )
   -> (String,Size) = (String2,Size2)
   ;  (String,Size) = (String1,Size1) ).

% decimal integer
% ª<n>d

fmt_tilde( 100, N, Ctrls, [Integer|Output], LinePosn, NextTab, FillTab ) :-
   (  N = 0
   -> number_string( Integer, String )
   ;  Float is Integer / (10^N),
      output( Home ),
      output( (``,0) ),
      fwrite( f, 0, N, Float ),
      output( Data ),
      output( Home ),
      Data = (String, Size)
   ),
   type( Integer, 1 ),
   ewrite( String ),
   len( String, Size ),
   NextPosn is LinePosn + Size,
   fmt_line( Ctrls, Output, NextPosn, NextTab, FillTab ).

% ª<n>D

fmt_tilde( 068, N, Ctrls, [Integer|Output], LinePosn, NextTab, FillTab ) :-
   (  N = 0
   -> Float = Integer
   ;  Float is Integer / (10^N) ),
   number_chars( Float, Chars1 ),
   fmt_tilde_thousands( Chars1, Chars2 ),
   fwrite( b, 0, 0, Chars2 ),
   len( Chars2, Size ),
   NextPosn is LinePosn + Size,
   fmt_line( Ctrls, Output, NextPosn, NextTab, FillTab ).

fmt_tilde_thousands( [45|Chars1], [45|Chars2] ) :-
   !,
   fmt_tilde_thousands( Chars1, Chars2 ).

fmt_tilde_thousands( Chars1, Chars4 ) :-
   fmt_tilde_decimal( Chars1, [], Chars2, Chars3 ),
   fmt_tilde_thousands( Chars2, Chars3, Chars4 ).

fmt_tilde_thousands( [Char3,Char2,Char1,Char0|RevFront], Back, Chars ) :-
   !,
   fmt_tilde_thousands( [Char0|RevFront], [44,Char1,Char2,Char3|Back], Chars ).

fmt_tilde_thousands( RevFront, Back, Chars ) :-
   reverse( RevFront, Back, Chars ).

fmt_tilde_decimal( [], RevFront, RevFront, [] ).

fmt_tilde_decimal( [46|Back], RevFront, RevFront, [46|Back] ) :-
   !.

fmt_tilde_decimal( [Char|Chars], RevFront1, RevFront2, Back ) :-
   fmt_tilde_decimal( Chars, [Char|RevFront1], RevFront2, Back ).

% radix integer
% ª<n>r

fmt_tilde( 114, N, Ctrls, [Integer|Output], LinePosn, NextTab, FillTab ) :-
   fmt_tilde_radix( Integer, N, lower, Size ),
   NextPosn is LinePosn + Size,
   fmt_line( Ctrls, Output, NextPosn, NextTab, FillTab ).

% ª<n>R

fmt_tilde( 082, N, Ctrls, [Integer|Output], LinePosn, NextTab, FillTab ) :-
   fmt_tilde_radix( Integer, N, upper, Size ),
   NextPosn is LinePosn + Size,
   fmt_line( Ctrls, Output, NextPosn, NextTab, FillTab ).

fmt_tilde_radix( Integer, Radix, _, Size ) :-
   output( Home ),
   output( (``,0) ),
   fwrite( r, 0, Radix, Integer ),
   output( Data ),
   output( Home ),
   Data = (String, Size),
   ewrite( String ).

% characters
% ª<n>s

fmt_tilde( 115, N, Ctrls, [Chars|Output], LinePosn, NextTab, FillTab ) :-
   chars( Chars ),
   len( Chars, Len ),
   (  N = 0
   -> Size = Len
   ;  Len < N
   -> Size = Len
   ;  Size = N ),
   len( Dummy, Size ),
   fmt_tilde_chars( Dummy, Chars ),
   NextPosn is LinePosn + Size,
   fmt_line( Ctrls, Output, NextPosn, NextTab, FillTab ).

fmt_tilde_chars( [], _ ).

fmt_tilde_chars( [_|Dummy], [Char|Chars] ) :-
   putx( 1, Char ),
   fmt_tilde_chars( Dummy, Chars ).

% ignore
% ªi

fmt_tilde( 105, 0, Ctrls, Output, LinePosn, NextTab, FillTab ) :-
   fmt_line( Ctrls, Output, LinePosn, NextTab, FillTab ).

% canonical term
% ªk

fmt_tilde( 107, 0, Ctrls, [Term|Output], LinePosn, NextTab, FillTab ) :-
   output( Home ),
   output( (``,0) ),
   write_canonical( Term ),
   output( Data ),
   output( Home ),
   Data = (String, Size),
   ewrite( String ),
   NextPosn is LinePosn + Size,
   fmt_line( Ctrls, Output, NextPosn, NextTab, FillTab ).

% print term
% ªp

fmt_tilde( 112, 0, Ctrls, [Term|Output], LinePosn, NextTab, FillTab ) :-
   output( Home ),
   output( (``,0) ),
   print( Term ),
   output( Data ),
   output( Home ),
   Data = (String, Size),
   ewrite( String ),
   NextPosn is LinePosn + Size,
   fmt_line( Ctrls, Output, NextPosn, NextTab, FillTab ).

% quoted term
% ªq

fmt_tilde( 113, 0, Ctrls, [Term|Output], LinePosn, NextTab, FillTab ) :-
   output( Home ),
   output( (``,0) ),
   writeq( Term ),
   output( Data ),
   output( Home ),
   Data = (String, Size),
   ewrite( String ),
   NextPosn is LinePosn + Size,
   fmt_line( Ctrls, Output, NextPosn, NextTab, FillTab ).

% unquoted term
% ªw

fmt_tilde( 119, 0, Ctrls, [Term|Output], LinePosn, NextTab, FillTab ) :-
   output( Home ),
   output( (``,0) ),
   write( Term ),
   output( Data ),
   output( Home ),
   Data = (String, Size),
   ewrite( String ),
   NextPosn is LinePosn + Size,
   fmt_line( Ctrls, Output, NextPosn, NextTab, FillTab ).

% newline
% ª<n>n

fmt_tilde( 110, N, Ctrls, Output, _, _, _ ) :-
   repeat( N, nl ),
   fmt_newline( Ctrls, Output ).

% conditional newline
% ªN

fmt_tilde( 078, 0, Ctrls, Output, LinePosn, _, _ ) :-
   (  LinePosn = 0
   -> true
   ;  nl ),
   fmt_newline( Ctrls, Output ).

% set tab
% ª<n>|

fmt_tilde( 124, N, Ctrls, Output, LinePosn, _, FillTab ) :-
   Size is (N-LinePosn) * sign(sign(N-LinePosn)+1),
   repeat( Size, putx(1,FillTab) ),
   NextPosn is LinePosn + Size,
   fmt_line( Ctrls, Output, NextPosn, N, FillTab ).

% tab
% ª<n>+

fmt_tilde( 043, N, Ctrls, Output, LinePosn, LastTab, FillTab ) :-
   NextTab is LastTab + N,
   fmt_tilde( 124, NextTab, Ctrls, Output, LinePosn, LastTab, FillTab ).

% fill tab
% ª<n>t

fmt_tilde( 116, N, Ctrls, Output, LinePosn, NextTab, _ ) :-
   cmp( -1, N, 127 ),
   fmt_line( Ctrls, Output, LinePosn, NextTab, N ).
