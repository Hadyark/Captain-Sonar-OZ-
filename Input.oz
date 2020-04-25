functor
import
	OS
export
   isTurnByTurn:IsTurnByTurn
   nRow:NRow
   nColumn:NColumn
   map:Map
   nbPlayer:NbPlayer
   players:Players
   colors:Colors
   thinkMin:ThinkMin
   thinkMax:ThinkMax
   turnSurface:TurnSurface
   maxDamage:MaxDamage
   missile:Missile
   mine:Mine
   sonar:Sonar
   drone:Drone
   minDistanceMine:MinDistanceMine
   maxDistanceMine:MaxDistanceMine
   minDistanceMissile:MinDistanceMissile
   maxDistanceMissile:MaxDistanceMissile
   guiDelay:GUIDelay
define
   IsTurnByTurn
   NRow
   NColumn
   Map
   NbPlayer
   Players
   Colors
   ThinkMin
   ThinkMax
   TurnSurface
   MaxDamage
   Missile
   Mine
   Sonar
   Drone
   MinDistanceMine
   MaxDistanceMine
   MinDistanceMissile
   MaxDistanceMissile
   GUIDelay

   GenerateMap
   NewRow
   PickMap
in

%%%% Style of game %%%%

   IsTurnByTurn = true

%%%% Description of the map %%%%

   NRow = 10
   NColumn = 10

   fun {NewRow Row1 Row2}
        [Row1.1 Row1.2.1 Row1.2.2.1 Row1.2.2.2.1 Row1.2.2.2.2.1 Row2.1 Row2.2.1 Row2.2.2.1 Row2.2.2.2.1 Row2.2.2.2.2.1]
    end
   fun {GenerateMap Map1 Map2 Map3 Map4}
        [
        {NewRow Map1.1 Map2.1}
        {NewRow Map1.2.1 Map2.2.1}
        {NewRow Map1.2.2.1 Map2.2.2.1}
        {NewRow Map1.2.2.2.1 Map2.2.2.2.1}
        {NewRow Map1.2.2.2.2.1 Map2.2.2.2.2.1}
        {NewRow Map3.1 Map4.1}
        {NewRow Map3.2.1 Map4.2.1}
        {NewRow Map3.2.2.1 Map4.2.2.1}
        {NewRow Map3.2.2.2.1 Map4.2.2.2.1}
        {NewRow Map3.2.2.2.2.1 Map4.2.2.2.2.1}
        ]
    end
    fun {PickMap}
        ListMap
      in
         ListMap = [
            [[0 0 0 0 0]
            [0 1 1 0 1]
            [0 0 1 0 1]
            [0 0 1 0 0]
            [0 0 0 0 0]]

            [[0 1 0 0 0]
            [0 0 0 0 0]
            [0 0 1 0 1]
            [0 1 1 0 0]
            [0 1 0 0 0]]

            [[0 0 0 0 0]
            [0 0 1 1 0]
            [0 0 1 1 0]
            [0 1 0 0 0]
            [0 0 0 0 0]]

            [[0 0 0 0 0]
            [0 1 1 1 0]
            [0 0 0 0 0]
            [0 0 1 1 0]
            [0 1 1 0 0]]

            [[0 0 1 0 0]
            [1 0 1 0 0]
            [1 0 0 0 0]
            [0 1 0 1 0]
            [0 0 0 0 0]]

            [[0 0 1 1 0]
            [0 1 0 0 0]
            [0 0 0 1 0]
            [1 0 1 0 0]
            [0 0 1 0 0]]

            [[0 0 0 1 0]
            [0 0 1 0 0]
            [0 1 1 1 0]
            [0 0 1 0 0]
            [0 0 0 0 0]]

            [[0 0 0 0 0]
            [0 1 1 0 0]
            [0 0 1 1 1]
            [0 0 0 0 0]
            [0 1 0 0 0]]

            [[0 0 0 0 0]
            [0 0 1 0 0]
            [0 1 0 0 0]
            [1 0 0 1 0]
            [0 0 0 0 0]]

            [[0 0 0 0 0]
            [0 1 0 1 0]
            [0 0 0 1 0]
            [0 1 0 1 0]
            [0 0 0 0 0]]
         ]
        {List.nth ListMap ({OS.rand} mod ({List.length ListMap}) + 1 )}
    end
    Map={GenerateMap {PickMap} {PickMap} {PickMap} {PickMap}}

%%%% Players description %%%%

   NbPlayer = 5
   Players = [playerBasicAI playerBasicAI randomAI randomAI xxD4rkPulv3r1sat0rxX] %playerBasicAI player
   Colors = [red green blue black grey]

%%%% Thinking parameters (only in simultaneous) %%%%

   ThinkMin = 500
   ThinkMax = 3000

%%%% Surface time/turns %%%%

   TurnSurface = 3

%%%% Life %%%%

   MaxDamage = 4

%%%% Number of load for each item %%%%

   Missile = 3
   Mine = 3
   Sonar = 3
   Drone = 3

%%%% Distances of placement %%%%

   MinDistanceMine = 1
   MaxDistanceMine = 2
   MinDistanceMissile = 1
   MaxDistanceMissile = 4

%%%% Waiting time for the GUI between each effect %%%%

   GUIDelay = 500 % ms

end
