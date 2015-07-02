class Container extends Component

	@horizontal: 'row'
	@vertical: 'column'
	@Ihorizontal: 'row-reverse'
	@Ivertical: 'column-reverse'
	

	containerCls: '-mf-flex-container'
	direction: @horizontal
	float: false
	transitionCls: ''
	adicionalCls: ''
	fullscreen: false

	components: []

	tpl: "
		<div class=\"{{containerCls}} {{transitionCls}} {{adicionalCls}}\">
			{{#each components}}
				{{Component .}}
			{{/each}}
		</div>
	"

	constructor:(config={})->
		@applyConfig @, config

		super(@)
		
		@addEvent ["resize"]



@mf.Container = Container