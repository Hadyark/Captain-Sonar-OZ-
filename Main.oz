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

   proc{Broadcast Mess PortSender Receiver}
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
      if Receiver > Input.nbPlayer then {System.show main(func: broadcast msg:done)}
      else
         case Mess
         of sayMissileExplode(ID Position) then
            {Send Players.Receiver.port sayMissileExplode(ID Position Message)}
            case Message
            of null then skip
            [] sayDeath(IDTouch) then {Broadcast sayDeath(IDTouch) PortSender 1}
            [] sayDamageTaken(IDTouch Damage LifeLeft) then
               {Send PortSender Message}
               {Send PortGui lifeUpdate(IDTouch LifeLeft)}
               {System.show main(func: broadcast msg:touched var:Message)}
            end
         [] sayMineExplode(ID Mine) then
            {Send Players.Receiver.port sayMineExplode(ID Mine Message)}
            {System.show main(func: broadcast msg:touched var:Message)}
            case Message
            of null then skip
            [] sayDeath(IDTouch) then 
               {Broadcast sayDeath(IDTouch) PortSender 1}
               {Send PortGui removePlayer(IDTouch)}
               {Send PortGui lifeUpdate(IDTouch LifeLeft)}
            [] sayDamageTaken(IDTouch Damage LifeLeft) then
               {Send PortSender Message}
               {Send PortGui lifeUpdate(IDTouch LifeLeft)}
               {System.show main(func: broadcast msg:done)}
            end
         [] sayPassingDrone(KindFire) then
            {Send Players.Receiver.port sayPassingDrone(KindFire IDTouch Answer)}
            {Send PortSender sayAnswerDrone(KindFire IDTouch Answer)}
         [] sayPassingSonar then
            {Send Players.Receiver.port sayPassingSonar(IDTouch Answer)}
            {Send PortSender sayAnswerSonar(IDTouch Answer)}
         [] sayDeath(IDTouch) then
            {System.show main(func: broadcast msg:sayDeath var:IDTouch)}
            {Send Players.Receiver.port Mess}
         else
            {Send Players.Receiver.port Mess}
         end
         {Broadcast Mess PortSender Receiver+1 }
      end
   end
   %6 The submarine is now authorised to charge an item.
   proc {AskCharge Player}
      ID
      KindItem
      IsDead
   in
      {Send Player.port isDead(IsDead)}
      if IsDead == false then
         {Send Player.port chargeItem(ID KindItem)}
         case KindItem 
         of null then {System.show main(func: askCharge msg:kindItem var:null)}
         [] _ then
            {System.show main(func: askCharge msg:kindItem var:KindItem)}
            {Broadcast sayCharge(ID KindItem) Player.port 1}
         end
      end
   end
   %7 The submarine is now authorised to fire an item.
   proc {AskFire Player}
      ID
      KindFire
      IsDead
   in 
      {Send Player.port isDead(IsDead)}
      if IsDead == false then
         {Send Player.port fireItem(ID KindFire)}
         case KindFire
         of null then {System.show main(func: askFire msg:kindFire var:KindFire)}
         [] pt(x:X y:Y) then 
            {System.show main(func: askFire msg:fmine var:KindFire)}
            {Broadcast sayMinePlaced(ID) Player.port 1 }
            {Send PortGui putMine(ID KindFire)}
         [] missile(Position) then 
            {System.show main(func: askFire msg:fmissile var:KindFire)}
            {Broadcast sayMissileExplode(ID Position) Player.port 1 }
            {Send PortGui explosion(ID Position)}
         [] drone(Line Coord) then 
            {System.show main(func: askFire msg:fdrone var:KindFire)}
            {Broadcast sayPassingDrone(KindFire) Player.port 1 }
            {Send PortGui drone(ID KindFire)}
         [] sonar then 
            {System.show main(func: askFire msg:fsonar var:KindFire)}
            {Broadcast sayPassingSonar Player.port 1 }
            {Send PortGui sonar(ID)}
         else
            {System.show main(func: askFire msg:kindFire var:KindFire)}
         end
      end
   end
   proc{AskFireMine Player}
      ID
      Mine
      IsDead
   in
      {Send Player.port isDead(IsDead)}
      if IsDead == false then
         {Send Player.port fireMine(ID Mine)}
         case Mine
         of null then {System.show main(func: askFireMine msg:mine var:Mine)}
         [] pt(x:X y:Y) then 
            {Broadcast sayMineExplode(ID Mine) Player.port 1 }
            {Send PortGui explosion(ID Mine)}
            {Send PortGui removeMine(ID Mine)}
         end
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
         {Broadcast saySurface(ID) Player.port 1}
         {Send PortGui surface(ID)}
         PlayerUpdated = {AdjoinList Player [turnSurface#1]}
         {System.show main(msg:playerIsSurface)}
         {Delay 200}
      %5 The chosen direction is broadcast
      else
         {System.show main(func: askMove msg:broadcastDirection player: ID vPos: Position var:Direction)}
         {Broadcast sayMove(ID Direction) Player.port 1}
         {Send PortGui movePlayer(ID Position)}
         {System.show main(msg:askMoveDone)}
         {Delay 200}
         %Go 6
         {AskCharge Player}{System.show main(msg:askChargeDone)}
         {Delay 200}
         %Go 7
         {AskFire Player}{System.show main(msg:askFireDone)}
         {Delay 200}
         %8
         {AskFireMine Player}{System.show main(msg:askFireMineDone)}
         {Delay 200}
         
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
      IsCurrentDead
      CountUpdated
      NDeathUpdated
   in
      {Delay 500}
      {System.show main(msg:newTurn vCount:Count vDeath:NDeath)}
      if NDeath == Input.nbPlayer -1 then {System.show main(func: turnByTurn msg:winnerIs var: Count)}
      else
         {Send Players.Count.port isDead(IsDead)}
         if IsDead then
            if Count == Input.nbPlayer then CountUpdated = 1
            else CountUpdated = Count + 1 end
            {TurnByTurn CountUpdated Players NDeath+1}
         else 
            PlayersUpdated = {AdjoinList Players [Count#{PlayTurn Players.Count}]}
            {Send PlayersUpdated.Count.port isDead(IsCurrentDead)}
            if Count == Input.nbPlayer then CountUpdated = 1
            else CountUpdated = Count + 1 end
            if IsCurrentDead then NDeathUpdated = NDeath +1
            else NDeathUpdated = 0 end
            {TurnByTurn CountUpdated Players NDeathUpdated}
         end
      end
   end
   {Delay 3000}
   {TurnByTurn 1 Players 0}
end