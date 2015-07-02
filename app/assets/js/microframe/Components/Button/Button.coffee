class Button extends Component


	containerCls: '-mf-button-container'
	componentCls: '-mf-button'
	text: ''
	icon: ''
	badge: false
	tpl: "
		<div class=\"{{containerCls}}\">
			<button class=\"{{componentCls}}\">
				<i class=\"fa fa-{{icon}}\"></i>{{text}}
				{{#if badge}}	
					<div class=\"-mf-badge\">{{badge}}</div>
				{{/if}}
			</button>
		</div>
	"


	constructor:(config={})->
		@applyConfig @, config
		super(@)

		@addEvent ['tap','swipe','hold']
		init.call @


	init=()->
		@on 'afterrender', ()=>

			@query('button').on 'tap press', (e)=>
				@fireEvent 'tap', @, e.target, e
				e.stopPropagation()



@mf.Button = Button