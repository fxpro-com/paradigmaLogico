%Leitura do arquivo
carregaBase:-open('calculoPearsonEmC.txt',read,Arquivo),
	read(Arquivo,Correlacao21Candles),
	read(Arquivo,Correlacao34Candles),
	read(Arquivo,Correlacao55Candles),
	read(Arquivo,Correlacao89Candles),
	close(Arquivo),
	write(Correlacao21Candles),write(-),
	write(Correlacao34Candles),write(-),
	write(Correlacao55Candles),write(-),
	write(Correlacao89Candles),write(-),
	tell('tabelaDadosPearson.pl'),
	write('pearson(21,'), write(Correlacao21Candles), write(')'),nl,
	write('pearson(34,'), write(Correlacao34Candles), write(')'),nl,
	write('pearson(55,'), write(Correlacao55Candles), write(')'),nl,
	write('pearson(89,'), write(Correlacao89Candles), write(')'),nl,
	nl,told.

%tell abre o arquivo para escrita
escritaPreFato:-tell('correlacao.txt'),
	write('0.92'),nl,told.
