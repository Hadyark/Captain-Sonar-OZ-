functor
import
    GUI
    Input
    PlayerManager
    OS
    System
define
    PlayerPort
    Port
    NewPlayer
    LoadPlayer
in
    Port = {GUI.portWindow}
   {Send Port buildWindow}
   fun {NewPlayer Count}
      if Count > Input.nbPlayer then nil
      else
     {PlayerManager.playerGenerator {List.nth Input.players Count} {List.nth Input.colors Count} Count} | {NewPlayer Count+1}
      end
   end

   proc {LoadPlayer PlayerPort}
      ID
      Pos
   in
      case PlayerPort of nil then skip
     [] H|T then
     {Send H initPosition(ID Pos)}
     {Send Port initPlayer(ID Pos)}
     {LoadPlayer T}
      end
   end
%%%%%%%%%%%%%%%%Start Game %%%%%%%%%%%%%%%%%%%%%%%%%%
   PlayerPort = {NewPlayer 1}
   {LoadPlayer PlayerPort}


end
