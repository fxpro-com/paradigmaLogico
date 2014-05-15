/*
   Module that implements a keyed balanced AVL tree library
   --------------------------------------------------------

   exports the following predicates:

   ktree_insert  / 4,    % Insert a term into an avl tree according to key
   ktree_delete  / 4,    % Delete a term from an avl tree according to key
   ktree_replace / 6,    % Replace a term with a new term according to key
   ktree_find    / 3,    % Deterministic find according to given key
   ktree_member  / 3,    % Non-deterministic tree membership
   ktree_to_list / 2,    % Convert an avl tree into a list of pairs
   ktree_to_list / 3,    % Convert an avl tree into a difference list
   list_to_ktree / 2     % Convert a list of pairs into an avl tree
*/

:- module( library_ktree,
           [
              ktree_insert  / 4,
              ktree_delete  / 4,
              ktree_replace / 6,
              ktree_find    / 3,
              ktree_member  / 3,
              ktree_to_list / 2,
              ktree_to_list / 3,
              list_to_ktree / 2
           ]
         ).

:- index( (kt_insert_left /6),  [1,2,3] ).
:- index( (kt_insert_right/6),  [1,2,3] ).
:- index( (kt_promote/5),       [1,2,3] ).
:- index( (kt_delete_left /6),  [1,2,3] ).
:- index( (kt_delete_right/6),  [1,2,3] ).
:- index( (kt_replace_left /6), [1,2,3] ).
:- index( (kt_replace_right/6), [1,2,3] ).

% Insert a term into an avl tree according to key

ktree_insert( InTree, OutTree, Key, Term ) :-
   kt_insert( InTree, OutTree, Key, Term, _ ).

kt_insert( [], t([],Key,Term,0,[]), Key, Term, 1 ).

kt_insert( t(Left,NKey,NTerm,NBal,Right), Tree, Key, Term, Inc ) :-
   compare( Rel, Key, NKey ),
   kt_insert( Rel, Left, NKey, NTerm, NBal, Right, Tree, Key, Term, Inc ).

kt_insert( (<), Left1, NKey, NTerm, NBal1, Right, Tree, Key, Term, Inc ) :-
   kt_insert( Left1, Left2, Key, Term, SubInc ),
   kt_insert_left( SubInc, Inc, NBal1, NBal2,
                   t(Left2,NKey,NTerm,NBal2,Right),
                   Tree
                 ).

kt_insert( (>), Left, NKey, NTerm, NBal1, Right1, Tree, Key, Term, Inc ) :-
   kt_insert( Right1, Right2, Key, Term, SubInc ),
   kt_insert_right( SubInc, Inc, NBal1, NBal2,
                    t(Left,NKey,NTerm,NBal2,Right2),
                    Tree
                  ).

kt_insert_left(  0,  0, Bal, Bal, Tree, Tree ).

kt_insert_left(  1,  0,   1,   0, Tree, Tree ) :-
   !.

kt_insert_left(  1,  1,   0,  -1, Tree, Tree ) :-
   !.

% LL = left sub-tree's left sub-sub-tree
% LK = left sub-tree's key
% LT = left sub-tree's term
% LR = left sub-tree's right sub-sub-tree
% NK = node's key
% NT = node's term
% R  = right sub-tree

kt_insert_left( 1,  0, -1,  0,
                t(t(LL,LK,LT,-1,LR),NK,NT,_,R),
                t(LL,LK,LT,0,t(LR,NK,NT,0,R))
              ) :-
   !.

% LL  = left sub-tree's left sub-sub-tree
% LK  = left sub-tree's key
% LT  = left sub-tree's term
% LRL = left sub-tree's right sub-sub-tree's left  sub-sub-sub-tree
% LRK = left sub-tree's right sub-sub-tree's key
% LRT = left sub-tree's right sub-sub-tree's term
% LRB = left sub-tree's right sub-sub-tree's term balancedness
% LRR = left sub-tree's right sub-sub-tree's right sub-sub-sub-tree
% NK  = node's key
% NT  = node's term
% LB  = balancedness of new left  sub-tree
% RB  = balancedness of new right sub-tree

