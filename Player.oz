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
    DisponnibleItem
    UpdateEnemy
    DistanceDammage
    
in
      
%%% Initialize submarine
    fun {InitSubmarine Color ID}
        Submarine
    in
        Submarine = submarine(
            id: id(id: ID color: Color name: random)
            turnSurface: Input.turnSurface
            visited: nil
            missile:0 
            mine:0 
            sonar:0 
            drone:0
            mines: nil
            life: Input.maxDamage
            enemies: enemies()
        )
        Submarine
    end  
%%% Initialize position submarine
    fun {InitPosition ID Position Submarine} 
        Pos
        SubmarineUpdated
        Bool
    in
        Pos = pt(x:({OS.rand} mod (Input.nColumn) + 1 ) y:({OS.rand} mod (Input.nRow) + 1 ))
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
        if Position.x > 0 andthen Position.x =< Input.nColumn then 
            if Position.y > 0 andthen Position.y =< Input.nRow then
                if {List.nth {List.nth Input.map Position.x} Position.y} == 0 then
                    true
                else
                    {System.show player(func: isWater msg:land)}
                    false
                end
            else
                {System.show player(func: isWater msg:outOfMap)}
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
            if Visited.1.x == Position.x andthen Visited.1.y == Position.y then {System.show player(func: isNotVisited msg:alreadyVisited)} 
                false
            else {IsNotVisited Visited.2 Position}
            end
        end
    end
%%% CanMove - Possible Move
    fun{CanMove Submarine Directions}
        {System.show player(func: canMove msg:directions var: Directions)}
        case Directions 
        of nil then nil
        [] east | T then {System.show player(func: canMove msg:east)}
            if {IsWater pt(x:(Submarine.pt.x+1) y:(Submarine.pt.y))} 
            andthen {IsNotVisited Submarine.visited pt(x:(Submarine.pt.x) y:(Submarine.pt.y+1))} 
                then {System.show player(func: canMove msg:addEast)}
                    east | {CanMove Submarine T} 
            else {CanMove Submarine T}
            end
        [] north | T then {System.show player(func: canMove msg:north)}
            if {IsWater pt(x:(Submarine.pt.x) y:(Submarine.pt.y-1))} 
            andthen {IsNotVisited Submarine.visited pt(x:(Submarine.pt.x-1) y:(Submarine.pt.y))} 
                then {System.show player(func: canMove msg:addNorth)}
                    north | {CanMove Submarine T} 
            else {CanMove Submarine T}
            end
        [] south | T then{System.show player(func: canMove msg:south)}
            if {IsWater pt(x:(Submarine.pt.x) y:(Submarine.pt.y+1))} 
            andthen {IsNotVisited Submarine.visited pt(x:(Submarine.pt.x+1) y:(Submarine.pt.y))} 
                then {System.show player(func: canMove msg:addSouth)}
                    south | {CanMove Submarine T} 
            else {CanMove Submarine T}
            end
        [] west | T then {System.show player(func: canMove msg:west)}
            if {IsWater pt(x:(Submarine.pt.x-1) y:(Submarine.pt.y))}
            andthen {IsNotVisited Submarine.visited pt(x:(Submarine.pt.x) y:(Submarine.pt.y-1))} 
                then {System.show player(func: canMove msg:addWest)}
                    west | {CanMove Submarine T} 
            else {CanMove Submarine T}
            end
        [] surface | T then surface | {CanMove Submarine T} 
        end
    end
