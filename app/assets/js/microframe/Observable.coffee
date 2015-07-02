###
    Classe Observable, usada para tratar eventos de objetos
###
class Observable extends Core

    ###
    Configuraveis
    @listeners {Function} deve retornar um JSON com os eventos representando a função do listener
    ###
    emitEvents = true

    constructor:()->
        @events ={}
        @_listeners ={}

        @setInitialListeners()
        super()

    ###
        Adiciona eventos para a classe, antes de queimar um evento ou de tratalo, toda classe deve adicionar um evento compreendido por Observable, para que seja tratado.
        @events {String|Array} nomes dos eventos que serão tratados pela classe 
    ###
    addEvent:(events)->
        @events = if Array.isArray events then events else [events]
        for ev in @events
            @_listeners[ev] = [] if !@_listeners[ev]?

    ###
        Queima um evento, e passa uma lista de argumentos
        @event {String} nomes dos eventos a ser queimado
        @args {mixins[list]} Uma lista de argumentos a serem passados para os ouvintes 
    ###
    fireEvent:(event, args...)->
        result = false

        if Array.isArray event
            result = @fireEvent.apply @, [ev].concat(args) for ev in event
        else
            if emitEvents
                if @_listeners[event]? and @_listeners[event].length > 0
                    for callback in @_listeners[event]
                        listener = callback

                        listener['fn'].apply @, if args.length is off then @ else args 

                        if listener['single']
                            @un event, listener['fn']
                result = true
            else
                result = false
        result
    ###
        EventListener
        @event {String} nomes dos eventos que serão ouvido
        @callback {Function} Função a ser executada quando o evento ocorrer
        @single {boolean} @default=false caso true, o evento só existira até a primeira vez que for disparado 
    ###
    on:(event, callback, single = false)->
        @addEvent event
        @_listeners[event].push {
            "fn": callback,
            "single": single
        }

    ###
        Remove EventListener
        @event {String} nomes dos eventos que serão removido dos ouvintes
        @callback {Function} Função que esta sendo executada quando o evento acontece
    ###
    un:(event, callback)->
        
        index = @_listeners[event].map((e)-> e.fn).indexOf callback
        @_listeners[event].splice index, 1 if index >= 0

            # @_listeners[event].length--
        true

    setInitialListeners:()->

        if @listeners?
            for k, v of  @listeners()
                @on k, v

    enableEvents:(bol)->
        emitEvents = bol


@mf.Observable = Observable