kt_insert_left( 1,  0, -1,  0,
                t(t(LL,LK,LT,1,t(LRL,LRK,LRT,LRB,LRR)),NK,NT,_,R),
                t(t(LL,LK,LT,LB,LRL),LRK,LRT,0,t(LRR,NK,NT,RB,R))
              ) :-
   ( LRB =  0
   -> LB =  0,
      RB =  0
   ; LRB = -1
   -> LB =  1,
      RB =  0
   ; LRB =  1
   -> LB =  0,
      RB = -1
   ).

kt_insert_right( 0,  0, Bal, Bal, Tree, Tree ).

kt_insert_right( 1,  0,  -1,   0, Tree, Tree ) :-
   !.

kt_insert_right( 1,  1,   0,   1, Tree, Tree ) :-
   !.

% L  = left sub-tree
% NK = node's key
% NT = node's term
% RL = right sub-tree's left sub-sub-tree
% RK = right sub-tree's key
% RT = right sub-tree's term
% RR = right sub-tree's right sub-sub-tree

kt_insert_right( 1,  0,  1,  0,
                 t(L,NK,NT,_,t(RL,RK,RT,1,RR)),
                 t(t(L,NK,NT,0,RL),RK,RT,0,RR)
               ) :-
   !.

% NK  = node's key
% NT  = node's term
% RLL = right sub-tree's left sub-sub-tree's left  sub-sub-sub-tree
% RLK = right sub-tree's left sub-sub-tree's key
% RLT = right sub-tree's left sub-sub-tree's term
% RLB = right sub-tree's left sub-sub-tree's term balancedness
% RLR = right sub-tree's left sub-sub-tree's right sub-sub-sub-tree
% RK  = right sub-tree's key
% RT  = right sub-tree's term
% RR  = right sub-tree's right sub-sub-tree
% LB  = balancedness of new left  sub-tree
% RB  = balancedness of new right sub-tree

kt_insert_right( 1,  0,  1,  0,
                 t(L,NK,NT,_,t(t(RLL,RLK,RLT,RLB,RLR),RK,RT,-1,RR)),
                 t(t(L,NK,NT,LB,RLL),RLK,RLT,0,t(RLR,RK,RT,RB,RR))
               ) :-
   ( RLB =  0
   -> LB =  0,
      RB =  0
   ; RLB = -1
   -> LB =  0,
      RB =  1
   ; RLB =  1
   -> LB = -1,
      RB =  0
   ).

% Delete a term from an avl tree according to key .

ktree_delete( InTree, OutTree, Key, Term ) :-
   kt_delete( InTree, OutTree, Key, Term, _ ).

kt_delete( t(Left,NKey,NTerm,NBal,Right), Tree, Key, Term, Dec ) :-
   compare( Rel, Key, NKey ),
   kt_delete( Rel, Left, NKey, NTerm, NBal, Right, Tree, Key, Term, Dec ).

kt_delete( (=), Left, Key, Term, NBal, Right, Tree, Key, Term, Dec ) :-
   kt_promote( NBal, Left, Right, Tree, Dec ).

kt_delete( (<), Left1, NKey, NTerm, NBal1, Right, Tree, Key, Term, Dec ) :-
   kt_delete( Left1, Left2, Key, Term, SubDec ),
   kt_delete_left( SubDec, Dec, NBal1, NBal2,
                  t(Left2,NKey,NTerm,NBal2,Right),
                  Tree
                 ).

kt_delete( (>), Left, NKey, NTerm, NBal1, Right1, Tree, Key, Term, Dec ) :-
   kt_delete( Right1, Right2, Term, Key, SubDec ),
   kt_delete_right( SubDec, Dec, NBal1, NBal2,
                    t(Left,NKey,NTerm,NBal2,Right2),
                    Tree
                  ).

% no promotion required for deletion of a leaf or near-leaf

kt_promote(  0,   [],    [],    [], 1 ) :-
   !.

kt_promote( -1, Left,    [],  Left, 1 ) :-
   !.

kt_promote(  1,   [], Right, Right, 1 ) :-
   !.

% promotion required for deletion of an interior node

kt_promote(  0, Left, Right1, t(Left,PKey,PTerm,PBal,Right2), Dec ) :-
   kt_promote_left( Right1, Right2, PKey, PTerm, Dec ),
   PBal is 0 - Dec.

kt_promote(  1, Left, Right1, t(Left,PKey,PTerm,PBal,Right2), Dec ) :-
   kt_promote_left( Right1, Right2, PKey, PTerm, Dec ),
   PBal is 1 - Dec.

