:-dynamic metodos/3.
:-include('tabelaFatos.pl').
:-include('controladoraFatos.pl').

%Esssa será a main --------------------

%chamar tabelaBancoDeDados.pl
%chamar controladoraFatos.pl

%-------------------------------------


%tell abre o arquivo para escrita
escritaPreFato:-tell('correlacao.txt'),
	write('0.92'),nl,told.






%Tabela virtual: definir uma tabela sem ter que cri�-la
%criterioDeEntrada(X,Y,Z):-metodosNumericos(X,_,Z).
%metodoNinja(21,mmUltraRapida).
%metodoNinja(34,mmMediaRapida).
%metodoNinja(55,mmMedia).
%metodoNinja(89,mmMediaLenta).






