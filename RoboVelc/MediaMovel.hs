module MediaMovel (mediaMovelInferior, mediaMovelSuperior) where

import CorrelacaoDePearson(calculaMedia)
import ArquivosForex (detectaQuantidadeCandle, lerCotacoes, cotacoes)
import Fibonacci (encontrarFibonacciAnterior)
import Foreign.Marshal


numeroFibonacciAnterior = encontrarFibonacciAnterior ( unsafeLocalState detectaQuantidadeCandle)
novaLista = take numeroFibonacciAnterior (unsafeLocalState lerCotacoes)

mediaMovelInferior = calculaMedia novaLista

mediaMovelSuperior = calculaMedia cotacoes