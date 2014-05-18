
%Manipula��o dos dados
%remove uma tupla

%deleta(X):-
%	deleta1(X), fail.
%deleta(X). %garante que seja bem sucedido

%deleta1(X):-
%	retract(X).
%deleta1(X). %garante que seja bem sucedido


%grava(X):-
	%esquece(X), assert(X).

%grava(X,Y,Z):-
%	assert(metodosNumericos(X,Y,Z)).


%Atividade: inserir e excluir dados da tabela de fatos

inserirFatoPearson(Candles,Pearson):-append('tabelaFatos.pl'),
	write('pearson('), write(Candles),write(','),write(Pearson), write(').'),nl,told.