functor
import
	Player
	PlayerBasicAI
	Player095RandomAI
	Player095XxD4rkPulv3r1sat0rxX
	Player044TireMINEaTord
export
	playerGenerator:PlayerGenerator
define
	PlayerGenerator
in
	fun{PlayerGenerator Kind Color ID}
		case Kind
		of player then {Player.portPlayer Color ID}
		[] playerBasicAI then {PlayerBasicAI.portPlayer Color ID}
		[] randomAI then {Player095RandomAI.portPlayer Color ID}
		[] xxD4rkPulv3r1sat0rxX then {Player095XxD4rkPulv3r1sat0rxX.portPlayer Color ID}
		[] player044TireMINEaTord then {Player044TireMINEaTord.portPlayer Color ID}
		end
	end
end
