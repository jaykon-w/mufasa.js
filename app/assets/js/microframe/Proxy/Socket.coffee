class Socket extends BridgeInterface

	socket: null
	autoSync: true
	

	events = []

	constructor:(config={})->
		throw new Error "Socket.io não localizado" if !io?

		

		if config.events?
			events = mf.clone config.events
			delete config.events

		if typeof config.extras?.query? is "object"
			config.extras.query = JSON.toQueryString config.extras.query

		@socket = io.connect config.host, config.extras
		@autoSync = config.autoSync || true


		@applyConfig @, config, true
		super @
		

		@addEvent events
		#@setEventWrapper()


	setEventWrapper:->
		@socket.removeAllListeners()

		for k in @events
			@socket.on k, ()=>
				@fireEvent.apply @, [].concat.apply([k], arguments).concat([@, @socket])


	on:(event, callback, single = false)->

		@socket.on event, ()=>
			@fireEvent.apply @, [].concat.apply([event], arguments).concat([@, @socket])

		super event, callback, single


	emit:()->
		@socket.emit.apply @socket, arguments



	bindsForStore:(store)->

		store.enableReceive = true

		if not events.contains "insert"
			@on "insert", (data, wrapper, original)->
				store.enableReceive = false
				store.add data
				store.enableReceive = true
		if not events.contains "remove"
			@on "remove", (data, wrapper, original)->
				store.enableReceive = false
				store.remove 'id', data.id
				store.enableReceive = true
		if not events.contains "update"
			@on "update", (data, wrapper, original)->
				store.enableReceive = false
				store.findAt(data.id)[0]?.replace data
				store.enableReceive = true
		


		store.on "insert", (store, collection, record)=>
			@emit "insert", record if store.enableReceive

		store.on "remove", (store, collection, record)=>
			@emit "remove", record if store.enableReceive

		store.on "update", (store, rec, prop, oldVal, val)=>
			@emit "update", rec if store.enableReceive

		true
		


@mf.Socket = Socket