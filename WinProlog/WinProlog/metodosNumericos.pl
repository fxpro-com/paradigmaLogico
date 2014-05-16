:-dynamic metodosNumericos/3.
%:-dynamic iniciar/0.
:-dynamic  escritaArquivo/0.
:-dynamic  leitura/0.

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
%iniciar:- [correlacao].

%:- initialization(leitura).
%see abre o arquivo para leitura
leitura:-see('correlacao.txt'), read(X),nl, seen.

leitura2:- open('correlacao.txt',read,S), read(S,X),close(S),writeln(X).


%tell abre o arquivo para escrita
escritaArquivo:-tell('correlacao.txt'),
write('0.92'),nl,
%told fecha o arquivo
told.
