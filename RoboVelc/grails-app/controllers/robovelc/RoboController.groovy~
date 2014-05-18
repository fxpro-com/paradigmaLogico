package robovelc

import static org.springframework.http.HttpStatus.*
import grails.transaction.Transactional

@Transactional(readOnly = true)
class RoboController {

    def FatorKService, FatorMService, FatorHService

    static allowedMethods = [save: "POST", update: "PUT", delete: "DELETE"]

    def index(Integer max) {
        params.max = Math.min(max ?: 10, 100)
        respond Robo.list(params), model:[roboInstanceCount: Robo.count()]
    }

    def show(Robo roboInstance) {
        respond roboInstance
    }

    def create() {
        respond new Robo(params)
    }


    def selecaoCorrelacao(){

        if(params.tipoGrafico.toString() == "M1")
            FatorMService.calculoCorrelacao(params.quantidadeCandle.toDouble());

        else if(params.tipoGrafico.toString() == "M5")
            FatorKService.calculoCorrelacao(params.quantidadeCandle.toDouble());

        else if(params.tipoGrafico.toString() == "H1")
            FatorHService.calculoCorrelacao(params.quantidadeCandle.toDouble());
        else 
            print("Erro. Nenhuma correlacao instanciada! \n");

    }


    @Transactional
    def save(Robo roboInstance) {

        selecaoCorrelacao()

        if (roboInstance == null) {
            notFound()
            return
        }

        if (roboInstance.hasErrors()) {
            respond roboInstance.errors, view:'create'
            return
        }

        roboInstance.save flush:true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.created.message', args: [message(code: 'roboInstance.label', default: 'Robo'), roboInstance.id])
                redirect roboInstance
            }
            '*' { respond roboInstance, [status: CREATED] }
        }
    }

    def edit(Robo roboInstance) {
        respond roboInstance
    }

    @Transactional
    def update(Robo roboInstance) {
        if (roboInstance == null) {
            notFound()
            return
        }

        if (roboInstance.hasErrors()) {
            respond roboInstance.errors, view:'edit'
            return
        }

        roboInstance.save flush:true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.updated.message', args: [message(code: 'Robo.label', default: 'Robo'), roboInstance.id])
                redirect roboInstance
            }
            '*'{ respond roboInstance, [status: OK] }
        }
    }

    def ativarRobo(Robo roboInstance){

        def arquivo ="criterioEntrada.txt"

        File limpaArquivo = new File(arquivo)
        File gravaArquivo = new File(arquivo)

        flash.message = "Robô "+roboInstance.nomeRobo.toString()+" ativado com sucesso!"
                redirect action:"index"

        limpaArquivo.write("")
        gravaArquivo.append(roboInstance.getNomeRobo())
        gravaArquivo.append("\n")
        gravaArquivo.append(roboInstance.getTipoGrafico())
        gravaArquivo.append("\n")
        gravaArquivo.append(roboInstance.getAlavancagem())
        gravaArquivo.append("\n")
        gravaArquivo.append(roboInstance.getQuantidadeCandle())
        gravaArquivo.append("\n")

        print roboInstance.getNomeRobo()
    }

    @Transactional
    def delete(Robo roboInstance) {

        if (roboInstance == null) {
            notFound()
            return
        }

        roboInstance.delete flush:true

        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.deleted.message', args: [message(code: 'Robo.label', default: 'Robo'), roboInstance.id])
                redirect action:"index", method:"GET"
            }
            '*'{ render status: NO_CONTENT }
        }
    }

    protected void notFound() {
        request.withFormat {
            form multipartForm {
                flash.message = message(code: 'default.not.found.message', args: [message(code: 'roboInstance.label', default: 'Robo'), params.id])
                redirect action: "index", method: "GET"
            }
            '*'{ render status: NOT_FOUND }
        }
    }
    
}
