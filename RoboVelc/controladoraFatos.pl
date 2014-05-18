:-include('tabelaFatos.pl').

insereNovoFatoPearson:- open('calculoPearsonEmC.txt',read,Arquivo),
	read(Arquivo,Correlacao21Candles),
	read(Arquivo,Correlacao34Candles),
	read(Arquivo,Correlacao55Candles),
	read(Arquivo,Correlacao89Candles),
	close(Arquivo),

	tell('tabelaFatos.pl'),
	Correlacao21Candles > 0.7,
	assert(pearson(21,Correlacao21Candles)), 
	listing(pearson(X,Y)), told,

	tell('tabelaFatos.pl'),
	Correlacao34Candles > 0.7,
	assert(pearson(34,Correlacao34Candles)),
	listing(pearson(X,Y)), told,

	tell('tabelaFatos.pl'),
	Correlacao55Candles > 0.7,
	assert(pearson(55,Correlacao55Candles)),
	listing(pearson(X,Y)), told,

	tell('tabelaFatos.pl'),
	Correlacao89Candles > 0.7,
	assert(pearson(89,Correlacao89Candles)),
	listing(pearson(X,Y)), told.
insereNovoFatoPearson.

exclui:-retract(pearson(21,0.8)), 
	tell('tabelaFatos.pl'),
	listing(pearson(X,Y)), told.
exclui.

