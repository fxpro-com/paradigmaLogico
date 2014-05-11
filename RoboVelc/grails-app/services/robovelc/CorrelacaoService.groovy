package robovelc

import grails.transaction.Transactional

@Transactional
abstract class CorrelacaoService {

	abstract def calculoCorrelacao(double tempoCorrelacao);

    def serviceMethod() { }
}
