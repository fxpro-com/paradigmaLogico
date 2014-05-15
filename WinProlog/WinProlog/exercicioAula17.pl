:-dynamic aluno/3.
:-dynamic professor/3.
:-dynamic nome/2.
:-dynamic curso/2.
:-dynamic orientado/2.
:-dynamic cursoDoAluno/2.

%Fatos
aluno(1, cleiton, software).
aluno(2, vanessa, software).
aluno(3, gabriela, eletronica).
aluno(4, jose, eletronica).

professor(111, milene, cleiton).
professor(222, fabricio, vanessa).
professor(333, laranjeira , maria).
professor(333, fatima, jose).

nome(1, cleiton).
nome(2, vanessa).
nome(3, gabriela).
nome(4, jose).
nome(111, milene).
nome(222, fabricio).
nome(333, laranjeira).
nome(444, fatima).

curso(1, software).
curso(2, software).
curso(3, eletronica).
curso(4, eletronica).

orientado(111, cleiton).
orientado(222, vanessa).
orientado(333, gabriela).
orientado(444, jose).

%Regras
%Tabela virtual: definir uma tabela sem ter que criá-la
cursoDoAluno(X, Y):-aluno(X, _, Y).

%Manipulação dos dados
%remove uma tupla
esquece(X):-
	esquece1(X), fail.
esquece(X). %garante que seja bem sucedido

esquece1(X):-
	retract(X).
esquece1(X). %garante que seja bem sucedido

%Insere uma tupla, mas primeiro verifica se a tupla não existe através do esquece(X)

%memoriza(X):-
	%esquece(X), assert(X).

memoriza(X,Y):-
	assert(nome(X,Y)).

