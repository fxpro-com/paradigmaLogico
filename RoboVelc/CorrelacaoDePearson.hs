module CorrelacaoDePearson(calculaMedia, vetorX, vetorY, covarianciaPearson, varianciaPearson, correlacaoDePearson)where

calculaMedia [] = 0
calculaMedia (cabeca:calda) = sum (cabeca:calda) / fromIntegral(length (cabeca:calda))

vetorX [] = []
vetorX (cabeca : calda) =  [cabeca] ++ vetorX ( drop 1 calda)

vetorY [] = []
vetorY (cabeca : calda) = [(head calda)] ++ vetorY ( drop 1 calda)

covarianciaPearson [] [] xMedio yMedio = 0
covarianciaPearson (cabecaX : caldax) (cabecaY : calday) xMedio yMedio = (cabecaX - xMedio) * (cabecaY - yMedio) + (covarianciaPearson caldax calday xMedio yMedio)

varianciaPearson [] media = 0
varianciaPearson (cabeca : calda) media = (cabeca - media) ** 2 + (varianciaPearson calda media)

correlacaoDePearson (cabeca:calda) =  do
		let x = vetorX (cabeca:calda)
		let y = vetorY (cabeca:calda)

		let mediaX = calculaMedia x
		let mediaY = calculaMedia y

		let covariancia = covarianciaPearson x y mediaX mediaY
		let varianciaX = varianciaPearson x mediaX
		let varianciaY = varianciaPearson y mediaY

		let varianciaXY = varianciaY * varianciaX
		let raizVarianciaXY = sqrt (varianciaXY)

		return (covariancia / raizVarianciaXY)