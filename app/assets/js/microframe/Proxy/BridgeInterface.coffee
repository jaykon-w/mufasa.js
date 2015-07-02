class BridgeInterface extends Observable
	
	interfaceMethod=()->
		throw new Error "Método não implementado"

	constructor:(config={})->
		@applyConfig @, config, true
		super @

	bindsForStore: interfaceMethod