kt_promote( -1, Left1, Right, t(Left2,PKey,PTerm,PBal,Right), Dec ) :-
   kt_promote_right( Left1, Left2, PKey, PTerm, Dec ),
   PBal is Dec - 1.

% found promoted leaf

kt_promote_left(  t([],PKey,PTerm,_,Right), Right, PKey, PTerm, 1 ) :-
   !.

% not the promoted leaf

kt_promote_left( t(Left1,NKey,NTerm,NBal1,Right), Tree, PKey, PTerm, Dec ) :-
   kt_promote_left( Left1, Left2, PKey, PTerm, Sub ),
   kt_delete_left( Sub, Dec, NBal1, NBal2,
                  t(Left2,NKey,NTerm,NBal2,Right),
                  Tree
                ).

kt_promote_right( t(Left,PKey,PTerm,_,[]),  Left,  PKey, PTerm, 1 ) :-
   !.

kt_promote_right( t(Left,NKey,NTerm,NBal1,Right1), Tree, PKey, PTerm, Dec ) :-
   kt_promote_right( Right1, Right2, PKey, PTerm, Sub ),
   kt_delete_right( Sub, Dec, NBal1, NBal2,
                    t(Left,NKey,NTerm,NBal2,Right2),
                    Tree
                  ).

kt_delete_left(  0,  0, Bal, Bal, Tree, Tree ).

kt_delete_left(  1,  0,   0,   1, Tree, Tree ) :-
   !.

kt_delete_left(  1,  1,  -1,   0, Tree, Tree ) :-
   !.

% single toggle required

% L  = left sub-tree
% NK = node's key
% NT = node's term
% RL = right sub-tree's left sub-tree
% RK = right sub-tree's key
% RT = right sub-tree's term
% RR = right sub-tree's right sub-tree

kt_delete_left( 1,  1,  1,  0,
                t(L,NK,NT,_,t(RL,RK,RT,1,RR)),
                t(t(L,NK,NT,0,RL),RK,RT,0,RR)
              ) :-
   !.

kt_delete_left( 1,  0,  1, -1,
                t(L,NK,NT,_,t(RL,RK,RT,0,RR)),
                t(t(L,NK,NT,1,RL),RK,RT,-1,RR)
              ) :-
   !.

% L   = left sub-tree
% NK  = node's key
% NT  = node's term
% RLL = right sub-tree's left sub-sub-tree's left sub-sub-sub-tree
% RLK = right sub-tree's left sub-sub-tree's key
% RLT = right sub-tree's left sub-sub-tree's term
% RLB = right sub-tree's left sub-sub-tree's balancedness
% RLR = right sub-tree's left sub-sub-tree's right sub-sub-sub-tree
% RK  = right sub-tree's key
% RT  = right sub-tree's term
% RR  = right sub-tree's right sub-sub-tree
% LB  = balancedness of new left  sub-tree
% RB  = balancedness of new right sub-tree

kt_delete_left( 1,  0,  1,  0,
                t(L,NK,NT,_,t(t(RLL,RLK,RLT,RLB,RLR),RK,RT,-1,RR)),
                t(t(L,NK,NT,LB,RLL),RLK,RLT,0,t(RLR,RK,RT,RB,RR))
              ) :-
   ( RLB =  0
   -> LB =  0,
      RB =  0
   ; RLB = -1
   -> LB =  0,
      RB =  1
   ; RLB =  1
   -> LB = -1,
      RB =  0
   ).

kt_delete_right( 0,  0, Bal, Bal, Tree, Tree ).

kt_delete_right( 1,  0,   0,  -1, Tree, Tree ) :-
   !.

kt_delete_right( 1,  1,   1,   0, Tree, Tree ) :-
   !.

% LL = left sub-tree's left sub-tree
% LK = left sub-tree's key
% LT = left sub-tree's term
% LR = left sub-tree's right sub-tree
% NK = node's key
% NT = node's term
% R  = right sub-tree

kt_delete_right( 1,  1, -1,  0,
                 t(t(LL,LK,LT,-1,LR),NK,NT,_,R),
                 t(LL,LK,LT,0,t(LR,NK,NT,0,R))
               ) :-
   !.

kt_delete_right( 1,  0, -1,  1,
                 t(t(LL,LK,LT,0,LR),NK,NT,_,R),
                 t(LL,LK,LT,1,t(LR,NK,NT,-1,R))
               ) :-
   !.

