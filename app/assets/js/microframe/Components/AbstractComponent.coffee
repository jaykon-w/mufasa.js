###
    Classe AbstractComponent, esta classe não deve ser instanciada
###
class AbstractComponent extends Template
	constructor:(config={})->

		super(config)
		Application.context.push @



	setStyle:(styles)->
		if typeof styles is "string"
			return stBuild = styles
		else if typeof styles is "object"
			stBuild = ""
			for k, v of styles
				stBuild += "#{k}: #{v};" if v?.toString?().length? > 0
			return stBuild


	checkForSpecialProperties:(container)->
		if @fullscreen
		
			@position = @position || "absolute" 
			@top = @top || 0
			@bottom = @bottom || 0
			@left = @left || 0
			@right = @right || 0

		if @float
			style = {
				'position': 'absolute'
				'top': if @direction is Container.vertical then 0 else null
				'bottom': if @direction is Container.vertical then 0 else null
				'left': if @direction is Container.horizontal then 0 else null
				'right': if @direction is Container.horizontal then 0 else null
			}
		else
			style = {
				'flex': @flex
				'-webkit-flex': @flex
				'-moz-flex': @flex
				'-ms-flex': @flex
				'-o-flex': @flex
				'flex-direction': @direction
				'-webkit-flex-direction': @direction
				'-moz-flex-direction': @direction
				'-ms-flex-direction': @direction
				'-o-flex-direction': @direction
			}

		style['position'] = @position ?= style['position']
		style['top'] = @top ?= style['top']
		style['bottom'] = @bottom ?= style['bottom']
		style['left'] = @left ?= style['left']
		style['right'] = @right ?= style['right']

		style = @setStyle style
		to = container
		to.setAttribute 'style', (to.getAttribute('style') || "") + style if style.length > 0


@mf.AbstractComponent = AbstractComponent