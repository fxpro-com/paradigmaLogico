%Leitura do arquivo
leitura:-open('saidaMetodosProlog.txt',read,Arquivo),
	read(Arquivo,Correlacao21Candles),
	read(Arquivo,Correlacao34Candles),
	read(Arquivo,Correlacao55Candles),
	read(Arquivo,Correlacao89Candles),
	close(Arquivo),
	write(Correlacao21Candles),write(-),
	write(Correlacao34Candles),write(-),
	write(Correlacao55Candles),write(-),
	write(Correlacao89Candles),write(-),nl.

%tell abre o arquivo para escrita
escritaArquivo:-tell('correlacao.txt'),
	write('0.92'),nl,told.