% LL  = left sub-tree's left sub-tree
% LK  = left sub-tree's key
% LT  = left sub-tree's term
% LRL = left sub-tree's right sub-sub-tree's left sub-sub-sub-tree
% LRK = left sub-tree's right sub-sub-tree's key
% LRT = left sub-tree's right sub-sub-tree's term
% LRB = left sub-tree's right sub-sub-tree's balancedness
% LRR = left sub-tree's right sub-sub-tree's right sub-sub-sub-tree
% NK  = node's key
% NT  = node's term
% R   = right sub-tree
% LB  = balancedness of new left  sub-tree
% RB  = balancedness of new right sub-tree

kt_delete_right( 1,  0, -1,  0,
                 t(t(LL,LK,LT,1,t(LRL,LRK,LRT,LRB,LRR)),NK,NT,_,R),
                 t(t(LL,LK,LT,LB,LRL),LRK,LRT,0,t(LRR,NK,NT,RB,R))
               ) :-
   ( LRB =  0
   -> LB =  0,
      RB =  0
   ; LRB = -1
   -> LB =  0,
      RB =  1
   ; LRB =  1
   -> LB = -1,
      RB =  0
   ).

% Replace a term with a new term according to key

ktree_replace( InTree, OutTree, Key, InTerm, OutTerm, Flag ) :-
   kt_replace( InTree, OutTree, Key, InTerm, OutTerm, Flag, _ ).

kt_replace( [], t([],Key,Term,0,[]), Key, _, Term, inserted, 1 ).

kt_replace( t(Left,NKey,NTerm,NBal,Right), Tree, Key, Term1, Term2, Flag, Inc ) :-
   compare( Rel, Key, NKey ),
   kt_replace( Rel, Left, NKey, NTerm, NBal, Right, Tree, Key, Term1, Term2, Flag, Inc ).

kt_replace( (=),
            Left,
            Key,
            Term1,
            Bal,
            Right,
            Tree,
            Key,
            Term1,
            Term2,
            replaced,
            0
          ) :-
   Tree = t(Left,Key,Term2,Bal,Right).

kt_replace( (<),
            Left1,
            NKey,
            NTerm,
            NBal1,
            Right,
            Tree,
            Key,
            Term1,
            Term2,
            Flag,
            Inc
          ) :-
   kt_replace( Left1, Left2, Key, Term1, Term2, Flag, SubInc ),
   kt_replace_left( SubInc, Inc, NBal1, NBal2,
                    t(Left2,NKey,NTerm,NBal2,Right),
                    Tree
                  ).

kt_replace( (>),
            Left,
            NKey,
            NTerm,
            NBal1,
            Right1,
            Tree,
            Key,
            Term1,
            Term2,
            Flag,
            Inc
          ) :-
   kt_replace( Right1, Right2, Key, Term1, Term2, Flag, SubInc ),
   kt_replace_right( SubInc, Inc, NBal1, NBal2,
                     t(Left,NKey,NTerm,NBal2,Right2),
                     Tree
                   ).

kt_replace_left(  0,  0,  B,  B, Tree, Tree ).

kt_replace_left(  1,  0,  1,  0, Tree, Tree ) :-
   !.

kt_replace_left(  1,  1,  0, -1, Tree, Tree ) :-
   !.

% single toggle required

% LL = left sub-tree's left sub-sub-tree
% LK = left sub-tree's key
% LT = left sub-tree's term
% LR = left sub-tree's right sub-sub-tree
% NK = node's key
% NT = node's term
% R  = right sub-tree

kt_replace_left( 1,  0, -1,  0,
                 t(t(LL,LK,LT,-1,LR),NK,NT,_,R),
                 t(LL,LK,LT,0,t(LR,NK,NT,0,R))
               ) :-
   !.

% LL  = left sub-tree's left sub-sub-tree
% LK  = left sub-tree's key
% LT  = left sub-tree's term
% LRL = left sub-tree's right sub-sub-tree's left  sub-sub-sub-tree
% LRK = left sub-tree's right sub-sub-tree's key
% LRT = left sub-tree's right sub-sub-tree's term
% LRB = left sub-tree's right sub-sub-tree's term balancedness
% LRR = left sub-tree's right sub-sub-tree's right sub-sub-sub-tree
% NK  = node's key
% NT  = node's term
% LB  = balancedness of new left  sub-tree
% RB  = balancedness of new right sub-tree

