/*
    An emulation for Quintus Prolog stream input and output predicates
    ------------------------------------------------------------------

    The following predicates are emulated:

	read/2,
        write/2,
        writeq/2,
        write_canonical/2,
        at_end_of_file/1,
        at_end_of_line/1,
        get0/2,
        get/2,
        skip/2,
        skip_line/1,
        put/2,
        tab/2,
        nl/1

    Please refer to Quintus Prolog documentation for the
    details of how to use the stream I/O predicates.
*/

read( Stream, Term ):-
   read( Term )   <~ Stream.

write( Stream, Term ):-
   write( Term )  ~> Stream.

writeq( Stream, Term ):-
   writeq( Term ) ~> Stream.

write_canonical( Stream, Term ):-
   write_canonical( Term ) ~> Stream.

at_end_of_file( Stream ):-
   at_end_of_file <~ Stream.

at_end_of_line( Stream ):-
   at_end_of_line <~ Stream.

get0( Stream, Byte ):-
   get0( Byte )   <~ Stream.

get( Stream, Byte ):-
   get( Byte )    <~ Stream.

skip( Stream, Byte ):-
   skip( Byte )   <~ Stream.

skip_line( Stream ):-
   skip_line      <~ Stream.

put( Stream, Byte ):-
   put( Byte )    ~> Stream.

tab( Stream, N ):-
   tab( N )       ~> Stream.

nl( Stream ):-
   nl             ~> Stream.
