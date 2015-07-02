class ListView extends Component

	###
    Configuraveis
    @tpl {String} Pode ser uma string representando o HTML ou o endereço para um arquivo .hdb que contenha o template HTML
    @store {Store}
    @containerCls {String} classe base para o container da listview
    ###


	tpl: "
		<nav class=\"{{containerCls}}\">
			<ul>
				{{#if loading}}
					<p>{{nome}}</p>
				{{else}}
					{{#Store .}}
						<li class=\"-mf-flex-container\"> <a href=\"{{href}}\" class=\"{{-mf-active-class}}\"><i class=\"fa fa-{{icon}}\"></i> <span>{{nome}}</span></a></li>
					{{/Store}}
				{{/if}}
			</ul>
		</nav>
	",
	store: null,
	containerCls: '-mf-listview-container',

	constructor:(config={})->
		@applyConfig @, config
		super(@)
		init.call @

	init = ()->
		@addEvent ['itemtap']
		@on 'afterrender', renderComportamentoLinks.bind @


	renderComportamentoLinks=(comp)->
		$(comp.xmlCompiled).find('a').on 'tap', (e)=>
			performateMenuClick.call @, comp, @store.find (item)->
				item.get('nome').toUpperCase().trim() is e.target.innerText.trim()

			e.preventDefault()


	performateMenuClick=(comp, rec)->
		@store.enableEvents false
		@store.find('-mf-active-class', 'active').map (_rec)->
			_rec.set '-mf-active-class', null
		rec[0].set '-mf-active-class', 'active'
		@store.enableEvents true


		@.query(".active").removeClass "active"
		el = @.query("[data-record-internal-id=#{rec[0].id}] a").addClass "active"

		@fireEvent 'itemtap', @, rec[0], el
		rec[0]


@mf.ListView = ListView