#include <stdio.h>
#include <stdlib.h>
#include <math.h>

double metodoCorrelacao(int tempoCorrelacao);

int main(){
	FILE *arquivo;
	double tempoCorrelacao = 21;

	arquivo = fopen("saidaMetodosProlog.txt","wt");

	fprintf(arquivo, "%lf\n",metodoCorrelacao(tempoCorrelacao));
	tempoCorrelacao = 34;
	fprintf(arquivo, "%lf\n",metodoCorrelacao(tempoCorrelacao));
	tempoCorrelacao = 55;
	fprintf(arquivo, "%lf\n",metodoCorrelacao(tempoCorrelacao));
	tempoCorrelacao = 89;
	fprintf(arquivo, "%lf\n",metodoCorrelacao(tempoCorrelacao));

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
	double leituraCotacoes[100];

 	arquivo = fopen("tabela5Minutos.csv","rt");

	for(int c=0; c<tempoCorrelacao; c++){
	    fscanf(arquivo, "%lf",&leituraCotacoes[c]);
	    numeroAbcissa = leituraCotacoes[c];
	    numeroOrdenada = leituraCotacoes[c+1];
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
