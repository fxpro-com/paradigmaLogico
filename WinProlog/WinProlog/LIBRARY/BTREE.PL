/*
   Module that implements a balanced AVL tree library
   --------------------------------------------------

   exports the following predicates:
   btree_insert  / 3  % Insert a term into an AVL tree
   btree_delete  / 3  % Delete a term from an AVL tree
   btree_member  / 2  % Non-deterministic membership of an AVL tree
   btree_to_list / 2  % Convert an AVL tree into a list of pairs
   btree_to_list / 3  % Convert an AVL tree into a difference list of pairs
   list_to_btree / 2  % Convert a list of terms into an AVL tree
*/

:- module( library_btree,
           [
              btree_insert  / 3,
              btree_delete  / 3,
              btree_member  / 2,
              btree_to_list / 2,
              btree_to_list / 3,
              list_to_btree / 2
           ]
         ).

:- index( (bt_insert_left /6), [1,2,3] ).
:- index( (bt_insert_right/6), [1,2,3] ).
:- index( (bt_delete_left /6), [1,2,3] ).
:- index( (bt_delete_right/6), [1,2,3] ).
:- index( (bt_promote/5), [1,2,3] ).

% Insert a term into an AVL tree .

btree_insert( InTree, OutTree, Term ) :-
   bt_insert( InTree, OutTree, Term, _ ).

bt_insert( [], t([],Term,0,[]), Term, 1 ).

bt_insert( t(Left,NTerm,NBal,Right), Tree, Term, Inc ) :-
   compare( Rel, Term, NTerm ),
   bt_insert( Rel, Left, NTerm, NBal, Right, Tree, Term, Inc ).

bt_insert( (<), Left1, NTerm, NBal1, Right, Tree, Term, Inc ) :-
   bt_insert( Left1, Left2, Term, SubInc ),
   bt_insert_left( SubInc, Inc, NBal1, NBal2,
                   t(Left2,NTerm,NBal2,Right),
                   Tree
                 ).

bt_insert( (>), Left, NTerm, NBal1, Right1, Tree, Term, Inc ) :-
   bt_insert( Right1, Right2, Term, SubInc ),
   bt_insert_right( SubInc, Inc, NBal1, NBal2,
                    t(Left,NTerm,NBal2,Right2),
                    Tree
                  ).

% Insert a term in the left sub-tree

bt_insert_left(  0,  0,  B,  B, Tree, Tree ).

bt_insert_left(  1,  0,  1,  0, Tree, Tree ) :-
   !.

bt_insert_left(  1,  1,  0, -1, Tree, Tree ) :-
   !.

% LL = left sub-tree's left sub-sub-tree
% LT = left sub-tree's term
% LR = left sub-tree's right sub-sub-tree
% NT = node's term
% R  = right sub-tree

bt_insert_left( 1,  0, -1,  0,
                t(t(LL,LT,-1,LR),NT,_,R),
                t(LL,LT,0,t(LR,NT,0,R))
              ) :-
   !.

% LL  = left sub-tree's left sub-sub-tree
% LT  = left sub-tree's term
% LRL = left sub-tree's right sub-sub-tree's left  sub-sub-sub-tree
% LRT = left sub-tree's right sub-sub-tree's term
% LRB = left sub-tree's right sub-sub-tree's term balancedness
% LRR = left sub-tree's right sub-sub-tree's right sub-sub-sub-tree
% NT  = node's term
% LB  = balancedness of new left  sub-tree
% RB  = balancedness of new right sub-tree