%%% Move - submarine
    fun {Move ID Position Direction Submarine} 
        NewPosition
        Visit
        SubmarineUpdated
        PossibleDirection
        Direction
    in
        {System.show player(func: move msg:myPosition var: Submarine.pt)}
        PossibleDirection = {CanMove Submarine [east north south west surface]}
        {System.show player(func: move msg:possibleDirection var: PossibleDirection)}
        Direction = {List.nth PossibleDirection ({OS.rand} mod ({List.length PossibleDirection}) + 1 )}
        {System.show player(func: move msg:direction var: Direction )}
        case Direction
        of surface then
            ID = Submarine.id
            SubmarineUpdated = {AdjoinList Submarine [turnSurface#1 visited#nil]}
        else 
            case Direction 
            of east then NewPosition = pt(x:(Submarine.pt.x) y:(Submarine.pt.y+1))
            [] north then NewPosition = pt(x:(Submarine.pt.x-1) y:(Submarine.pt.y))
            [] south then NewPosition = pt(x:(Submarine.pt.x+1) y:(Submarine.pt.y))
            [] west then NewPosition = pt(x:(Submarine.pt.x) y:(Submarine.pt.y-1))
            end
            ID = Submarine.id
            Visit = Submarine.pt | Submarine.visited
            {System.show player(func: move msg:newPosition var: NewPosition )}
            SubmarineUpdated = {AdjoinList Submarine [pt#NewPosition turnSurface#0 visited#Visit]} 

        end
        SubmarineUpdated
    end
%%% Dive
    fun {Dive Submarine}
        {AdjoinList Submarine [turnSurface#0]}
    end
%%% ChargeItem
    fun {ChargeItem ID KindItem Submarine} 
        Items
        Item
        SubmarineUpdated
    in
        Items = [missile mine sonar drone]
        Item = {List.nth Items 1}
        case Item 
        of missile then
            if Submarine.missile == Input.missile then
                KindItem = null
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
            else
                SubmarineUpdated = {AdjoinList Submarine [mine#Submarine.mine+1]}
                if SubmarineUpdated.mine == Input.mine then
                    KindItem = mine
                else KindItem = null end
            end
        [] sonar then 
            if Submarine.sonar == Input.sonar then
                KindItem = null
            else
                SubmarineUpdated = {AdjoinList Submarine [sonar#Submarine.sonar+1]}
                if SubmarineUpdated.sonar == Input.sonar then
                    KindItem = sonar
                else KindItem = null end
            end
        [] drone then 
            if Submarine.drone == Input.drone then
                KindItem = null
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
%%% DisponnibleItem
    fun {DisponnibleItem Submarine List}

        case List
        of nil then skip
            null | nil
        [] missile | T then 
            if Submarine.missile == Input.missile then
                Label| {DisponnibleItem Submarine T}
            else 
                {DisponnibleItem Submarine T}
            end
        [] mine | T then 
            if Submarine.mine == Input.mine then
                Label| {DisponnibleItem Submarine T}
            else 
                {DisponnibleItem Submarine T}
            end
        [] sonar | T then 
            if Submarine.sonar == Input.sonar then
                Label| {DisponnibleItem Submarine T}
            else 
                {DisponnibleItem Submarine T}
            end
        [] drone | T then 
            if Submarine.drone == Input.drone then
                Label| {DisponnibleItem Submarine T}
            else 
                {DisponnibleItem Submarine T}
            end
        end
    end
%%% FireItem
    fun {FireItem ID FireItem Submarine } 
        Rand
        Items
        Item
        Position
        ListMine
        SubmarineUpdated
    in
        Items = {DisponnibleItem Submarine [missile mine sonar drone]}
        {System.show player(func: fireItem msg:items var:Items)}
        Item = {List.nth Items ({OS.rand} mod ({List.length Items}) + 1 )}
        {System.show player(func: fireItem msg:item var:Item)}
        Position = pt(x:({OS.rand} mod Input.nRow +1) y:({OS.rand} mod Input.nColumn +1))
        case Item 
        of missile then 
            FireItem = missile(Position)
            SubmarineUpdated = {AdjoinList Submarine [missile#0]}
        [] mine then 
            FireItem = mine(Position)
            ListMine = Submarine.mines | Position
            SubmarineUpdated = {AdjoinList Submarine [mine#0]}
        [] sonar then 
            FireItem = sonar
            SubmarineUpdated = {AdjoinList Submarine [sonar#0]}
        [] drone then 
            SubmarineUpdated = {AdjoinList Submarine [drone#0]}
            Rand = ({OS.rand} mod 2 )
            if Rand == 1 then
                FireItem = drone(row Position.x)
            else
                FireItem = drone(column Position.y)
            end
        else
            FireItem = null
        end
        ID = Submarine.id
        SubmarineUpdated
    end
%%% FireMine
    fun {FireMine ID Mine Submarine}
        SubmarineUpdated
        in
        {System.show Submarine}
        ID= Submarine.id
        case Submarine.mines
        of nil then {System.show debug1}
            Mine = null
            SubmarineUpdated = Submarine
        [] H | T then {System.show debug2}
            Mine = H
            SubmarineUpdated = {AdjoinList Submarine [mines#T]}
        end
        SubmarineUpdated
    end    
%%% IsDead
    fun {IsDead Answer Submarine}
        Answer = Submarine.life == 0
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
                Up = {AdjoinList Submarine.enemies [(ID.id)#enemy(id:ID visited:nil nbMines:0 missile:0 sonar:0 drone:0)]}
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
    in
        if ID == Submarine.id then Submarine
        else
            if {Value.hasFeature Submarine.enemies (ID.id)} == false then
                EnemyDirection = Direction | nil
            else
                EnemyDirection = Direction | Submarine.enemies.(ID.id).visited
            end
            {UpdateEnemy ID Submarine [visited#EnemyDirection]}
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
        {UpdateEnemy ID Submarine [nbMine#Submarine.enemies.ID.nbMine+1]}
    end
%%% DistanceDammage
    fun{DistanceDammage Position Message Submarine}
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
                if Submarine.life == 0 then Message = sayDeath(Submarine.id)
                else Message = 1 end
            else
                SubmarineUpdated = {AdjoinList Submarine [life#Submarine.life-2]}
                if Submarine.life == 0 then Message = sayDeath(Submarine.id)
                else Message = 2 end
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
        {DistanceDammage Position Message {UpdateEnemy ID Submarine [nbMine#Submarine.enemies.ID.nbMine-1]}}
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
        {UpdateEnemy ID Submarine [drone#false]}
    end
%%% SayAnswerDrone
    fun {SayAnswerDrone Drone ID Answer Submarine}
        SubmarineUpdated
    in
        if ID \= Submarine.id andthen Answer \= false then
            case Drone
            of drone(row X) then
                SubmarineUpdated = {UpdateEnemy ID Submarine [lastX#X]}
            [] drone(column Y) then
                SubmarineUpdated = {UpdateEnemy ID Submarine [lastY#Y]}
            else
                SubmarineUpdated = Submarine
            end
        end
        SubmarineUpdated
    end
%%% SayPassingSonar
    fun {SayPassingSonar ID Answer Submarine}
        ID = Submarine.id
        if ({OS.rand} mod 2) == 1 then
            Answer = pt(x:Submarine.pt.x y:({OS.rand} mod Input.nColumn))
        else
            Answer = pt(x:({OS.rand} mod Input.nRow) y:Submarine.pt.y)
        end
        Submarine
    end
%%% SayAnswerSonar
    fun {SayAnswerSonar ID Answer Submarine}
        Update
        SubmarineUpdated
    in
        if ID \= Submarine.id then
            Update = {UpdateEnemy ID Submarine [possibleX#Answer.x]}
            SubmarineUpdated = {UpdateEnemy ID Submarine [possibleY#Answer.y]}
        else 
            SubmarineUpdated = Submarine
        end
        SubmarineUpdated
    end
%%% SayDeath
    fun {SayDeath ID Submarine}
        SubmarineUpdated
    in
        SubmarineUpdated = {UpdateEnemy ID Submarine [isDeath#true]}
        SubmarineUpdated
    end
%%% SayDamageTaken
    fun {SayDamageTaken ID Damage LifeLeft Submarine}
        SubmarineUpdated
    in
        if ID \= Submarine.id then
            case Damage
            of null then skip
            [] sayDeath(ID) then SubmarineUpdated = {SayDeath ID Submarine}
            else
                SubmarineUpdated = {UpdateEnemy ID Submarine [life#Submarine.enemies.ID.life-LifeLeft]}
            end
        end
        SubmarineUpdated
    end
%%% Port
    proc{TreatStream Stream Submarine} % as as many parameters as you want
        SubmarineUpdated
    in
        {System.show streamPlayer(player: Submarine aStream:Stream.1)}
        case Stream
            of nil then skip
            []initPosition(ID Position)|S then SubmarineUpdated in 
                SubmarineUpdated = {InitPosition ID Position Submarine}
                {TreatStream S SubmarineUpdated} 
            []move(ID Position Direction)|S then SubmarineUpdated in 
                SubmarineUpdated = {Move ID Position Direction Submarine}
                {TreatStream S SubmarineUpdated}  
            []dive|S then SubmarineUpdated in 
                SubmarineUpdated = {Dive Submarine}
                {TreatStream S SubmarineUpdated}  
            []chargeItem(ID KindItem)|S then SubmarineUpdated in 
                SubmarineUpdated = {ChargeItem ID KindItem Submarine}{System.show debugCharge(SubmarineUpdated)}
                {TreatStream S SubmarineUpdated}
            []fireItem(ID KindFire)|S then SubmarineUpdated in {System.show debugFireItem(SubmarineUpdated)}
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