kt_replace_left( 1,  0, -1,  0,
                 t(t(LL,LK,LT,1,t(LRL,LRK,LRT,LRB,LRR)),NK,NT,_,R),
                 t(t(LL,LK,LT,LB,LRL),LRK,LRT,0,t(LRR,NK,NT,RB,R))
               ) :-
   ( LRB =  0
   -> LB =  0,
      RB =  0
   ; LRB = -1
   -> LB =  1,
      RB =  0
   ; LRB =  1
   -> LB =  0,
      RB = -1
   ).

kt_replace_right( 0,  0,  B,  B, Tree, Tree ).

kt_replace_right( 1,  0, -1,  0, Tree, Tree ) :-
   !.

kt_replace_right( 1,  1,  0,  1, Tree, Tree ) :-
   !.

% L  = left sub-tree
% NK = node's key
% NT = node's term
% RL = right sub-tree's left sub-sub-tree
% RK = right sub-tree's key
% RT = right sub-tree's term
% RR = right sub-tree's right sub-sub-tree

kt_replace_right( 1,  0,  1,  0,
                  t(L,NK,NT,_,t(RL,RK,RT,1,RR)),
                  t(t(L,NK,NT,0,RL),RK,RT,0,RR)
                ) :-
   !.

% NK  = node's key
% NT  = node's term
% RLL = right sub-tree's left sub-sub-tree's left  sub-sub-sub-tree
% RLK = right sub-tree's left sub-sub-tree's key
% RLT = right sub-tree's left sub-sub-tree's term
% RLB = right sub-tree's left sub-sub-tree's term balancedness
% RLR = right sub-tree's left sub-sub-tree's right sub-sub-sub-tree
% RK  = right sub-tree's key
% RT  = right sub-tree's term
% RR  = right sub-tree's right sub-sub-tree
% LB  = balancedness of new left  sub-tree
% RB  = balancedness of new right sub-tree

kt_replace_right( 1,  0,  1,  0,
                  t(L,NK,NT,_,t(t(RLL,RLK,RLT,RLB,RLR),RK,RT,-1,RR)),
                  t(t(L,NK,NT,LB,RLL),RLK,RLT,0,t(RLR,RK,RT,RB,RR))
                ) :-
   ( RLB =  0
   -> LB =  0,
      RB =  0
   ; RLB = -1
   -> LB =  0,
      RB =  1
   ; RLB =  1
   -> LB = -1,
      RB =  0
   ).

% Deterministic find according to given key

ktree_find( Key, Term, t(Left,NKey,NTerm,_,Right) ) :-
   compare( Rel, Key, NKey ),
   kt_find( Rel, Key, Term, Left, NTerm, Right ).

kt_find( (=), _, Term, _, Term, _ ).

kt_find( (<), Key, Term, t(LLeft,LKey,LTerm,_,LRight), _, _ ) :-
   compare( Rel, Key, LKey ),
   kt_find( Rel, Key, Term, LLeft, LTerm, LRight ).

kt_find( (>), Key, Term, _, _, t(RLeft,RKey,RTerm,_,RRight) ) :-
   compare( Rel, Key, RKey ),
   kt_find( Rel, Key, Term, RLeft, RTerm, RRight ).

% Non-deterministic tree membership

ktree_member( Key, Term, t(Left,NKey,NTerm,_,Right) ) :-
   (  ktree_member( Key, Term, Left )
   ;  (Key-Term) = (NKey-NTerm)
   ;  ktree_member( Key, Term, Right )
   ).

% Convert an avl tree into a list of pairs

ktree_to_list( Tree, List ) :-
   ktree_to_list( Tree, List, [] ).

ktree_to_list( [], List, List ).

% Convert an avl tree into a difference list

ktree_to_list( t(Left,Key,Term,_,Right), List1, List3 ) :-
   ktree_to_list( Left, List1, [(Key,Term)|List2] ),
   ktree_to_list( Right, List2, List3 ).

% Convert a list of pairs into an avl tree

list_to_ktree( List, Tree ) :-
   list_to_kt( List, [], Tree ).

list_to_kt( [], Tree, Tree ).

list_to_kt( [(Key,Term)|List], Tree1, Tree3 ) :-
   kt_insert( Tree1, Tree2, Key, Term, _ ),
   list_to_kt( List, Tree2, Tree3 ).
