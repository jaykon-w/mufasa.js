class Application extends Observable

	appName: 'app'
	@context: null
	###
    Configuraveis
    @launch {Function} função a executar no lançador
    @init {Function} função a executar na inicialização do componente
    ###

	constructor:(config={})->

		window.MyMF = {}

		@applyConfig @, config
		window.MyMF[@appName] = []
		Application.context = window.MyMF[@appName]

		super(@)
		
		@addEvent ['launch', 'ready']

		@init?()
		initialListeners.call @


		$ ()=> @fireEvent 'ready', @


	initialListeners = ()->
		@on 'ready', ()=>
			@launch() if @launch?


@mf.Application = Application