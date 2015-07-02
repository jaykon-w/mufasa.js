###
    Classe Component
###
class Component extends AbstractComponent


	###
        @private
    ###
	initialized = false

	###
	@tpl //{string} Template handlebar
	@beforeInit //{function} Função para ser executada antes da exibição do component na tela, scopo: this
	@init //{function} Função para ser executada depois da exibição do component na tela, scopo: this
	@store //{Store Object}
	@data //{Object}
	@renderTo {Element|Selector} para onde o componente será reenderizado
	###


	###
        Construtor da classe
        @config {Object} Objeto de configuração, acima estão os principais parametros de configuração, mas qualquer um pode ser passado e ser chamado no Component::init()
    ###
	constructor:(config={})->
		@defineInitialConfiguration(config)
		
		@beforeInit?.call @ if !initialized
		super(@)
		@addEvent ['render','afterrender','hide','show']


		@createBinds() if @store?
		@render()
		
		@init?.call @ if !initialized
		initialized = true

	###
        Faz todo o processo de reenderização do Componente
        @newData {Object} @default=null Objeto a ser reescrito no Template::compile
    ###
	render:(newData=null)->
		@beforeRender(newData)
		
		@checkForSpecialProperties(@xmlCompiled[0])

		@makeView()
		@


	###
        Compila o template antes de exibir na tela
        @newData {Object} @default=null Objeto a ser reescrito no Template::compile
    ###
	beforeRender:(newData=null)->
		
		@xmlCompiled = $(@compile newData || @)
		@fireEvent 'render', @


	###
        Reenderiza o componente na tela
    ###
	makeView:()->
		if typeof @renderTo is "function"
			to = @renderTo()
		else if @renderTo?
			to = @renderTo

		if to?
			if $(@xmlCompiled).first().attr('data-id') and $(to).first().attr('data-id') is $(@xmlCompiled).first().attr('data-id') 
				$(to).replaceWith @xmlCompiled
			else
				$(to).html @xmlCompiled
			
			@fireEvent 'afterrender', @, @xmlCompiled


	###
        Cria os binds no Store, para que a view seja atualizada
    ###
	createBinds:()->
		@store.on 'update', ()=>
			@render() if @store.rebuildOnChange
		@store.on 'insert', ()=>
			@render() if @store.rebuildOnChange
		@store.on 'delete', ()=>
			@render() if @store.rebuildOnChange
		@store.on 'clear', ()=>
			@render() if @store.rebuildOnChange


	###
        definine as configurações iniciais
    ###
	defineInitialConfiguration:(config={})->

		@applyConfig @, config

		@hidden = false
		initialized = false
		true


	###
        busca um Elemento dentro do Template HTML já compilado
    ###
	query:(selector)->
		if selector
			$(@xmlCompiled).find selector
		else
			$(@xmlCompiled).first()

	hide:()->
		@xmlCompiled.hide()
		@hidden = true
		@fireEvent 'hide', @, @xmlCompiled
		@

	show:()->
		@xmlCompiled.show()
		@hidden = false
		@fireEvent 'show', @, @xmlCompiled
		@

	toggle:()->
		if @hidden
			@show()
		else
			@hide()


	@PseudoSelectors: {
		"parent": (v, scope)->
			component = []
			upperComponents = []
			tempC = []

			tempC = scope.map (obj)->
				[obj.parent] if obj.parent?

			tempC = tempC.filter (e)->e

			if tempC.length > 0
				for InnerCmp in tempC
					upperComponents.push Component.PseudoSelectors["parent"](v, InnerCmp)


			[].concat.apply component, [].concat.apply tempC, upperComponents

	}


	@FnSelectors: {
		# by pseudo
		":\\w+\\(.+\\)": (v, scope)->

			component = []

			[pseudo, fn, value] = v.match(/:(\w+)\((.+)\)/i)

			for key, obj of Component.PseudoSelectors
				if RegExp("^#{key}$").test fn

					component = obj value, scope

					break
				
			component = Component.query value, {components: component}


		# by attribute
		"\\[(.+)\\]": (v, scope)->
			component = []

			[sel, attr, logic, value] = /\[(.+)(\b(?:\!|\||\?|\^|\$|\*)?=\b)(.+)\]/.exec(v) || /\[(.+)()()\]/.exec(v)
			value = rebuildTypes value
			FnLogic = {
				'=': (obj)->
					if obj[attr] is value
						component.push obj
				'!=': (obj)->
					if obj[attr] isnt value
						component.push obj
				'|=': (obj)->
				'?=': (obj)->
				'^=': (obj)->
					if RegExp("^#{value}").test obj[attr]
						component.push obj
				'$=': (obj)->
					if RegExp("#{value}$").test obj[attr]
						component.push obj
				'*=': (obj)->
					if RegExp("#{value}", "g").test obj[attr]
						component.push obj
			}


			if logic is "" and value is ""

				for key, obj of scope
					if obj[attr]? 
						component.push obj
			else
				for key, obj of scope
					FnLogic[logic](obj)


			component

		# by component
		"\\b\\w+\\b": (v, scope)->
			
			component = []

			for key, obj of scope
				if obj._className is v
					component.push obj if component.indexOf(obj) is -1
			
			component
			
		# children  
		"\\s*>\\s*|\\s+": (v, scope)->
			component = []
			depperComponents = []
			tempC = []

			tempC = scope.map (obj)->
				obj.components

			tempC = tempC.filter (e)->e

			if /^\s+$/.test(v) and tempC.length > 0
				for InnerCmp in tempC
					depperComponents.push Component.FnSelectors["\\s*>\\s*|\\s+"](v, InnerCmp)


			[].concat.apply component, [].concat.apply tempC, depperComponents


		# by class or id
		"(\\.)|(#).+": (v, scope)->
			component = []

			for key, obj of scope
				if obj.query().is(v)
					component.push obj
			

			component
		

	}


	rebuildTypes=(str)->
		val = null

		if str is "true" or str is "false"
			val = eval str
		else if /^\d+$/.test str
			val = Number str
		else
			val = str

		val





	@query:(selector, context=null)->
		components = []
		selector.split(',').forEach (sel)->

			components.push explodeSelector sel.trim(), context

		[].concat.apply [], components

	explodeSelector=(selector, context=null)->
		if context?
			context = [context]
			selector = ">#{selector}"

		component = context || Application.context

		selector.replace /(\..+)|(#.+)|(\[([^\#\.]\w+.{0,2}[^\#\.]\w+)\])|(\s*>\s*)|(\s+)|(:\w+\(.+\))|([^\#\.:]\w+)/ig, (v)->
			for key, obj of Component.FnSelectors
				if RegExp("^#{key}$").test v

					component = obj v, component

					break
			
		component



mf.Component = Component