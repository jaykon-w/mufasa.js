###
    Classe Record, representa um unico registro
###
class Record extends Observable
	###
        @private
        Id interno do Record
    ###
	@_id=0


	###
        Construtor da classe
        @data {Object}
        @return this
    ###
	constructor:(data)->
		super()
		@addEvent('change')

		@data = data
		@originalData = mf.clone data
		@id = data.id || data._id || ++Record._id
		@

	###
        Getter
    ###
	get:(prop)->
		@data[prop]


	###
        Setter
    ###
	set:(prop, val)->
		oldVal = @get(prop)

		@data[prop] = val
		
		@fireEvent('change', @, prop, oldVal, val)
		@


	replace:(data)->
		old = mf.clone @data
		@data = data
		@fireEvent('change', @, Object.keys(data), old, @data)
		@


@mf.Record = Record