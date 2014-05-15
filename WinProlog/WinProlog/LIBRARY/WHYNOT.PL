/*
    A non-unification analyser - (c) Logic Programming Associates - 04 Apr 96
    -------------------------------------------------------------------------

    The why_not_unify/3 predicate gives a report on why two terms
    fail to unify.
*/

% if either term is a variable, the terms would unify, so cut and fail

why_not_unify( Variable1, Variable2, WhyNot ):-
   (  var( Variable1 )
   ;  var( Variable2 )
   ),
   !,
   fail.

% see if both terms have the same functor/arity, and then check their arguments

why_not_unify( Function1, Function2, WhyNot ) :-
   functor( Function1, Functor, Arity ),
   functor( Function2, Functor, Arity ),
   !,
   Function1 =.. [Functor|Arguments1],
   Function2 =.. [Functor|Arguments2],
   why_not_unifies( Arguments1, Arguments2, WhyNot ).

% if the functor/arity of the terms are not identical, then they cannot unify

why_not_unify( Term1, Term2, (Term1 \= Term2) ).

% if the first arguments are the same then check the remaining elements

why_not_unifies( [Argument|Arguments1], [Argument|Arguments2], WhyNot ) :-
   !,
   why_not_unifies( Arguments1, Arguments2, WhyNot ).

% if the first arguments are not the same then check why they are not the same

why_not_unifies( [Argument1|_], [Argument2|_], WhyNot ) :-
   why_not_unify( Argument1, Argument2, WhyNot ).
