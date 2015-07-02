class Toolbar extends Container

	@top: 'top'
	@right: 'right'
	@bottom: 'bottom'
	@left: 'left'


	toolbarCls: '-mf-toolbar-container'
	position: 'fixed'
	side: @top
	size: 'auto'


	constructor:(config={})->
		@applyConfig @, config

		@setups()
		@adicionalCls += " #{@toolbarCls} "

		super(@)


	setSide:(val)->
		@side = val
		@setups()
		@render()


	setups:()->
		switch @side
			when Toolbar.top
				@top = 0
				@left = 0
				@right = 0
				@height = @size
				@direction = Container.horizontal
			when Toolbar.right
				@top = 0
				@bottom = 0
				@right = 0
				@width = @size
				@direction = Container.vertical
			when Toolbar.bottom
				@left = 0
				@bottom = 0
				@right = 0
				@height = @size
				@direction = Container.horizontal
			when Toolbar.left
				@left = 0
				@bottom = 0
				@top = 0
				@width = @size
				@direction = Container.vertical

		
			
	
@mf.Toolbar = Toolbar