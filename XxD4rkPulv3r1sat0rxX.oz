functor
import
    Input
    OS
    System
export
    portPlayer:StartPlayer
define
    StartPlayer
    TreatStream

    %%% FUNCTION / PROCEDURE %%%
    InitPosition
    Move
    Dive
    CanMove
    ChargeItem
    FireItem
    FireMine
    IsDead
    SayMove
    SaySurface
    SayCharge
    SayMinePlaced
    SayMissileExplode
    SayMineExplode
    SayPassingDrone
    SayAnswerDrone
    SayPassingSonar
    SayAnswerSonar
    SayDeath
    SayDamageTaken

    InitSubmarine
    IsWater
    IsNotVisited
    UpdateEnemy
    DistanceDammage

    %%% ADVANCED AI
    GeneratePossiblesPositions
    ValidPath
    CheckPoints
    RemovePoint
    CheckPositionsEvery
    FirePosition
    UpdatePossiblesPositions

    ShortestPath
    GetPath
in
      
%%% Initialize submarine
    fun {InitSubmarine Color ID}
        Submarine
        in
        Submarine = submarine(
            id: id(id: ID color: Color name: xxD4rkPulv3r1sat0rxx)
            turnSurface: Input.turnSurface
            visited: nil
            missile:0 
            mine:0 
            sonar:0 
            drone:0
            mines: nil
            life: Input.maxDamage
            enemies: enemies()
            sonarLaunched:0
            lastMissile:pt(x:0 y:0)
        )
        Submarine
    end  
