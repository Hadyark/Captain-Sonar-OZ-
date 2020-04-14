functor
import
    GUI
    Input
    PlayerManager
    System
define
    PortGui
    PortPlayers

    CreatePlayer
    AskPosition
in
%%% 1) Create the port for the GUI and launch its interface
   PortGui = {GUI.portWindow}
   {Send PortGui buildWindow}

%%% 2) Create the port for every player using the PlayerManager and assign 
%%% a unique id between 1 and Input.nbPlayer (< idnum >). The ids are given 
%%% in the order they are defined in the input file end
   fun {CreatePlayer Count}
      if Count > Input.nbPlayer then nil
      else
	      {PlayerManager.playerGenerator {List.nth Input.players Count} {List.nth Input.colors Count} Count} | {CreatePlayer Count+1}
      end
   end

   PortPlayers = {CreatePlayer 1}
%%% 3) Ask every player to set up (choose its initial point, 
%%% they all are at the surface at this time)
   proc {AskPosition Players}
      ID
      Position
      in

      case Players
      of nil then skip
      [] PPlayer|T then
         {Send PPlayer initPosition(ID Position)}
         {Send PortGui initPlayer(ID Position)}
         {AskPosition T}
      end
   end

   {AskPosition PortPlayers}

%%% 4) When every player has set up, launch the game 
%%% (either in turn by turn or in simultaneous mode, 
%%% as specified by the input file)

end
