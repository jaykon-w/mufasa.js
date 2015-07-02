class Select extends Component

	tpl: "
	<div style=\"display: inherit;\">
		<label style=\"width: 100px\">{{label}}: </label>
		<select style=\"width: 100%;\">
			{{#Store .}}
				<option value=\"{{id}}\">
				{{#if nome}}
					{{nome}}
				{{else}}
					{{codigo}}
				{{/if}}
				</option>
			{{/Store}}
		</select>
	</div>
	"
	store: new Store()
	height: 25
	label: ''


	constructor:(config={})->
		@applyConfig @, config
		super(@)

		@addEvent ['select']


	init:()->
		@on 'afterrender', (e)=>
			self = @
			@query().on('change', (ev)->
				opt = $(ev.target).find ':selected'

				self.fireEvent 'select', self, opt.val(), self.getStore().findAt(opt[0].dataset.recordInternalId)[0]
			)

			@getStore().on 'afterload', =>
				@render()



class Carro extends Component


	tpl: "<div style=\"transition: all 0.5s ease-out;\"></div>"
	style: "background: orange"
	position: 'absolute'
	bottom: 0
	left: 'calc(50% - 5%)'
	height: 150
	width: '10%'

	constructor:(config={})->
		@applyConfig @, config
		super(@)

		@addEvent ['move']



	moveTo:(px)->
		@query()[0].style.left = px+"px"



	normalize:(val, minIn=-100, maxIn=100, minOut=0, maxOut=($('#container_master')[0]?.offsetWidth || document.body.clientWidth)-@query().outerWidth())->

		((maxOut - minOut) * (val - minIn))/(maxIn - minIn) + minOut


	inverseNormalize:(args...)->

		val = args[0]
		maxOut = args[4] || ($('#container_master')[0]?.offsetWidth || document.body.clientWidth)-@query().outerWidth()
		result = @normalize.apply @, args
		
		rest = maxOut-result



class Viewport extends Container
	fullscreen: true

	constructor:(config={})->
		@applyConfig @, config
		super(@)

		new Container
			direction: Container.horizontal
			id: 'main-container'
			height: '100%'
			renderTo: document.body
			components: [
				new Container
					flex: 0.5
					direction: Container.vertical
					components: [
						new Select
							id: 'select_veiculo'
							style: 'align-self: center; margin: 5px;'
							width: '50%'
							label: 'Veiculo'
						new Select
							id: 'select_lines'
							style: 'align-self: center; margin: 5px;'
							width: '50%'
							label: 'Linha'
						new Select
							id: 'select_ways'
							style: 'align-self: center; margin: 5px;'
							width: '50%'
							label: 'Sentido'
						new Container
							height: 300
							position: 'relative'
							style: 'background: rgba(254, 254, 254, 0.51); margin-top: 50px'
							id: 'container_master'
							components:[
								new Container
									style: "background: rgba(0, 128, 0, 0.5);left: calc(50% - 10%)"
									top: 0
									bottom: 0
									position: 'absolute'
									width: '20%'
									id: "best_position"
									components:[
										new Container
											style: "background: #EF1111"
											position: 'absolute'
											top: 0
											bottom: 0
											width: '50%'
											left: '25%'
											id: "medium_carr"
									]
								new Carro
									id: "carro"
							]
					]
			]




class Configuration extends Controller

	constructor:(url, wsPath)->
		@url = url || 'http://173.224.125.206:8803'
		@wsPath = wsPath || 'OperadorServiceRest'
		@ws = [@url, @wsPath].join '/'



		@applyConfig @, @
		super()

		@initializeView()
		


	initializeView:->
		new Viewport()
		lineField = Component.query('#select_lines')[0]
		wayField = Component.query('#select_ways')[0]
		stopField = Component.query('#select_stops')[0]
		vehicleField = Component.query('#select_veiculo')[0] 
		
		lineField.setStore @loadLines()
		vehicleField.setStore @loadVeiculos()


		@carro = Component.query('Carro')[0]


		lineField.on('select', (obj, val, record)=>
			@selectedLine = record
			Component.query('#select_ways')[0].setStore @loadSentidos record.get 'id'
		)

		wayField.on('select', (obj, val, record)=>
			@selectedWay = record
			@loadTempoMedioSentido @selectedLine.get('id'), @selectedWay.get('id')
			@managerInterval()
		)

		###stopField.on('select', (obj, val, record)=>
			@selectedStop = record
			@managerInterval()
		)###

		vehicleField.on('select', (obj, val, record)=>
			@selectedVehicle = record
			@carro.details = record
			if @selectedWay?
				@managerInterval()
		)


	managerInterval:()->
		clearInterval Carro.interval if Carro.interval?
		Carro.interval = setInterval @initRequestInterval, 5000 


	initRequestInterval:()=>
		@loadVeiculosDaLinha(@selectedLine.get('id'), @selectedWay.get('id')).on 'afterload', (e)=>
			@refreshData() 
	

	refreshData:()->
		try
			@carro.data  = @veiculosDaLinha.find('id', @carro.details.get 'id')[0]

			# Formula para posicionar no centro de dois veiculos
			
			prevVehicle = @veiculosDaLinha.getAt(@carro.data.index-1)
			nextVehicle = @veiculosDaLinha.getAt(@carro.data.index+1)

			if !prevVehicle? or !nextVehicle?
				@carro.moveTo(@carro.normalize(0, -1, 1))
			else

				nextVehicle = nextVehicle.get('patternFraction')
				prevVehicle = prevVehicle.get('patternFraction')

				bestFraction = (nextVehicle + prevVehicle)/2
				bestFraction = @carro.normalize (bestFraction - @carro.data.get('patternFraction'))*2, -0.5, 0.5, prevVehicle, nextVehicle
				bestFraction = @carro.inverseNormalize bestFraction, prevVehicle, nextVehicle

				@carro.moveTo(bestFraction)
				
			

			# Formula para melhor posição referente ao horario real de partida do veiculo e o tempo medio da linha
			###
			dateNow = new Date()
			dateNow = dateNow.valueOf()
			carroIniViagem = @carro.data.get 'viagemtimestamp'
			viagemEndTime = carroIniViagem + parseInt(@tempoMedioSentido.store[0].data*1000)

			bestFraction = @carro.inverseNormalize dateNow, carroIniViagem, viagemEndTime, 0, 1
			@carro.moveTo(@carro.data.get('patternFraction') - bestFraction, -1, 1)
			###
			

			# Formula para melhor posição referente a distribuição de todos os carros pela linha
			###
			bestFraction = (1/@veiculosDaLinha.store.length) * @carro.data.index+1

			@carro.moveTo(@carro.data.get('patternFraction') - bestFraction, -0.5, 0.5)
			###
		catch



	loadLines:->
		@linhas = new Store() 
		@linhas.load "#{@ws}/linhas", "linhas"

	loadVeiculos:->
		@veiculos = new Store()
		@veiculos.load "#{@ws}/veiculos", "veiculos"

	loadEmpresas:->
		@empresas = new Store()
		@empresas.load "#{@ws}/veiculos", "veiculos"

	loadVeiculosDaLinha:(idLinha, idPattern)->
		@veiculosDaLinha = new Store()
		@veiculosDaLinha.load "#{@ws}/veiculosDaLinha/#{idLinha}/#{idPattern}", "veiculos"

	loadSentidos:(idLinha)->
		@sentidos = new Store()
		@sentidos.load "#{@ws}/sentidos/#{idLinha}", "sentidos"

	loadTamanhoSentido:(idPattern)->
		@tamanhoSentido = new Store()
		@tamanhoSentido.load "#{@ws}/sentido/#{idPattern}/tamanho", "int"

	loadTempoMedioSentido:(idLinha, idPattern)->
		@tempoMedioSentido = new Store()
		@tempoMedioSentido.load "#{@ws}/sentido/#{idLinha}/#{idPattern}/tempomedio", "double"

	loadPontos:(idPattern)->
		@pontos = new Store()
		@pontos.load "#{@ws}/pontos/#{idPattern}", "pontos"








@app = new Application({

	appName: 'busassist'

	launch:()->
		@conf = new Configuration()
		
})


