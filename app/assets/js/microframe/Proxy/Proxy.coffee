class Proxy extends Core

	@SOCKET: 'Socket'

	bridge: null
	type: @SOCKET
	store: null


	constructor:(config={})->
		@applyConfig @, config, true
		super(@)

		@getAdapter(config)



	getAdapter:(config)->
		
		switch config.type
			when Proxy.SOCKET
				@bridge = new Socket(config.bridge)
			else
				throw new Error "Proxy.type não suportado."


	setStore:(store)->
		throw new Error("Não é uma instancia de Store") if store not instanceof Store
		@store = store
		@bridge.bindsForStore store 


@mf.Proxy = Proxy
