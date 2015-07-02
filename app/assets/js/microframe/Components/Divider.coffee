class Divider extends Component

	componentCls: '-mf-divider'
	tpl: "
		<hr class=\"{{componentCls}}\" />
	"


	constructor:(config={})->
		@applyConfig @, config
		super(@)


@mf.Divider = Divider