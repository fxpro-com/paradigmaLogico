/*
** Read or Write Switch Values - Brian D Steel - 15 Aug 95 / 19 Mar 97
** -------------------------------------------------------------------
**
** This file can be used to read and write permanent settings for the
** default values of the 26 command line switches in WIN-PROLOG, by
** accessing the internal switch table. You can changes these settings
** as often as you like, by simply rerunning this program. The call:
**
**     ?- get_switch(h,X).
**
** returns the current default setting of the /H (heap space) switch;
** similarly, the call:
**
**     ?- set_switch(p,4000).
**
** sets a default value of 4000 for the /P (program space) switch, which
** will be used next time you run WIN-PROLOG.
**
** Note that command line switches always override the internal
** settings, so if you set a value which prevents Prolog from loading
** (such as too much program space), you can override this on the
** command line. For example, if the /P switch was set to 4000, but you
** do not have enough memory, you can run WIN-PROLOG with the command:
**
**     C> WIN PRO386W /P2000
**
** which overrides the /P4000 permanent setting, and once it is running,
** change the permanent setting to something smaller. If you want to
** reset switches to their default states, set their values back to -1.
*/

% read the named switch from prolog .EXE file

get_switch( Switch, Value ) :-
  type( Value, 0 ),
  prolog_offset( Switch, Prolog, Offset ),
  fopen( Prolog, Prolog, 0 ),
  input( Stream ),
  input( Prolog ),
  inpos( Offset ),
  getx( 4, Value ),
  input( Stream ),
  fclose( Prolog ).

% write the named switch into the prolog .EXE file

set_switch( Switch, Value ) :-
  type( Value, 1 ),
  prolog_offset( Switch, Prolog, Offset ),
  fopen( Prolog, Prolog, 2 ),
  output( Stream ),
  output( Prolog ),
  outpos( Offset ),
  putx( 4, Value ),
  output( Stream ),
  fclose( Prolog ).

% compute the prolog .EXE file location and switch offset

prolog_offset( Switch, Prolog, Offset ) :-
  env( '', Files ),
  Files = [File],
  fname( File, Path, Name, _ ),
  cat( [Path,Name,'.EXE'], Prolog, _ ),
  atmbyt( Switch, List ),
  (  List >= "A",
     List =< "Z"
  -> Value is (List - 64) * 4 - 4
  ;  List >= "a",
     List =< "z"
  -> Value is (List - 96) * 4 - 4
  ),
  fopen( Prolog, Prolog, 0 ),
  input( Stream ),
  input( Prolog ),
  find( `~098~100~115~001` ),
  inpos( Base ),
  input( Stream ),
  fclose( Prolog ),
  Offset is Base + Value.
