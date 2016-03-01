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
		store.autoCommit = true

		if not events.contains "insert"
			@on "insert", (data, wrapper, original)->
				store.enableReceive = false
				data.$$reemitThis = false
				store.add data
		if not events.contains "remove"
			@on "remove", (data, wrapper, original)->
				store.enableReceive = false

				store.findAt(data.id)?.data.$$reemitThis = false
				store.remove 'id', data.id
		if not events.contains "update"
			@on "update", (data, wrapper, original)->
				store.enableReceive = false

				findedData = store.findAt(data.id)
				data.$$reemitThis = false
				findedData?.replace data
		


		store.on "insert", (store, collection, record)=>
			@emit "insert", record if record.data.$$reemitThis isnt false
			delete record.data.$$reemitThis

		store.on "remove", (store, collection, record)=>
			return false if !record.data?
			@emit "remove", record if record.data?.$$reemitThis isnt false
			delete record.$$reemitThis

		store.on "update", (store, record, prop, oldVal, val)=>
			@emit "update", record if record.data.$$reemitThis isnt false
			delete record.$$reemitThis

		true
		


@mf.Socket = Socket