/*
   A program that counts the variables in a structure
   --------------------------------------------------

   count_variables/2    finds the number of occurences of each variable
                        in a given structure.
*/

:- module( library_varcount,
           [
             count_variables / 2
           ]
         ).

% find the number of occurences of each variable in a given structure

% returns a list of ... '$VAR'(Name,Variable,Count) triplets

count_variables( Structure, Vars ) :-
   vars( Structure, VarNames ),
   VarNames \= [],
   !,
   set_to_zero( VarNames, Vars0 ),
   count_vars( Structure, Vars0, Vars ).

count_variables( _, [] ).

% Initialise the "counter" list

set_to_zero( [], [] ).

set_to_zero( [(Name,Var)|VarNames], ['$VAR'(Name,Var,0)|Vars0] ) :-
   set_to_zero( VarNames, Vars0 ).

% If it is a variable, then increment its count

count_vars( Var, Vars1, Vars2 ) :-
   var( Var ),
   !,
   increment_var( Vars1, Vars2, Var ).

count_vars( [Term|Terms], Vars1, Vars3 ) :-
   !,
   count_vars( Term,  Vars1, Vars2 ),
   count_vars( Terms, Vars2, Vars3 ).

count_vars( Structure, Vars1, Vars3 ) :-
   Structure =.. [_,Term|Terms],
   !,
   count_vars( Term,  Vars1, Vars2 ),
   count_vars( Terms, Vars2, Vars3 ).

count_vars( _, Vars, Vars ).

% Increment the count for a given variable

increment_var( ['$VAR'(Name,Variable,Count1)|Vars1],
               ['$VAR'(Name,Variable,Count2)|Vars2],
               Var
             ) :-
   (  Var == Variable
   -> Count2 is Count1 + 1,
      Vars1 = Vars2
   ;  Count2 = Count1,
      increment_var( Vars1, Vars2, Var )
   ).
