/*
   Modal Dialog Utility - 02 May 96 - Alan Westwood and Brian D Steel
   ------------------------------------------------------------------

   The call_dialog/2 predicate calls a modal dialog, and returns both the
   button pressed and a list of controls and their values.
*/

% call a dialog, returning its button and control values

call_dialog( Dialog, Result, Data ) :-
  call_dialog( Dialog, Result ),
  ctrl_data( Dialog, Data ).

% return the values of appropriate controls for a dialog

ctrl_data( Dialog, Data ) :-
   wlink( Dialog, 5, Child ),
   ctrl_link( Child, Children ),
   ctrl_values( Children, Data ).

% link the siblings of a given window

ctrl_link( Child, [(Class,Child)|Children] ) :-
   ctrl_class( Child, Class ),
   (  wlink(Child, 2, Sibling )
   -> ctrl_link( Sibling, Children )
   ;  Children = []
   ).

% find the class type of a given control

ctrl_class( Control, Class ) :-
  wclass( Control, Cls ),
  ctrl_type( Cls, Control, Class ).

% given a control class and a controls style find its type

ctrl_type( 'Button', Control, Type ) :-
   !,
   wstyle( Control, Style ),
   Value is Style /\ 15,
   ctrl_button( Value, Type ).

ctrl_type( Class, _, Type ) :-
   lwrupr( Type, Class ).

% given a button style, return its type

ctrl_button(  0, pushbutton ).
ctrl_button(  1, pushbutton ).
ctrl_button(  2, checkbox   ).
ctrl_button(  3, checkbox   ).
ctrl_button(  4, radio      ).
ctrl_button(  5, tristate   ).
ctrl_button(  6, tristate   ).
ctrl_button(  7, groupbox   ).
ctrl_button(  9, radio      ).
ctrl_button( 11, ownerdraw  ).

% return the contents for appropriate controls in the given list

ctrl_values( [], [] ).

ctrl_values( [(Type,Control)|Controls], [(Control,Value)|Values] ) :-
   ctrl_value( Type, Control, Value ),
   !,
   ctrl_values( Controls, Values ).

ctrl_values( [_|Controls], Values ) :-
   ctrl_values( Controls, Values ).

% find the value of a given control

ctrl_value( checkbox, Control, Value ) :-
   wbtnsel( Control, Value ).

ctrl_value( radio, Control, Value ) :-
   wbtnsel( Control, Value ).

ctrl_value( tristate, Control, Value ) :-
   wbtnsel( Control, Value ).

ctrl_value( listbox, Control, Value ) :-
   ctrl_listbox( Control, 0, Value ).

ctrl_value( combobox, Control, Value ) :-
   ctrl_listbox( Control, 0, Value ).

ctrl_value( edit, Control, Value ) :-
   wtext( Control, Value ).

% get all selected items from a listbox or a combobox

ctrl_listbox( Control, Posn, Strings1 ) :-
  wlbxget( Control, Posn, String ),
  wlbxsel( Control, Posn, Sel ),
  (  Sel = 1
  -> Strings1 = [String|Strings2]
  ;  Sel = 0
  -> Strings1 = Strings2
  ),
  NextPosn is Posn + 1,
  !,
  ctrl_listbox( Control, NextPosn, Strings2 ).

ctrl_listbox( _, _, [] ).
