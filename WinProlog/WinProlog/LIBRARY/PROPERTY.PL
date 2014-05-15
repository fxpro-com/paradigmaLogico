/*
   A module to implement the MacProlog-style property management
   -------------------------------------------------------------

   set_prop  / 3   Set the property of a symbol to a value
   get_prop  / 3   Get the value of a property of a symbol
   get_props / 2   Get a list of the properties of a symbol
   del_prop  / 2   delete a property of a symbol
   del_props / 1   delete all properties of a symbol
*/

:- module( library_property,
           [
             set_prop  / 3,
             get_prop  / 3,
             get_props / 2,
             del_prop  / 2,
             del_props / 1
           ]
         ).

:- initialization  hide( '$SYMBOL$' ).

% Set the property of a symbol to a value

set_prop( Symbol, Property, Value ) :-
   set_prop2( Symbol, Property, PropName ),
   PropHead =.. [PropName,Property,Value],
   addcls( [PropHead], 1 ).

set_prop2( Symbol, Property, PropName ) :-
   def( '$SYMBOL$', 3, _ ),
   SymbHead = '$SYMBOL$'(Symbol,_,_),
   idxcls( [SymbHead|_], 0, SymbIndex ),
   !,
   getcls( [SymbHead,PropCall], SymbIndex ),
   functor( PropCall, PropName, 2 ),
   PropHead =.. [PropName,Property,_],
   (  idxcls( [PropHead], 0, PropIndex )
   -> delcls( [PropHead], PropIndex )
   ;  true
   ).

set_prop2( Symbol, _, PropName ) :-
   stratm( `$PROPERTY$`, PropName ),
   hide( PropName ),
   SymbHead = '$SYMBOL$'(Symbol,Prop,Val),
   PropCall =.. [PropName,Prop,Val],
   addcls( [SymbHead,PropCall], 1 ).

% Get the value of a symbols associated property

get_prop( Symbol, Property, Value ) :-
   def( '$SYMBOL$', 3, _ ),
   '$SYMBOL$'( Symbol, Property, Value ).

% Get a list of the properties of a symbol

get_props( Symbol, Properties ) :-
   def( '$SYMBOL$', 3, _ ),
   SymbHead = '$SYMBOL$'(Symbol,_,_),
   idxcls( [SymbHead|_], 0, SymbIndex ),
   !,
   getcls( [SymbHead,PropCall], SymbIndex ),
   functor( PropCall, PropName, 2 ),
   get_props2( PropName, 1, Properties ).

get_props( _, [] ).

get_props2( PropName, Index, [Property|Properties] ) :-
   PropHead =.. [PropName,Property,_],
   getcls( [PropHead], Index ),
   !,
   NextIndex is Index + 1,
   get_props2( PropName, NextIndex, Properties ).

get_props2( _, _, [] ).

% Delete a property of a symbol

del_prop( Symbol, Property ) :-
   def( '$SYMBOL$', 3, _ ),
   SymbHead = '$SYMBOL$'(Symbol,_,_),
   idxcls( [SymbHead|_], 0, SymbIndex ),
   getcls( [SymbHead,PropCall], SymbIndex ),
   functor( PropCall, PropName, 2 ),
   PropHead =.. [PropName,Property,_],
   idxcls( [PropHead], 0, PropIndex ),
   !,
   delcls( [PropHead], PropIndex ),
   (  def( PropName, 2, 1 )
   -> true
   ;  delcls( [SymbHead|_], SymbIndex )
   ).

del_prop( _, _ ).

% Delete all properties of a symbol

del_props( Symbol ) :-
   def( '$SYMBOL$', 3, _ ),
   SymbHead = '$SYMBOL$'(Symbol,_,_),
   idxcls( [SymbHead|_], 0, SymbIndex ),
   !,
   getcls( [SymbHead,PropCall], SymbIndex ),
   functor( PropCall, PropName, 2 ),
   delprd( PropName, 2 ),
   delcls( [SymbHead|_], SymbIndex ).

del_props( _ ).
