functor
import
	Player
export
	playerGenerator:PlayerGenerator
define
	PlayerGenerator
in
	fun{PlayerGenerator Kind Color ID}
		case Kind
		of player then {Player.portPlayer Color ID}
		end
	end
end
