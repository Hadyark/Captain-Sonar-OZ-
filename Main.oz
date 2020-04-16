functor
import
    GUI
    Input
    PlayerManager
    System
define
    PortGui
    Players

    CreatePlayer
    AskPosition
    AskCharge
    AskFire
    AskFireMine
    Broadcast
    AskMove
    PlayTurn
   TurnByTurn

in
%%% 1) Create the port for the GUI and launch its interface
   PortGui = {GUI.portWindow}
   {Send PortGui buildWindow}

%%% 2) Create the port for every player using the PlayerManager and assign 
%%% a unique id between 1 and Input.nbPlayer (< idnum >). The ids are given 
%%% in the order they are defined in the input file end
   fun {CreatePlayer Count Players} 
      Port 
      PlayersUpdated
   in
      if Count > Input.nbPlayer then Players
      else
         Port = {PlayerManager.playerGenerator {List.nth Input.players Count} {List.nth Input.colors Count} Count}
         PlayersUpdated = {AdjoinList  Players [Count#submarine(id: Count turnSurface:Input.turnSurface port:Port)]}
	      {CreatePlayer Count+1 PlayersUpdated}
      end
   end

   Players = {CreatePlayer 1 players()}

%%% 3) Ask every player to set up (choose its initial point, 
%%% they all are at the surface at this time)
   proc {AskPosition Players Count}
      ID
      Position
   in
      if Count > Input.nbPlayer then skip
      else
         {Send Players.Count.port initPosition(ID Position)}
         {System.show main(func: askPosition msg:position var:Position)}
         {Send PortGui initPlayer(ID Position)}

         {AskPosition Players Count+1}
      end
   end

   {AskPosition Players 1}

%%% 4) When every player has set up, launch the game 
%%% (either in turn by turn or in simultaneous mode, 
%%% as specified by the input file)

   proc{Broadcast Count Mess}
      Message
      Dammage
      Position
      ID
      IDTouch
      LifeLeft
      Answer
      Drone
      Mine
   in 
      if Count > Input.nbPlayer then {System.show main(func: broadcast msg:done)}
      else
         case Mess
         of sayMissileExplode(ID Position) then
            {Send Players.Count.port sayMissileExplode(ID Position Message)}
            case Message
            of null then skip
            [] sayDeath(IDTouch) then {Broadcast 1 sayDeath(IDTouch)}
            [] sayDamageTaken(IDTouch Damage LifeLeft) then
               {Send Players.(ID.id).port Message}
            end
         [] sayMineExplode(ID Mine) then
            {Send Players.Count.port sayMineExplode(ID Mine Message)}
            {System.show main(func: broadcast msg:mineExplode var:Message)}
            case Message
            of null then skip
            [] sayDeath(IDTouch) then {Broadcast 1 sayDeath(IDTouch)}
            [] sayDamageTaken(IDTouch Damage LifeLeft) then
               {Send Players.(ID.id).port Message}
            end
         [] sayPassingDrone(KindFire) then
            {Send Players.Count.port sayPassingDrone(KindFire ID Answer)}
            {Send Players.(ID.id).port sayAnswerDrone(Drone ID Answer)}
         [] sayPassingSonar then
            {Send Players.Count.port sayPassingSonar(ID Answer)}
            {Send Players.(ID.id).port sayAnswerSonar(ID Answer)}
         [] sayDeath(IDTouch) then
            {System.show main(func: broadcast msg:sayDeath var:IDTouch)}
            {Send Players.Count.port Mess}
         else
            {Send Players.Count.port Mess}
         end
         {Broadcast Count+1 Mess}
      end
   end
   %6 The submarine is now authorised to charge an item.
   proc {AskCharge Player}
      ID
      KindItem
   in
      {Send Player.port chargeItem(ID KindItem)}
      case KindItem 
      of null then {System.show main(func: askCharge msg:kindItem var:null)}
      [] _ then
         {System.show main(func: askCharge msg:kindItem var:KindItem)}
         {Broadcast 1 sayCharge(ID KindItem)}
      end
   end
   %7 The submarine is now authorised to fire an item.
   proc {AskFire Player}
      ID
      KindFire
   in 
      {Send Player.port fireItem(ID KindFire)}
  
      case KindFire
      of null then {System.show main(func: askFire msg:kindFire var:KindFire)}
      [] mine(_) then 
         {System.show main(func: askFire msg:mine var:KindFire)}
         {Broadcast 1 sayMinePlaced(ID)}
      [] missile(Position) then 
         {System.show main(func: askFire msg:missile var:KindFire)}
         {Broadcast 1 sayMissileExplode(ID Position)}
      [] drone(_) then 
         {System.show main(func: askFire msg:drone var:KindFire)}
         {Broadcast 1 sayPassingDrone(KindFire)}
      [] sonar then 
         {System.show main(func: askFire msg:sonar var:KindFire)}
         {Broadcast 1 sayPassingSonar}
      else
         {System.show main(func: askFire msg:kindFire var:KindFire)}
      end
   end
   proc{AskFireMine Player}
      ID
      Mine
   in
      {Send Player.port fireMine(ID Mine)}
      case Mine
      of null then {System.show main(func: askFireMine msg:mine var:Mine)}
      [] mine(_) then 
         {System.show main(func: askFireMine msg:mine var:Mine)}
         {Broadcast 1 sayMineExplode(ID Mine)}
      end
   end
   %3 Ask the submarine to choose its direction
   fun {AskMove Player}
      ID 
      Position
      Direction
      PlayerUpdated
      Answer
   in
      {Send Player.port move(ID Position Direction)}
      %4 Surface has been chosen
      if Direction == surface then
         {Broadcast 1 saySurface(ID)}
         {Send PortGui surface(ID)}
         PlayerUpdated = {AdjoinList Player [turnSurface#1]}
         {System.show main(func: askFire msg:5)}
      %5 The chosen direction is broadcast
      else
         {System.show main(func: askMove msg:broadcastDirection player: ID var:Direction)}
         {Broadcast 1 sayMove(ID Direction)}
         {Send PortGui movePlayer(ID Position)}
         {System.show main(func: askMove msg:askMoveDone)}
         %Go 6
         {AskCharge Player}{System.show main(func: askMove msg:askChargeDone)}
         %Go 7
         {AskFire Player}{System.show main(func: askMove msg:askFireDone)}
         %8
         {AskFireMine Player}{System.show main(func: askMove msg:askFireMineDone)}
         
         PlayerUpdated = Player
      end
      PlayerUpdated
   end
  
   %Turn for one player
   fun {PlayTurn Player}
      FirstUpdate
      PlayersUpdated
   in
      {System.show main(func: playTurn msg:playerTurn var:Player.id)}
      if Player.turnSurface == 0 then 
         %Go 3
         PlayersUpdated = {AskMove Player}
         {System.show main(func: playTurn msg:endd)}
      else 
         if Player.turnSurface == Input.turnSurface then 
            {Send Player.port dive}
            FirstUpdate = {AdjoinList Player [turnSurface#0]}
            %Go 3
            PlayersUpdated = {AskMove Player}
            {System.show main(func: playTurn msg:endd)}
         else
            PlayersUpdated = {AdjoinList Player [turnSurface#Player.turnSurface+1]}
            {System.show main(func: playTurn msg:endd)}
         end
      end
      PlayersUpdated
   end

   proc {TurnByTurn Count Players NDeath} 
      PlayersUpdated
      IsDead
   in
      {System.show main(func: turnByTurn msg:countAndnDeath vCount:Count vDeath:NDeath)}
      if NDeath == Input.nbPlayer -1 then {System.show main(func: turnByTurn msg:winnerIs var: Count)}
      else
         {Send Players.Count.port isDead(IsDead)}
         if IsDead then
            {TurnByTurn Count+1 Players NDeath+1}
         else 
            PlayersUpdated = {AdjoinList Players [Count#{PlayTurn Players.Count}]}
            {System.show main(func: turnByTurn msg:nextPlayer)}
            if Count == Input.nbPlayer then {TurnByTurn 1 PlayersUpdated 0}
            else {TurnByTurn Count+1 PlayersUpdated 0}
            end
         end
      end
   end
   {TurnByTurn 1 Players 0}
end