%%% Initialize position submarine
    fun {InitPosition ID Position Submarine} 
        Pos
        SubmarineUpdated
        Bool
        in
        Pos = pt(x:({OS.rand} mod (Input.nRow) + 1 ) y:({OS.rand} mod (Input.nColumn) + 1 ))
        Bool= {IsWater Pos}
        if Bool then
            ID = Submarine.id
            Position = Pos
            SubmarineUpdated = {AdjoinList Submarine [pt#Position]}
            SubmarineUpdated
        else
            {InitPosition ID Position Submarine} 
        end
    end
%%% IsWater - Check is case contains water
    fun{IsWater Position}
        if Position.x > 0 andthen Position.x =< Input.nRow then 
            if Position.y > 0 andthen Position.y =< Input.nColumn then
                if {List.nth {List.nth Input.map Position.x} Position.y} == 0 then
                    true
                else
                    false
                end
            else
                false
            end
        else
            false
        end
        
    end
%%% IsNotVisited - Check if the case has been already visited
    fun{IsNotVisited Visited Position}
        if Visited == nil then
            true
        else 
            if Visited.1.x == Position.x andthen Visited.1.y == Position.y then 
                false
            else {IsNotVisited Visited.2 Position}
            end
        end
    end
%%% CanMove - Possible Move
    fun{CanMove Submarine Directions}
        Pt
        in
        case Directions 
        of nil then nil
        [] east | T then
            Pt = pt(x:(Submarine.pt.x) y:(Submarine.pt.y+1))
            if {IsWater Pt} andthen {IsNotVisited Submarine.visited Pt} then
                    east | {CanMove Submarine T} 
            else {CanMove Submarine T}
            end
        [] north | T then
            Pt = pt(x:(Submarine.pt.x-1) y:(Submarine.pt.y))
            if {IsWater Pt} andthen {IsNotVisited Submarine.visited Pt} then
                    north | {CanMove Submarine T} 
            else {CanMove Submarine T}
            end
        [] south | T then
            Pt = pt(x:(Submarine.pt.x+1) y:(Submarine.pt.y))
            if {IsWater Pt} andthen {IsNotVisited Submarine.visited Pt} then                
                south | {CanMove Submarine T} 
            else {CanMove Submarine T}
            end
        [] west | T then
            Pt = pt(x:(Submarine.pt.x) y:(Submarine.pt.y-1))
            if {IsWater Pt} andthen {IsNotVisited Submarine.visited Pt} then
                west | {CanMove Submarine T} 
            else {CanMove Submarine T}
            end
        [] surface | T then 
            if Submarine.visited == nil then
                {CanMove Submarine T}
            else
                surface | {CanMove Submarine T}
            end
        end
    end
%%% Move - submarine
    fun {Move ID Position Direction Submarine} 
        Visit
        SubmarineUpdated
        PossibleDirection
        PositionsIsRange
        Possibles
        NextPos
        Dir
        Shortest
        MyPoint
        in
        %Create list with every players's position
        Possibles = {CheckPositionsEvery Submarine.enemies 1 1} 
        {System.show movePossible(Possibles)}
        %Get if possition is within range
        PositionsIsRange = {FirePosition Possibles Submarine Input.minDistanceMissile 4}
        {System.show iAm(Submarine.id.color)}
        {System.show moveIsRange(PositionsIsRange Submarine.missile)}
        %If i have a missile and if I am not within range to fire someone and if I am not too close (Distance >3) -> need move fast
        if Submarine.missile == Input.missile andthen PositionsIsRange == nil
        andthen Possibles \= nil andthen {Abs (Submarine.pt.x - Possibles.1.x)} + {Abs (Submarine.pt.y - Possibles.1.y)} > 3 then
            {System.show beforeShortestPath}
            %get the shortest path
            MyPoint = [pt(x: Submarine.pt.x y: Submarine.pt.y id:(((Submarine.pt.x)*100)+(Submarine.pt.y)) prev:null)]
            Shortest = {ShortestPath Possibles.1 MyPoint visited()}
            %if a path exist
            {System.show Shortest}
            {System.show ((Possibles.1.x)*100)+(Possibles.1.y)}
            if {Value.hasFeature Shortest ((Possibles.1.x)*100)+(Possibles.1.y)} then
                %Get the next posistion
                NextPos ={List.last {GetPath Shortest ((Possibles.1.x)*100)+(Possibles.1.y)} }
                {System.show nextPos(NextPos)}
                %if the next position is not visited -> get the next direction
                if {IsNotVisited Submarine.visited NextPos} then
                    {System.show notVisited}
                    if NextPos.x == Submarine.pt.x     andthen NextPos.y == Submarine.pt.y+1  then Dir=east end
                    if NextPos.x == Submarine.pt.x-1   andthen NextPos.y == Submarine.pt.y    then Dir=north end
                    if NextPos.x == Submarine.pt.x+1   andthen NextPos.y == Submarine.pt.y    then Dir=south end
                    if NextPos.x == Submarine.pt.x     andthen NextPos.y == Submarine.pt.y-1  then Dir=west end
                    {System.show dir(Dir)}
                else {System.show visitedGoSurface} Dir=surface
                end
            %if a path doesn't exist -> random position
            else
                PossibleDirection = {CanMove Submarine [east north south west east north south west east north south west surface ]}
                Dir = {List.nth PossibleDirection ({OS.rand} mod ({List.length PossibleDirection}) + 1 )}
            end
            %{Delay 10000}
        %If i have not a missile or if I am within range -> Random direction  
        else
            PossibleDirection = {CanMove Submarine [east north south west east north south west east north south west surface ]}
            Dir = {List.nth PossibleDirection ({OS.rand} mod ({List.length PossibleDirection}) + 1 )}
        end

        case Dir
        of surface then
            SubmarineUpdated = {AdjoinList Submarine [turnSurface#1 visited#nil]}
        else 
            case Dir 
            of east then Position = pt(x:(Submarine.pt.x) y:(Submarine.pt.y+1)) 
            [] north then Position = pt(x:(Submarine.pt.x-1) y:(Submarine.pt.y)) 
            [] south then Position = pt(x:(Submarine.pt.x+1) y:(Submarine.pt.y)) 
            [] west then Position = pt(x:(Submarine.pt.x) y:(Submarine.pt.y-1)) 
            end
            Visit = Submarine.pt | Submarine.visited
            SubmarineUpdated = {AdjoinList Submarine [pt#Position turnSurface#0 visited#Visit]} 

        end
        ID = Submarine.id
        Direction = Dir
        SubmarineUpdated
    end
%%% Dive
    fun {Dive Submarine}
        {AdjoinList Submarine [turnSurface#0]}
    end
%%% ChargeItem
    fun {ChargeItem ID KindItem Submarine} 
        Item
        SubmarineUpdated
        in
        if Submarine.sonarLaunched == 0 then
            Item = sonar
        else 
            Item = missile
        end
        case Item 
        of missile then
            if Submarine.missile == Input.missile then
                KindItem = null
                SubmarineUpdated = Submarine
            else
                SubmarineUpdated = {AdjoinList Submarine [missile#Submarine.missile+1]}
                if SubmarineUpdated.missile == Input.missile then
                    KindItem = missile
                else 
                    KindItem = null 
                end
            end
        [] mine then 
            if Submarine.mine == Input.mine then
                KindItem = null
                SubmarineUpdated = Submarine
            else
                SubmarineUpdated = {AdjoinList Submarine [mine#Submarine.mine+1]}
                if SubmarineUpdated.mine == Input.mine then
                    KindItem = mine
                else KindItem = null end
            end
        [] sonar then 
            if Submarine.sonar == Input.sonar then
                KindItem = null
                SubmarineUpdated = Submarine
            else
                SubmarineUpdated = {AdjoinList Submarine [sonar#Submarine.sonar+1]}
                if SubmarineUpdated.sonar == Input.sonar then
                    KindItem = sonar
                else KindItem = null end
            end
        [] drone then 
            if Submarine.drone == Input.drone then
                KindItem = null
                SubmarineUpdated = Submarine
            else
                SubmarineUpdated = {AdjoinList Submarine [drone#Submarine.drone+1]}
                if SubmarineUpdated.drone == Input.drone then
                    KindItem = drone
                else KindItem = null end
            end
        else
            KindItem = null
            SubmarineUpdated = Submarine
        end
        ID = Submarine.id
        SubmarineUpdated
    end
%%% FireItem
    fun {FireItem ID FireItem Submarine } 
        Item
        SubmarineUpdated
        Position
        Possibles
        in
        Possibles = {CheckPositionsEvery Submarine.enemies 1 1} 
        {System.show fireItem(Possibles)}
        Position = {FirePosition Possibles Submarine Input.minDistanceMissile Input.maxDistanceMissile}
        {System.show fireItem(Position)}
        if Submarine.missile == Input.missile then
            if Position == nil then
                Item = null
            else
                Item = missile
            end
        else 
            if Submarine.sonar == Input.sonar then
                Item = sonar
            else Item = null
            end
        end
        case Item 
        of missile then
            FireItem = missile(Position)
            SubmarineUpdated = {AdjoinList Submarine [missile#0 lastMissile#Position]}
        [] sonar then 
            FireItem = sonar
            SubmarineUpdated = {AdjoinList Submarine [sonar#0 sonarLaunched#Submarine.sonarLaunched+1]}
        else
            FireItem = null
            SubmarineUpdated = Submarine
        end
        ID = Submarine.id
        SubmarineUpdated
    end
%%% FireMine
    fun {FireMine ID Mine Submarine}
        SubmarineUpdated
        in
        ID= Submarine.id
        case Submarine.mines
        of nil then
            Mine = null
            SubmarineUpdated = Submarine
        [] H | T then
            Mine = H
            SubmarineUpdated = {AdjoinList Submarine [mines#T]}
        end
        SubmarineUpdated
    end    
%%% IsDead
    fun {IsDead Answer Submarine}
        Answer = Submarine.life < 1
        Submarine
    end
%%% UpdateEnemy
    fun {UpdateEnemy ID Submarine Data}
        Up
        Updated
        Enemy
        Enemies
        in  
        if ID == Submarine.id then Submarine
        else
            if {Value.hasFeature Submarine.enemies (ID.id)} == false then
                Up = {AdjoinList Submarine.enemies [(ID.id)#enemy(id:ID visited:nil nbMines:0 missile:0 sonar:0 drone:0 possiblesPositions:nil)]}
                Updated = {AdjoinList Submarine [enemies#Up]}
            else
                Updated = Submarine
            end
            Enemy =   {AdjoinList Updated.enemies.(ID.id) Data}
            Enemies = {AdjoinList Updated.enemies [(ID.id)#Enemy]}
            {AdjoinList Updated [enemies#Enemies]}
        end
    end
%%% SayMove
    fun {SayMove ID Direction Submarine}
        EnemyDirection
        UpdatedPossiblesPositions
        in
        if ID == Submarine.id then Submarine
        else
            if {Value.hasFeature Submarine.enemies (ID.id)} == false then
                EnemyDirection = Direction | nil
                UpdatedPossiblesPositions = nil
            else
                EnemyDirection = Direction | Submarine.enemies.(ID.id).visited
                UpdatedPossiblesPositions = {UpdatePossiblesPositions Direction Submarine.enemies.(ID.id).possiblesPositions}
            end
            {UpdateEnemy ID Submarine [visited#EnemyDirection possiblesPositions#UpdatedPossiblesPositions]}
        end
    end
%%% SaySurface
    fun {SaySurface ID Submarine}
        {UpdateEnemy ID Submarine [surface#true]}
    end
%%% SayCharge
    fun {SayCharge ID KindItem Submarine}
        {UpdateEnemy ID Submarine [KindItem#true]}
    end
%%% SayMinePlaced
    fun {SayMinePlaced ID Submarine}
        if ID == Submarine.id then Submarine
        else
            if {Value.hasFeature Submarine.enemies (ID.id)} == false then
                {UpdateEnemy ID Submarine [nbMines#0]}
            else
                {UpdateEnemy ID Submarine [nbMines#Submarine.enemies.(ID.id).nbMines+1]}
            end
        end
    end
%%% DistanceDammage
    fun {DistanceDammage Position Message Submarine}
        Distance
        SubmarineUpdated 
        in
        Distance = {Abs (Submarine.pt.x - Position.x)} + {Abs (Submarine.pt.y - Position.y)}
        if Distance > 1 then
            SubmarineUpdated = Submarine
            Message = null
        else    
            if Distance == 1 then
                SubmarineUpdated = {AdjoinList Submarine [life#Submarine.life-1]}
                if SubmarineUpdated.life < 1 then Message = sayDeath(SubmarineUpdated.id)
                else Message = sayDamageTaken(SubmarineUpdated.id 1 SubmarineUpdated.life) end
            else
                SubmarineUpdated = {AdjoinList Submarine [life#Submarine.life-2]}
                if SubmarineUpdated.life < 1 then Message = sayDeath(SubmarineUpdated.id)
                else Message = sayDamageTaken(SubmarineUpdated.id 2 SubmarineUpdated.life) end
            end
        end
        SubmarineUpdated
    end
%%% SayMissileExplode
    fun {SayMissileExplode ID Position Message Submarine}
        {DistanceDammage Position Message {UpdateEnemy ID Submarine [missile#false]}}
    end
%%% SayMineExplode
    fun {SayMineExplode ID Position Message Submarine}
        if ID == Submarine.id then
            {DistanceDammage Position Message Submarine}
        else
            {DistanceDammage Position Message {UpdateEnemy ID Submarine [nbMines#Submarine.enemies.(ID.id).nbMines-1]}}
        end
    end
%%% SayPassingDrone
    fun {SayPassingDrone Drone ID Answer Submarine}
        ID = Submarine.id
        case Drone
        of drone(row X) then
            if Submarine.pt.x == X then
                Answer = true
            else
                Answer = false
            end
        [] drone(column Y) then
            if Submarine.pt.y == Y then
                Answer = true
            else
                Answer = false
            end
        end
        Submarine
    end
%%% SayAnswerDrone
    fun {SayAnswerDrone Drone ID Answer Submarine}
        SubmarineUpdated
        in
        case Drone
        of drone(row X) then
            SubmarineUpdated = {UpdateEnemy ID Submarine [lastX#X]}
        [] drone(column Y) then
            SubmarineUpdated = {UpdateEnemy ID Submarine [lastY#Y]}
        else
            SubmarineUpdated = Submarine
        end
        SubmarineUpdated
    end
%%% SayPassingSonar
    fun {SayPassingSonar ID Answer Submarine}
        ID = Submarine.id
        if ({OS.rand} mod 2) == 1 then
            Answer = pt(x:Submarine.pt.x y:({OS.rand} mod (Input.nColumn) + 1 ))
        else
            Answer = pt(x:({OS.rand} mod (Input.nRow) + 1 ) y:Submarine.pt.y)
        end
        Submarine
    end
%%% SayAnswerSonar
    fun {SayAnswerSonar ID Answer Submarine}
        if ID.id == Submarine.id.id then Submarine
        else
            {UpdateEnemy ID Submarine [possiblesPositions#{GeneratePossiblesPositions Answer 1 1}]}
        end
    end
%%% SayDeath
    fun {SayDeath ID Submarine}
        {UpdateEnemy ID Submarine [isDeath#true]}
    end
%%% SayDamageTaken
    fun {SayDamageTaken ID Damage LifeLeft Submarine}
        NewList
        N
        S 
        W 
        E 
        in
        if Damage == null then 
            NewList = {RemovePoint Submarine.lastMissile Submarine.(ID.id).possiblesPositions}
            {UpdateEnemy ID Submarine [possiblesPositions#NewList]}
        else
            if Damage == 2 then
                NewList = [Submarine.lastMissile]
                {UpdateEnemy ID Submarine [life#LifeLeft possiblesPositions#NewList]}
            else
                N = pt(x: Submarine.lastMissile.x-1 y:Submarine.lastMissile.y)
                S = pt(x: Submarine.lastMissile.x+1 y:Submarine.lastMissile.y)
                W = pt(x: Submarine.lastMissile.x   y:Submarine.lastMissile.y-1)
                E = pt(x: Submarine.lastMissile.x   y:Submarine.lastMissile.y+1)
                
                {UpdateEnemy ID Submarine [life#LifeLeft possiblesPositions#[N S W E]]}
            end
        end
    end

%%%%%%%%%%%% ADVANCED AI %%%%%%%%%%%%%%%%%%%%
    fun {GeneratePossiblesPositions Answer CountX CountY} %sayAnswerSonar
        if CountY > 10 then
            if CountX > 10 then
                nil
            else
                if {IsWater pt(x:CountX y:Answer.y)} then{System.show generatePossiblesPositions(pt(x:CountX y:Answer.y))}
                    pt(x:CountX y:Answer.y) | {GeneratePossiblesPositions Answer CountX+1 CountY}
                else {GeneratePossiblesPositions Answer CountX+1 CountY}
                end
            end
        else   
            if {IsWater pt(x:Answer.x y:CountY)} then{System.show generatePossiblesPositions(pt(x:Answer.x y:CountY))}
                pt(x:Answer.x y:CountY) | {GeneratePossiblesPositions Answer CountX CountY+1}
            else {GeneratePossiblesPositions Answer CountX CountY+1}
            end
        end
    end

    fun{ValidPath Directions Point}
        NewPoint   
        in
        if {IsWater Point} then
            case Directions
            of nil then true
            [] Dir | T then 
                if Dir == north then NewPoint = pt(x:Point.x+1 y:Point.y) end
                if Dir == south then NewPoint = pt(x:Point.x-1 y:Point.y) end
                if Dir == east then NewPoint = pt(x:Point.x y:Point.y-1) end
                if Dir == west then NewPoint = pt(x:Point.x y:Point.y+1) end
                {ValidPath T NewPoint}
            end
        else
            false
        end
    end

    fun {CheckPoints Directions ListPoints}       {System.show checkPoints(Directions)}
        case ListPoints
        of nil then nil
        [] Point | T then 
            if {ValidPath Directions Point} then{System.show checkPoints(valid:Directions)}
                Point | {CheckPoints Directions T}
            else
                {CheckPoints Directions T}
            end
        end
    end
    fun {RemovePoint Point ListPoints}
        case ListPoints
        of nil then nil
        [] Pt | T then 
            if Pt \= Point then
                Pt | {RemovePoint Point T}
            else
               {RemovePoint Point T}
            end
        end
    end

    fun{UpdatePossiblesPositions Direction ListPoints} %sayMove
        Return
    in
        case ListPoints
        of nil then nil
        [] Point | T then 
            if Direction == north then Return = pt(x:Point.x-1 y:Point.y) | {UpdatePossiblesPositions Direction T} end
            if Direction == south then Return = pt(x:Point.x+1 y:Point.y) | {UpdatePossiblesPositions Direction T} end
            if Direction == east then  Return = pt(x:Point.x y:Point.y+1) | {UpdatePossiblesPositions Direction T} end
            if Direction == west then  Return = pt(x:Point.x y:Point.y-1) | {UpdatePossiblesPositions Direction T} end
            Return
        end
    end

    fun{CheckPositionsEvery Enemies Count ID}
        {System.show debugCheckPositionsEvery(Enemies Count)}
        if Enemies == enemies then nil 
        else
            if {Value.hasFeature Enemies ID} then 
                if Count == {Record.width Enemies} then
                    {CheckPoints Enemies.ID.visited Enemies.ID.possiblesPositions}
                else
                    {AdjoinList {CheckPoints Enemies.ID.visited Enemies.ID.possiblesPositions} {CheckPositionsEvery Enemies Count+1 ID+1}}
                end
            else
                {CheckPositionsEvery Enemies Count ID+1}
            end
            
        end
    end
    
    fun{FirePosition ListPoints Submarine Min Max}
        Distance
        in
        case ListPoints
        of nil then nil
        [] Position | T then
            Distance = {Abs (Submarine.pt.x - Position.x)} + {Abs (Submarine.pt.y - Position.y)}
            {System.show firePosition(sub: Submarine.pt)}
            {System.show firePosition(pos: Position)}
            {System.show firePosition(diss: Distance)}
            if Distance > Min andthen Distance =< Max then Position
            else {FirePosition T Submarine Min Max}
            end
        end
    end
    %%% Shortest path
    fun{GetPath Visited Arrive}{System.show Visited.Arrive}
        if Visited.Arrive.prev == null then nil
        else Visited.Arrive | {GetPath Visited Visited.Arrive.prev} end
    end
    fun {ShortestPath Arrive List Visited}
        NewList
        NewVisited
        Return
        N W E S
        in 
            case List
            of nil then Return = Visited
            [] H | T then 
                if{IsWater H} andthen {Value.hasFeature Visited (H.id)} \= true then
                    NewVisited = {AdjoinList Visited [(H.id)#H]}
                    if H.x == Arrive.x andthen H.y == Arrive.y then Return = NewVisited 
                    else
                        N = pt(x: H.x-1 y:H.y id:((H.x-1)*100)+(H.y) prev:(H.id))
                        E = pt(x: H.x y:H.y+1 id:((H.x)*100)+(H.y+1) prev:(H.id))  
                        W = pt(x: H.x y:H.y-1 id:((H.x)*100)+(H.y-1) prev:(H.id))  
                        S = pt(x: H.x+1 y:H.y id:((H.x+1)*100)+(H.y) prev:(H.id))  

                        NewList =  {Append T [N E W S]}
                        
                        Return = {ShortestPath Arrive NewList NewVisited}
                    end
                else
                    if H.x < 1 orelse H.y < 1 orelse H.x > Input.nRow orelse H.y > Input.nColumn then Return = {ShortestPath Arrive T {Record.subtract Visited H.id}}
                    else Return = {ShortestPath Arrive T Visited}end
                end
            end
        Return
    end
%%% Port
    proc{TreatStream Stream Submarine} % as as many parameters as you want
        SubmarineUpdated
    in
        {System.show streamPlayer(player: Submarine.id.id aStream:Stream.1)}
        case Stream
            of nil then skip
            []initPosition(ID Position)|S then SubmarineUpdated in 
                SubmarineUpdated = {InitPosition ID Position Submarine}
                {TreatStream S SubmarineUpdated} 
            []move(ID Position Direction)|S then SubmarineUpdated in 
                {System.show streamPlayer(state: Submarine)}
                SubmarineUpdated = {Move ID Position Direction Submarine}
                {TreatStream S SubmarineUpdated}  
            []dive|S then SubmarineUpdated in 
                SubmarineUpdated = {Dive Submarine}
                {TreatStream S SubmarineUpdated}  
            []chargeItem(ID KindItem)|S then SubmarineUpdated in 
                SubmarineUpdated = {ChargeItem ID KindItem Submarine}
                {TreatStream S SubmarineUpdated}
            []fireItem(ID KindFire)|S then SubmarineUpdated in
                SubmarineUpdated = {FireItem ID KindFire Submarine}
                {TreatStream S SubmarineUpdated} 
            []fireMine(ID Mine)|S then SubmarineUpdated in 
                SubmarineUpdated = {FireMine ID Mine Submarine}
                {TreatStream S SubmarineUpdated} 
            []isDead(Answer)|S then 
                SubmarineUpdated = {IsDead Answer Submarine}
                {TreatStream S SubmarineUpdated} 
            []sayMove(ID Direction)|S then SubmarineUpdated in
                SubmarineUpdated = {SayMove ID Direction Submarine}
                {TreatStream S SubmarineUpdated} 
            []saySurface(ID)|S then SubmarineUpdated in 
                SubmarineUpdated = {SaySurface ID Submarine}
                {TreatStream S SubmarineUpdated} 
            []sayCharge(ID KindItem)|S then SubmarineUpdated in 
                SubmarineUpdated = {SayCharge ID KindItem Submarine}
                {TreatStream S SubmarineUpdated} 
            []sayMinePlaced(ID)|S then SubmarineUpdated in 
                SubmarineUpdated = {SayMinePlaced ID Submarine}
                {TreatStream S SubmarineUpdated} 
            []sayMissileExplode(ID Position Message)|S then SubmarineUpdated in 
                SubmarineUpdated = {SayMissileExplode ID Position Message Submarine}
                {TreatStream S SubmarineUpdated}
            []sayMineExplode(ID Position Message)|S then SubmarineUpdated in 
                SubmarineUpdated = {SayMineExplode ID Position Message Submarine}
                {TreatStream S SubmarineUpdated}
            []sayPassingDrone(Drone ID Answer)|S then SubmarineUpdated in 
                SubmarineUpdated = {SayPassingDrone Drone ID Answer Submarine}
                {TreatStream S SubmarineUpdated} 
            []sayAnswerDrone(Drone ID Answer)|S then SubmarineUpdated in 
                SubmarineUpdated = {SayAnswerDrone Drone ID Answer Submarine}
                {TreatStream S SubmarineUpdated} 
            []sayPassingSonar(ID Answer)|S then SubmarineUpdated in 
                SubmarineUpdated = {SayPassingSonar ID Answer Submarine}
                {TreatStream S SubmarineUpdated}
            []sayAnswerSonar(ID Answer)|S then SubmarineUpdated in 
                SubmarineUpdated = {SayAnswerSonar ID Answer Submarine}
                {TreatStream S SubmarineUpdated}
            []sayDeath(ID)|S then SubmarineUpdated in 
                SubmarineUpdated = {SayDeath ID Submarine}
                {TreatStream S SubmarineUpdated}
            []sayDamageTaken(ID Damage LifeLeft)|S then SubmarineUpdated in 
                SubmarineUpdated = {SayDamageTaken ID Damage LifeLeft Submarine}
                {TreatStream S SubmarineUpdated}
            else
                if {Value.hasFeature Submarine.enemies 2} then
                    {System.show player(msg:badStream var:Stream.1)} 
                    {TreatStream Stream.2 Submarine}
                end
        end
    end
    fun{StartPlayer Color ID}
        Stream
        Port
        Submarine
    in
        {NewPort Stream Port}
        thread
            Submarine = {InitSubmarine Color ID}
            {TreatStream Stream Submarine}
            {System.show player(msg:treatStreamEnd)} 
        end
        Port
    end
end
