/*
   A set of utilities to implement various list/combo box handling predicates
   --------------------------------------------------------------------------

   wlbxadd/2    Add a list of strings to a list/combo box
   wlbxsub/1    Remove all strings from a list/combo box
   wlbxsub/2    Remove a single string from a list/combo box
   wlbxset/2    Select a string in a list/combo box
   wlbxget/2    Get the selection in a single-choice list/combo box
   wlbxgets/2   Get a list of selections in a multiple-choice list/combo box
   wlbxnext/1   Move selection to next entry in single-choice list/combo box
*/

% add a list of strings to a list/combo box

wlbxadd( Window, String ) :-
   string( String ),
   !,
   wlbxadd( Window, -1, String ).

wlbxadd( Window, Strings ) :-
   wlbxsub( Window ),
   forall( member( String, Strings ),
           wlbxadd( Window, -1, String )
         ).

% remove all strings from a list/combo box

wlbxsub( Window ) :-
   \+ wlbxdel( Window, 0 ),
   !.

wlbxsub( Window ) :-
   wlbxsub( Window ).

% remove a single string from a list/combo box

wlbxsub( Window, String ) :-
   wlbxfnd( Window, -1, String, Posn ),
   wlbxdel( Window, Posn ).

% select a string in a list/combo box

wlbxset( Window, String ) :-
   wlbxfnd( Window, -1, String, Posn ),
   wlbxsel( Window, Posn, 1 ).

% get the selection in a single-choice list/combo box

wlbxget( Window, String ) :-
   wlbxget1( Window, 0, String ).

wlbxget1( Window, Posn, Selected ) :-
   wlbxget( Window, Posn, String ),
   wlbxsel( Window, Posn, Sel ),
   (  Sel = 1
   -> Selected = String
   ;  Sel = 0
   -> NextPosn is Posn + 1,
      wlbxget1( Window, NextPosn, Selected )
   ).

% get the list of selections in a multiple-choice list/combo box

wlbxgets( Window, Strings ) :-
   wlbxgets( Window, 0, Strings ).

wlbxgets( Window, Posn, Strings1 ) :-
   wlbxget( Window, Posn, String ),
   wlbxsel( Window, Posn, Sel ),
   (  Sel = 1
   -> Strings1 = [String|Strings2]
   ;  Sel = 0
   -> Strings1 = Strings2 ),
   NextPosn is Posn + 1,
   !,
   wlbxgets( Window, NextPosn, Strings2 ).

wlbxgets( _, _, [] ).

% move selection to next entry in single-choice list/combo box

wlbxnext( Window ) :-
   wlbxnext( Window, 0 ).

wlbxnext( Window, Posn ) :-
   Next is Posn + 1,
   wlbxget( Window, Next, _   ),
   wlbxsel( Window, Posn, Sel ),
   (  Sel = 1
   -> wlbxsel( Window, Next, 1 )
   ;  wlbxnext( Window, Next )
   ).
