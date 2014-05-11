import ArquivosForex(cotacoes,detectaQuantidadeCandle)
import CorrelacaoDePearson(correlacaoDePearson)
import Fibonacci(encontrarFibonacciAnterior)
import MediaMovel (mediaMovelInferior, mediaMovelSuperior)
import Foreign.Marshal
import System.IO

main = do
	let pearson = unsafeLocalState (correlacaoDePearson cotacoes)
	let mediaInferior = mediaMovelInferior
	let mediaSuperior = mediaMovelSuperior

	arquivoForex <- openFile "saidaMetodosNumericos.txt" AppendMode
	hPrint arquivoForex pearson
	hPrint arquivoForex mediaInferior
	hPrint arquivoForex mediaSuperior

	hClose arquivoForex