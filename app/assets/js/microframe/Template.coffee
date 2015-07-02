###
    Classe Template
###
class Template extends View

	###
    Configuraveis
    @tpl {String} Pode ser uma string representando o HTML ou o endereço para um arquivo .hdbque contenha o template HTML
    @width {String|Number}
    @height {String|Number}
    @style {String}
    ###

	###
        Construtor da classe Template
        @tpl {String} Pode ser uma string representando o HTML ou o endereço para um arquivo .hdbque contenha o template HTML
    ###
	constructor:(config={})->
		@applyConfig @, config
		super(@)
		
		if typeof config is 'object'
			tpl = config.tpl
		else
			tpl = config


		@addEvent ['beforecompile','aftercompile']


		if /\.hdb$/.test tpl
			$.ajax {
				url: tpl,
				type: 'GET',
				async: false,
				success: (e)=>
					@xml = e
			}
			###$.get tpl, (e)=>
				@xml = e###
		else
			@xml = tpl

		repassBasicAttr.call @



	repassBasicAttr = ()->

		@xml = $(@xml).first()
		@xml.css 'width', @width if @width?
		@xml.css 'height', @height if @height?
		@xml[0].setAttribute('id', @id) if @id?
		@xml[0].setAttribute('style', if @xml[0].getAttribute('style') is "" then @style+";" else (@xml[0].getAttribute('style') || "")+@style+";")  if @style?.length > 0

		@xml = @xml[0].outerHTML
			

	###
        Compila o template
        @data {Object} Objeto contendo os parametros a serem representados no template
    ###
	compile:(data)->

		@fireEvent 'beforecompile', @, @xml

		@hdb = Hdb.compile @xml
		result = @xmlCompiled = @hdb data

		@fireEvent 'aftercompile', @, result

		result


@mf.Template = Template