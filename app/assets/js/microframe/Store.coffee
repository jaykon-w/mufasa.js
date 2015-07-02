###
	Class Srore
###
class Store extends Observable

	rebuildOnChange: true
	storeId: null

	###
    Configuraveis
    @loadConfig {Object} objeto de configuração do JQuery::Ajax
    @autoLoad {Boolean}
    @loadNamespace {String}
    ###

	###
        Construtor da classe Store
        @config {Object} um objeto de configuração
    ###
	constructor:(config={})->
		
		@inialStoreConfig(config)
		super()
		Application.context.push @

		
		@addEvent(['insert','update','delete','remove','load','beforeload','loadfailure','afterload','clear'])

		@add(config.data) if config.data?
		@load null, @loadNamespace if @autoLoad and @loadConfig



	###
        Inicializador das configurações, dentro dessa função estão todas as configurações possiveis para o parametro config
        @config {Object} um objeto de configuração
        @return this
    ###
	inialStoreConfig:(config={})->
		[@store,@removedRecords,@updatedRecords,@loaded,@loadConfig,@autoLoad,@loadNamespace] = [[],[],[],false,null,false,null]

		@applyConfig @, config, true
		@


	###
        Adiciona Records a classe Store
        @record {Object|Record|Array}
        @criterio {Object} {after|before : Number} adiciona um record antes ou depois de um indice especifico
        @oneFire {boolean} @default=false se true, irá queimar o evento de insert apenas no fim da inserção da lista completa
        @return this
    ###
	add:(record, criterio={}, oneFire=false)->

		if Array.isArray record
			for rec in record
				@add rec, criterio, true
				criterio.after += 1 if criterio.after?
				criterio.before += 1 if criterio.before?


			@fireEvent 'insert', @, @store, record

		else

			record = new Record(record) if record not instanceof Record 
			existentRecord = @findAt record.id

			if existentRecord.length == 0

				record.on 'change', _onRecordChange.bind @

				if criterio.after? and criterio.after > -1 and criterio.after <= @store.length-1
					@store.splice(criterio.after, 0, record)
					
				else if criterio.before? and criterio.before > 0 and criterio.before <= @store.length-1
					@store.splice(criterio.before-1, 0, record)

				else
					@store.push record
				

				Object.defineProperty record, 'index',
					get: ()=>
						@store.indexOf record

				@fireEvent 'insert', @, @store, record if !oneFire
		
		@

	###
        Recupera o objeto data de Record, em toda a lista de Store::store
        @return Array de Record::data
    ###
	getData:->
		rec.data for key, rec of @store
	


	toJSON:->
		@getData()


	###
		@private
    ###
	_onRecordChange=(rec, prop, oldVal, val)->
		@fireEvent 'update', @, rec, prop, oldVal, val

		finded = @updatedRecords.filter (i)->
			i.id is rec.id

		@updatedRecords.push rec if !finded.length


	###
        Procura um Record no Store:store
        @param {function|2 argumentos}
        @return Array de Record
    ###
	find:()->

		return _findByCallback.apply @, arguments if typeof(arguments[0]) is "function"
		return _findByParams.apply @, arguments if arguments.length is 2


	findAt:(id)->

		@store.filter (item)->
			item.id is id	

	getAt:(index)->
		@store[index]

	###
        Define a configuração padrão para o ajax usado em load
        @config {Object} um objeto de configuração
    ###
	setLoadConfig:(config)->
		@loadConfig = config

	###
        Limpa o Store
        @return this
    ###
	clear:()->
		for rec, key in @store
			delete @store[key]
		@store = []
		@fireEvent 'clear', @
		@
		

	###
        Carrefga os dados para Record via Ajax
        @config {JQuery::AjaxConfig} um objeto de configuração ajax do JQuery
        @namespace {String} @default=null caso não seja null, vai usar esse namespace para o retorno da URL
        @return this
    ###
	load:(config, namespace=null)->
		@fireEvent 'beforeload', @, config

		config = @loadConfig = config || @loadConfig
		namespace = @loadNamespace = namespace || @loadNamespace

		$.ajax config
		.done (data, textStatus, jqXHR)=>
			result = data
			if namespace
				result = result[namespace]
			
			@fireEvent 'load', @, result, textStatus, jqXHR
			@clear()
			@add result
			@fireEvent 'afterload', @, result, textStatus, jqXHR
		.fail (data, textStatus, jqXHR)=>
			@fireEvent 'loadfailure', @, data, textStatus, jqXHR

		@


	setProxy:(proxy)->
		throw new Error("O objecto não é uma instancia de Proxy") if proxy not instanceof Proxy

		@proxy = proxy
		@proxy.setStore @
		@



	###
        @private
    ###
	_findByCallback=(callback)->
		result = @store.filter callback


	###
        @private
    ###
	_findByParams=(prop, val)->

		result = @store.filter (item)->
			item.get(prop) is val	


	###
		Remove os Records que encontrar pelo filtro, o filtroé o mesmo que os usados em find
        @args Mesmo parametro de find
        @return this
    ###
	remove:(args...)->

		@removedRecords = []

		recs = @find.apply @, args

		for rec in recs
			@removedRecords.push.apply @removedRecords, @store.splice(@store.indexOf(rec), 1)
		
		@fireEvent ['delete','remove'], @, @store, @removedRecords
		@


	@lookup:(id)->
		store = Application.context.filter (Objs)->
			Objs instanceof Store and Objs.storeId is id
		
		store[0]


@mf.Store = Store
