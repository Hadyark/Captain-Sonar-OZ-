functor
import
	Player
	PlayerBasicAI
	RandomAI
	XxD4rkPulv3r1sat0rxX
export
	playerGenerator:PlayerGenerator
define
	PlayerGenerator
in
	fun{PlayerGenerator Kind Color ID}
		case Kind
		of player then {Player.portPlayer Color ID}
		[] playerBasicAI then {PlayerBasicAI.portPlayer Color ID}
		[] randomAI then {RandomAI.portPlayer Color ID}
		[] xxD4rkPulv3r1sat0rxX then {XxD4rkPulv3r1sat0rxX.portPlayer Color ID}
		end
	end
end