bt_insert_left(  1,  0, -1,  0,
                 t(t(LL,LT,1,t(LRL,LRT,LRB,LRR)),NT,_,R),
                 t(t(LL,LT,LB,LRL),LRT,0,t(LRR,NT,RB,R))
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

% Insert a term in the right sub-tree

bt_insert_right( 0,  0,  B,  B, Tree, Tree ).

bt_insert_right( 1,  0, -1,  0, Tree, Tree ) :-
   !.

bt_insert_right( 1,  1,  0,  1, Tree, Tree ) :-
   !.

% L  = left sub-tree
% NT = node's term
% RL = right sub-tree's left sub-sub-tree
% RT = right sub-tree's term
% RR = right sub-tree's right sub-sub-tree

bt_insert_right( 1,  0,  1,  0,
                 t(L,NT,_,t(RL,RT,1,RR)),
                 t(t(L,NT,0,RL),RT,0,RR)
               ) :-
   !.

% NT  = node's term
% RLL = right sub-tree's left sub-sub-tree's left  sub-sub-sub-tree
% RLT = right sub-tree's left sub-sub-tree's term
% RLB = right sub-tree's left sub-sub-tree's term balancedness
% RLR = right sub-tree's left sub-sub-tree's right sub-sub-sub-tree
% RT  = right sub-tree's term
% RR  = right sub-tree's right sub-sub-tree
% LB  = balancedness of new left  sub-tree
% RB  = balancedness of new right sub-tree

bt_insert_right( 1,  0,  1,  0,
                 t(L,NT,_,t(t(RLL,RLT,RLB,RLR),RT,-1,RR)),
                 t(t(L,NT,LB,RLL),RLT,0,t(RLR,RT,RB,RR))
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

% Delete a term from an AVL tree

btree_delete( InTree, OutTree, Term ) :-
  bt_delete( InTree, OutTree, Term, _ ).

bt_delete( t(Left,NTerm,NBal,Right), Tree, Term, Dec ) :-
  compare( Rel, Term, NTerm ),
  bt_delete( Rel, Left, NTerm, NBal, Right, Tree, Term, Dec ).

bt_delete( (=), Left, Term, NBal, Right, Tree, Term, Dec ) :-
  bt_promote( NBal, Left, Right, Tree, Dec ).

bt_delete( (<), Left1, NTerm, NBal1, Right, Tree, Term, Dec ) :-
   bt_delete( Left1, Left2, Term, SubDec ),
   bt_delete_left( SubDec, Dec, NBal1, NBal2,
                   t(Left2,NTerm,NBal2,Right),
                   Tree
                 ).

bt_delete( (>), Left, NTerm, NBal1, Right1, Tree, Term, Dec ) :-
   bt_delete( Right1, Right2, Term, SubDec ),
   bt_delete_right( SubDec, Dec, NBal1, NBal2,
                    t(Left,NTerm,NBal2,Right2),
                    Tree
                  ).

% no promotion required for the deletion of a leaf or near-leaf

bt_promote(  0,   [],    [],    [], 1 ) :-
   !.

bt_promote( -1, Left,    [],  Left, 1 ) :-
   !.

bt_promote(  1,   [], Right, Right, 1 ) :-
   !.

% promotion required for deletion of an interior node

bt_promote(  0, Left, Right1, t(Left,PTerm,PBal,Right2), Dec ) :-
   bt_promote_left( Right1, Right2, PTerm, Dec ),
   PBal is 0 - Dec.

bt_promote(  1, Left, Right1, t(Left,PTerm,PBal,Right2), Dec ) :-
   bt_promote_left( Right1, Right2, PTerm, Dec ),
   PBal is 1 - Dec.

bt_promote( -1, Left1, Right, t(Left2,PTerm,PBal,Right), Dec ) :-
   bt_promote_right( Left1, Left2, PTerm, Dec ),
   PBal is Dec - 1.

% found promoted leaf

bt_promote_left(  t([],PTerm,_,Right), Right, PTerm, 1 ) :-
   !.

% not the promoted leaf

bt_promote_left( t(Left1,NTerm,NBal1,Right), Tree, PTerm, Dec ) :-
   bt_promote_left( Left1, Left2, PTerm, Sub ),
   bt_delete_left( Sub, Dec, NBal1, NBal2,
                   t(Left2,NTerm,NBal2,Right),
                   Tree
                 ).

bt_promote_right( t(Left,PTerm,_,[]),  Left,  PTerm, 1 ) :-
   !.

bt_promote_right( t(Left,NTerm,NBal1,Right1), Tree, PTerm, Dec ) :-
   bt_promote_right( Right1, Right2, PTerm, Sub ),
   bt_delete_right( Sub, Dec, NBal1, NBal2,
                    t(Left,NTerm,NBal2,Right2),
                    Tree
                  ).

% no toggle required

bt_delete_left(  0, 0,  B,  B, Tree, Tree ).

bt_delete_left(  1, 0,  0,  1, Tree, Tree ) :-
   !.

bt_delete_left(  1, 1, -1,  0, Tree, Tree ) :-
   !.

% L  = left sub-tree
% NT = node's term
% RL = right sub-tree's left sub-tree
% RT = right sub-tree's term
% RR = right sub-tree's right sub-tree

bt_delete_left( 1,  1,  1,  0,
                t( L, NT, _, t(RL,RT,1,RR) ),
                t( t(L,NT,0,RL), RT, 0, RR )
              ) :-
   !.

bt_delete_left( 1,  0,  1, -1,
                t( L, NT, _, t(RL,RT,0,RR) ),
                t( t(L,NT,1,RL), RT, -1, RR )
              ) :-
   !.

% L   = left sub-tree
% NT  = node's term
% RLL = right sub-tree's left sub-sub-tree's left sub-sub-sub-tree
% RLT = right sub-tree's left sub-sub-tree's term
% RLB = right sub-tree's left sub-sub-tree's balancedness
% RLR = right sub-tree's left sub-sub-tree's right sub-sub-sub-tree
% RT  = right sub-tree's term
% RR  = right sub-tree's right sub-sub-tree
% LB  = balancedness of new left  sub-tree
% RB  = balancedness of new right sub-tree

bt_delete_left( 1,  0,  1,  0,
                t( L, NT, _, t( t(RLL,RLT,RLB,RLR), RT, -1, RR ) ),
                t( t(L, NT, LB, RLL ), RLT, 0, t(RLR,RT,RB,RR) )
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

bt_delete_right( 0,  0,  B,  B, Tree, Tree ).

bt_delete_right( 1,  0,  0, -1, Tree, Tree ) :-
   !.

bt_delete_right( 1,  1,  1,  0, Tree, Tree ) :-
   !.

% LL = left sub-tree's left sub-tree
% LT = left sub-tree's term
% LR = left sub-tree's right sub-tree
% NT = node's term
% R  = right sub-tree

bt_delete_right( 1,  1, -1,  0,
                 t( t(LL,LT,-1,LR), NT, _, R ),
                 t( LL, LT, 0, t(LR,NT,0,R) )
               ) :-
   !.

bt_delete_right( 1,  0, -1,  1,
                 t( t(LL,LT,0,LR), NT, _, R ),
                 t( LL, LT, 1, t(LR,NT,-1,R) )  ) :-
   !.

% LL  = left sub-tree's left sub-tree
% LT  = left sub-tree's term
% LRL = left sub-tree's right sub-sub-tree's left sub-sub-sub-tree
% LRT = left sub-tree's right sub-sub-tree's term
% LRB = left sub-tree's right sub-sub-tree's balancedness
% LRR = left sub-tree's right sub-sub-tree's right sub-sub-sub-tree
% NT  = node's term
% R   = right sub-tree
% LB  = balancedness of new left  sub-tree
% RB  = balancedness of new right sub-tree

bt_delete_right( 1,  0, -1,  0,
                 t( t( LL, LT,  1, t(LRL,LRT,LRB,LRR) ), NT, _, R ),
                 t( t( LL, LT, LB,LRL), LRT, 0, t(LRR,NT,RB,R) )
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

% Non-deterministic membership of an AVL tree

btree_member( Term, t(Left,NTerm,_,Right) ) :-
   ( btree_member( Term, Left )
   ; Term = NTerm
   ; btree_member( Term, Right )
   ).

% Convert an AVL tree into a list .

btree_to_list( Tree, List ) :-
   btree_to_list( Tree, List, [] ).

% Convert an AVL tree into a difference list.

btree_to_list( [], List, List ).

btree_to_list( t(Left,Term,_,Right), List1, List3 ) :-
   btree_to_list( Left, List1, [Term|List2] ),
   btree_to_list( Right, List2, List3 ).

% Convert a list of terms into an AVL tree

list_to_btree( List, Tree ) :-
   list_to_bt( List, [], Tree ).

list_to_bt( [], Tree, Tree ).

list_to_bt( [Term|List], Tree1, Tree3 ) :-
   bt_insert( Tree1, Tree2, Term, _ ),
   list_to_bt( List, Tree2, Tree3 ).
