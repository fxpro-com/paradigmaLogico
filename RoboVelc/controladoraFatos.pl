:-include('tabelaFatos.pl').
%pearson(21,0.8).


inserirFatoPearson(Candles,Pearson):-append('tabelaFatos.pl'),
	write('pearson('), write(Candles),write(','),write(Pearson), write(').'),nl,told.
inserirFatoPearson(Candles,Pearson).

reconstroiTabelaFatos():- reconstroiTabelaFatosAuxiliar(),fail, close(Arquivo).
reconstroiTabelaFatos().

reconstroiTabelaFatosAuxiliar():- open('tabelaFatos.pl',read,Arquivo),
	read(Arquivo,Linha),
	write(Linha).
reconstroiTabelaFatosAuxiliar().


%deleta(X):-
	%deleta1(X), fail.
%deleta(X).

%deleta1(X):-
	%retract(X).
%deleta1(X).
