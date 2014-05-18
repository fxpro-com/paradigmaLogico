#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define QUANTIDADE_CANDLES 100
#define TAMANHO_STRING 50

double leituraCotacoes[QUANTIDADE_CANDLES];
char nomeRobo[TAMANHO_STRING],nomeTipoGrafico[TAMANHO_STRING];

double metodoCorrelacao(int tempoCorrelacao);
void detectaRoboETipoDeGrafico();

int main(){
	FILE *arquivo;
	double tempoCorrelacao = 21;
	char pontoProlog = '.';

	arquivo = fopen("calculoPearsonEmC.txt","wt");

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

	detectaRoboETipoDeGrafico();

	arquivo = fopen(nomeTipoGrafico,"rt");

	for(int c=0; c<QUANTIDADE_CANDLES; c++){
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

void detectaRoboETipoDeGrafico(){
	FILE *arquivo;

	arquivo = fopen("criterioDeEntrada.txt","rt");
	fscanf(arquivo, "%s",&nomeRobo);
	fscanf(arquivo, "%s",&nomeTipoGrafico);
	fclose(arquivo);
}
