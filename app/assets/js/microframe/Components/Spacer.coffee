class Spacer extends Component


	tpl: "
		<div></div>
	"

	constructor:(config={})->
		@applyConfig @, config
		super(@)