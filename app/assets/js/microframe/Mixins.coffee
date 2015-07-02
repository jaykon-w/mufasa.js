###
	Classe Mixin, usada para extender mais de uma classe para a nova
	@exemple ```coffee
		class A extends Mixin.use B, C, D
	```
###
class Mixin
    @use= (mixins...) ->
        for mixin in mixins
            @::[key] = value for key, value of mixin::
        @

@mf.Mixin = Mixin