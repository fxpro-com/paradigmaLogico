module Fibonacci (verificaCotacaoListaFibonacci, encontrarFibonacciAnterior) where

import Foreign.Marshal

verificaCotacaoListaFibonacci candle=
		candle `elem` [1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,1597,2584,4181]


encontrarFibonacciAnterior candle= if (verificaCotacaoListaFibonacci (candle-1))
	then (candle - 1)
	else encontrarFibonacciAnterior (candle-1)