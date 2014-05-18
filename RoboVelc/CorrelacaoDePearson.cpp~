#include <stdio.h>
#include <stdlib.h>
#include <math.h>

double leituraCotacoes[100];
double metodoCorrelacao(int tempoCorrelacao);

int main(){
	FILE *arquivo;
	double tempoCorrelacao = 21;
	char pontoProlog = '.';

	arquivo = fopen("saidaMetodosProlog.txt","wt");

	fprintf(arquivo, "%lf%c\n",metodoCorrelacao(tempoCorrelacao), pontoProlog);
	tempoCorrelacao = 34;
	fprintf(arquivo, "%lf%c\n",metodoCorrelacao(tempoCorrelacao), pontoProlog);
	tempoCorrelacao = 55;
	fprintf(arquivo, "%lf%c\n",metodoCorrelacao(tempoCorrelacao), pontoProlog);
	tempoCorrelacao = 89;
	fprintf(arquivo, "%lf%c\n",metodoCorrelacao(tempoCorrelacao), pontoProlog);

	fclose(arquivo);

	return 0;	
}

double metodoCorrelacao(int tempoCorrelacao){

	FILE *arquivo;
        double somaOrdenadas = 0, somaAbcissas = 0,
	       somaOrdenadasQuadrado = 0, somaAbcissasQuadrado = 0,
	       somaXvezesY = 0, correlacao,
	       numeroAbcissa, numeroOrdenada,
	       numerador, denominador_1,denominador;

 	arquivo = fopen("tabela1Hora.csv","rt");

	for(int c=0; c<100; c++){
	    fscanf(arquivo, "%lf",&leituraCotacoes[c]);
	}

	for(int c=0; c<tempoCorrelacao; c++){
	    numeroAbcissa = leituraCotacoes[c];
	    numeroOrdenada = leituraCotacoes[c+1];
	    printf("%lf c \n",leituraCotacoes[c]);
	    printf("%lf c+1 \n",leituraCotacoes[c+1]);

	    somaAbcissas =   somaAbcissas + numeroAbcissa;
	    somaAbcissasQuadrado += (numeroAbcissa*numeroAbcissa);
	    somaOrdenadas = somaOrdenadas + numeroOrdenada;
	    somaOrdenadasQuadrado += (numeroOrdenada*numeroOrdenada);
	    somaXvezesY = somaXvezesY + (numeroOrdenada*numeroAbcissa);
	 } 

	numerador =((tempoCorrelacao*somaXvezesY)-((somaAbcissas)*(somaOrdenadas)));
	denominador_1 =((tempoCorrelacao*somaAbcissasQuadrado)-(somaAbcissas*somaAbcissas))*
	((tempoCorrelacao*somaOrdenadasQuadrado)-(somaOrdenadas*somaOrdenadas));	

	denominador = pow(denominador_1, 1.0/2.0); 

	correlacao = numerador/denominador; 
	
	return correlacao;

	printf("%f\n",correlacao);
	fclose(arquivo);
}
