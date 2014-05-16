:-dynamic metodos/3.
consult(tabelaFatos.pl).

%Regras

%Tabela virtual: definir uma tabela sem ter que criá-la
criterioDeEntrada(X,Y,Z):-metodosNumericos(X,_,Z).

%Manipulação dos dados
%remove uma tupla
deleta(X):-
	deleta1(X), fail.
deleta(X). %garante que seja bem sucedido

deleta1(X):-
	retract(X).
deleta1(X). %garante que seja bem sucedido

%Insere uma tupla, mas primeiro verifica se a tupla não existe através do esquece(X)

%grava(X):-
	%esquece(X), assert(X).

grava(X,Y,Z):-
	assert(metodosNumericos(X,Y,Z)).

consult(leituraEscritaArquivo.pl).

