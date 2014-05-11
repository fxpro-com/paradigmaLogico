package robovelc

import grails.transaction.Transactional

@Transactional
class FatorHService  extends CorrelacaoService{
	List cotacoesFatorK = new File("tabela1Hora.csv").readLines()

	def calculoCorrelacao(double tempoCorrelacao){
		 double somaOrdenadas = 0, somaAbcissas = 0,
		        somaOrdenadasQuadrado = 0, somaAbcissasQuadrado = 0,
		        somaXvezesY = 0, correlacao,
		        numeroAbcissa, numeroOrdenada,
		        numerador, denominador_1,denominador;

		for(int c=0; c<tempoCorrelacao; c++){
		    numeroAbcissa = cotacoesFatorK[c].toDouble()
		    numeroOrdenada = cotacoesFatorK[c+1].toDouble()
		    somaAbcissas =   somaAbcissas + numeroAbcissa;
		    somaAbcissasQuadrado += (numeroAbcissa*numeroAbcissa);
		    somaOrdenadas = somaOrdenadas + numeroOrdenada;
		    somaOrdenadasQuadrado += (numeroOrdenada*numeroOrdenada);
		    somaXvezesY = somaXvezesY + (numeroOrdenada*numeroAbcissa);
		 } 

		numerador =((tempoCorrelacao*somaXvezesY)-((somaAbcissas)*(somaOrdenadas)));
		denominador_1 =((tempoCorrelacao*somaAbcissasQuadrado)-(somaAbcissas*somaAbcissas))*
		((tempoCorrelacao*somaOrdenadasQuadrado)-(somaOrdenadas*somaOrdenadas));	

		denominador = Math.pow(denominador_1, 1/2); 

		correlacao = numerador/denominador; 

		println "______________________________________\n"
		println "Fator H instanciado = ["+correlacao+"]\n\n\n\n"
		println "______________________________________\n"

		return correlacao
	}

    def serviceMethod() {}
}
