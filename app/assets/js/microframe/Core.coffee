@mf={
	###
		Clona um objeto, é utilpara passar um Objeto para uma variavel por valor, e não por referencia
		@param {obj} O objeto a ser clonado
		@return {obj} Um clone do Objeto passado
	###
	clone:(obj)->
	    return obj if null is obj or "object" != typeof obj
	    copy = obj.constructor()
	    for attr of obj
	        if obj.hasOwnProperty attr
	        	copy[attr] = obj[attr]

	    copy

	lastInternalId: 0

	isMobile:()->
		check = false;
		
		do(a = (navigator.userAgent||navigator.vendor||@opera))->
			if /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino\/i.test(a)||\/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0,4))
				check = true
			else if innerWidth < 640
				check = true
		
		
		check

}

routie = @routie
###
	Inplementação do metodo camelize para a classe String
	@param {string} A string a ser convertida em CamelCase
	@return {string}
###

Object.defineProperty String::, 'camelize', 
	value: ()->
		@replace /(?:^|[-_])(\w)/g, (_, c)->
			if c then c.toUpperCase() else ""

Object.defineProperty Array::, 'contains',
	value: (val)->
		!!~@indexOf(val);


JSON.serialize = (obj, prefix)->
	str = []
	for p of obj
    	if obj.hasOwnProperty p
	    	k = 
	    	if prefix
	    		prefix + "[" + p + "]"
	    	else 
	    		p
	    	
	    	v = obj[p]

	    	str.push if typeof(v) is "object" then JSON.serialize v, k else encodeURIComponent(k) + "=" + encodeURIComponent(v)
    	
	str.join("&")


$ = @$

Hdb = @Handlebars

###
	Handlebar helper Store, para que seja usado no lugar do #each, nos templates que receberem store de um componente
	@exemple ```js
		{{#Store .}}
			<li><i class="{{icon}}"></i> <a href="{{href}}">{{nome}}</a></li>
		{{/Store}}
	```
###
Hdb.registerHelper 'Store', (item, opt)->
	ret = ""

	if opt.data.root instanceof Array
		store = new Store({data: opt.data.root})
		list = store.getData()
	if opt.data.root.hasOwnProperty "store"
		store = opt.data.root.getStore?()||opt.data.root 
		list = store.getData()
	
	inc = 0
	for obj in list
		ret += $(opt.fn obj).first().attr('data-record-internal-id', store.store[inc++].id)[0].outerHTML

	ret

Hdb.registerHelper 'Component', (item, opt)->
	ret = ""

	comp = item
	comp.parent = opt.data.root
	comp.xml = $(comp.xml).first().attr('data-id', "component-container-#{mf.lastInternalId++}")[0].outerHTML
	comp.renderTo = ()->
		opt.data.root.query("[data-id=#{$(comp.xml).first().attr 'data-id'}]")
	

	comp.afterRenderFunction = ()->
		comp.render()
		comp.checkForSpecialProperties comp.renderTo()[0]
	

	opt.data.root.on 'afterrender', comp.afterRenderFunction, true

	new Handlebars.SafeString comp.xml



###
		list = new Store({data: opt.data.root})
		list = list.getData()
	if opt.data.root.hasOwnProperty "store"
		list = opt.data.root.getStore().getData()
		
	for obj in list
		ret += opt.fn obj

	ret
###
###
	Classe core
###
class Core


	constructor:()->
		@_className = @constructor.name

	###
		Transforma o obeto de configuração passado, em propriedades membro do Objeto
		@prototype {Object.prototype} O prototipo do objeto que deve ser usado
		@config {Object} Um objeto com as configurações que devem ser passada ao outro objeto
		@replace {boolean} @default=true caso seja true, se o Objeto que recebera as configurações já tiver um dos parametros de `config`, ele será reescrito. 
	###
	applyConfig:(prototype, config, replace=true)->
		for key, value of config
			if replace
				prototype[key] = config[key]
				@defineGetSet key, prototype
			else
				if !prototype[key]
					prototype[key] = config[key]
					@defineGetSet key, prototype

	###
		Cria os Getters e Setters das propriedades passadas
		@key {String} Nome da propriedade
		@prototype {Object.prototype} O prototipo do objeto que deve ser usado
	###
	defineGetSet:(key, prototype)->
		if typeof(prototype[key]) isnt "function"
			
			if !prototype["get#{key.camelize()}"]?
				prototype["get#{key.camelize()}"] = ()->
					@[key]
			if !prototype["set#{key.camelize()}"]?
				prototype["set#{key.camelize()}"] = (e)->
					@[key] = e
					@render()
		
				
@mf.Core = Core