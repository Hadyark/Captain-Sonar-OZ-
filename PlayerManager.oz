functor
import
	Player
	PlayerBasicAI
export
	playerGenerator:PlayerGenerator
define
	PlayerGenerator
in
	fun{PlayerGenerator Kind Color ID}
		case Kind
		of player then {Player.portPlayer Color ID}
		[] playerBasicAI then {PlayerBasicAI.portPlayer Color ID}
		end
	end
end
