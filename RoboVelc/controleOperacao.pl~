carregaCorrelacoes:-open('calculoPearsonEmC.txt',read,Arquivo),
	read(Arquivo,Linha1),
	read(Arquivo,Linha2),
	read(Arquivo,Linha3),
	read(Arquivo,Linha4),
	alavancagem(Linha1,Linha2,Linha3,Linha4),
	close(Arquivo).

alavancagem(Linha1,Linha2,Linha3,Linha4):-  
	( (Linha1 > 0.7, Cont = 0.1) , (Linha2 > 0.7, Cont = 0.2) , (Linha3 > 0.7, 
	Cont = 0.3 ) , (Linha4 > 0.7, Cont = 0.4) ), registraAlavancagem(Cont).
alavancagem(Linha1,Linha2,Linha3,Linha4).

registraAlavancagem(Cont):- tell('entradaMQL.txt'),
	write(Cont), nl,told.


