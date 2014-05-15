:-dynamic metodosNumericos/3.


%Fatos-> Verdades
metodosNumericos(-0.85,0.23,vaiSubir).
metodosNumericos(-0.85,0.38,vaiSubir).
metodosNumericos(-0.85,0.50,vaiSubir).
metodosNumericos(-0.85,0.62,vaiSubir).
metodosNumericos(0.85,0.23,vaiCair).
metodosNumericos(0.85,0.38,vaiCair).
metodosNumericos(0.85,0.50,vaiCair).
metodosNumericos(0.85,0.62,vaiCair).

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



%:- initialization(iniciar).
%iniciar:- [correlacao.txt].

%see abre o arquivo para leitura
see('correlacao'), read(X).
%seen fecha o arquivo
%seen.
