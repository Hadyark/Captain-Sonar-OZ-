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
    SubmarineUpdated

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
    PossibleDirection
    DisponnibleItem
    UpdateEnemy
    DistanceDammage
    
in
      
%%% Initialize submarine
    fun {InitSubmarine Color ID}
        Submarine
    in
        Submarine = submarine(
            id: id(id: ID color: Color name: "Random")
            isSubmerged: true
            visited: nil
            missile:0 
            mine:0 
            sonar:0 
            drone:0
            mines: nil
            life: Input.maxDamage
        )
        Submarine
    end  
%%% Initialize position submarine
    fun {InitPosition ID Position Submarine} 
        Pos
        SubmarineUpdated
    in
        Pos = pt(x:({OS.rand} mod (Input.nColumn) + 1 ) y:({OS.rand} mod (Input.nRow) + 1 ))
        if {IsWater Pos} then
            ID = Submarine.id
            Position = Pos
            SubmarineUpdated = {AdjoinList Submarine [position#Position]}
            SubmarineUpdated
        else
            {InitPosition ID Position Submarine} 
        end
    end
%%% IsWater - Check is case contains water
    fun{IsWater Position}
      {List.nth {List.nth Input.map Position.x} Position.y} == 0
    end
%%% IsNotVisited - Check if the case has been already visited
    fun{IsNotVisited Visited Position}
        if Visited.1 == nil then true
        else 
            if Visited.1.x == Position.x andthen Visited.1.y == Position.y then false
            else {IsNotVisited Visited.2 Position}
            end
        end
    end
%%% CanMove - Possible Move
    fun{CanMove Submarine Directions}
        case Directions 
        of east | T then 
            if {IsWater pt(x:(Submarine.pt.x) y:(Submarine.pos.y+1))} 
            andthen {IsNotVisited Submarine.visited pt(x:(Submarine.position.x) y:(Submarine.pos.y+1))} 
                then east | {CanMove Submarine T} 
            else {CanMove Submarine T}
            end
        [] north | T then 
            if {IsWater pt(x:(Submarine.pos.x-1) y:(Submarine.pos.y))} 
            andthen {IsNotVisited Submarine.visited pt(x:(Submarine.pos.x-1) y:(Submarine.pos.y))} 
                then north | {CanMove Submarine T} 
            else {CanMove Submarine T}
            end
        [] south | T then
            if {IsWater pt(x:(Submarine.pos.x+1) y:(Submarine.pos.y))} 
            andthen {IsNotVisited Submarine.visited pt(x:(Submarine.pos.x+1) y:(Submarine.pos.y))} 
                then south | {CanMove Submarine T} 
            else {CanMove Submarine T}
            end
        [] west | T then 
            if {IsWater pt(x:(Submarine.pos.x) y:(Submarine.pos.y-1))}
            andthen {IsNotVisited Submarine.visited pt(x:(Submarine.pos.x) y:(Submarine.pos.y-1))} 
                then west | {CanMove Submarine T} 
            else {CanMove Submarine T}
            end
        end
    end
%%% Move - submarine
    fun {Move ID Position Direction Submarine} 
        NewPosition
        Visit
    in
        if Submarine.isAlive then
            PossibleDirection = {CanMove Submarine [east north south west]}
            Direction = {Nth PossibleDirection ({OS.rand} mod ({Length PossibleDirection}) + 1 )}
            case Direction
            of surface then
                SubmarineUpdated = {AdjoinList Submarine [isSubmerged#false visited#nil]}
            else 
                case Direction 
                of east then NewPosition = pt(x:(Submarine.position.x) y:(Submarine.position.y+1))
                [] north then NewPosition = pt(x:(Submarine.position.x-1) y:(Submarine.position.y))
                [] south then NewPosition = pt(x:(Submarine.position.x+1) y:(Submarine.position.y))
                [] west then NewPosition = pt(x:(Submarine.position.x) y:(Submarine.position.y-1))
                end
                Visit = Submarine.position | Submarine.visited
                SubmarineUpdated = {AdjoinList Submarine [position#NewPosition isSubmerged#true visited#Visit]}
                SubmarineUpdated
            end
        else
            Direction = null
            Position = nul
            Submarine
        end
    end
%%% Dive
    fun {Dive Submarine}
        {AdjoinList Submarine [isSubmerged#true]}
    end
%%% ChargeItem
    fun {ChargeItem ID KindItem Submarine} 
        Items
        Item
    in
        Items = [missile mine sonar drone]
        Item = {Nth Items ({OS.rand} mod ({Length Items}) + 1 )}
        case Item 
        of missile then 
            SubmarineUpdated = {AdjoinList Submarine [missile#Submarine.missile+1]}
            if Submarine.missile == Input.missile then
                ID = Submarine.id
                KindItem = missile
            end
        [] mine then 
            SubmarineUpdated = {AdjoinList Submarine [mine#Submarine.mine+1]}
            if Submarine.mine == Input.mine then
                ID = Submarine.id
                KindItem = mine
            end
        [] sonar then 
            SubmarineUpdated = {AdjoinList Submarine [sonar#Submarine.sonar+1]}
            if Submarine.sonar == Input.sonar then
                ID = Submarine.id
                KindItem = sonar
            end
        [] drone then 
            SubmarineUpdated = {AdjoinList Submarine [drone#Submarine.drone+1]}
            if Submarine.drone == Input.drone then
                ID = Submarine.id
                KindItem = drone
            end 
        end
    end
%%% DisponnibleItem
    fun {DisponnibleItem Submarine List}
        Label
    in
        Label = List.1
        case Label
        of missile then 
            if Submarine.missile == Input.missile then
                Label| {DisponnibleItem Submarine List.2}
            else 
                {DisponnibleItem Submarine List.2}
            end
        [] mine then 
            if Submarine.mine == Input.mine then
                Label| {DisponnibleItem Submarine List.2}
            else 
                {DisponnibleItem Submarine List.2}
            end
        [] sonar then 
            if Submarine.sonar == Input.sonar then
                Label| {DisponnibleItem Submarine List.2}
            else 
                {DisponnibleItem Submarine List.2}
            end
        [] drone then 
            if Submarine.drone == Input.drone then
                Label| {DisponnibleItem Submarine List.2}
            else 
                {DisponnibleItem Submarine List.2}
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
    in
        Items = {DisponnibleItem Submarine [missile mine sonar drone]}
        Item = {Nth Items ({OS.rand} mod ({Length Items}) + 1 )}
        Position = pt(x:({OS.rand} mod Input.nRow) y:({OS.rand} mod Input.nColumn ))
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
        ID= Submarine.id
        Mine = Submarine.mines.1
        {AdjoinList Submarine [mines#Submarine.mines.2]}
    end    
%%% IsDead
    fun {IsDead ID Answer Submarine}
        ID = Submarine.id
        Answer = Submarine.life == 0
        Submarine
    end
%%% UpdateEnemy
    fun {UpdateEnemy ID Submarine Data}
        Enemy
        Enemies
    in
        Enemy =   {AdjoinList Submarine.enemies.ID Data}
        Enemies = {AdjoinList Submarine.enemies [ID#Enemy]}
        {AdjoinList Submarine [enemies#Enemies]}
    end
%%% SayMove
    fun {SayMove ID Direction Submarine}
        EnemyDirection
    in
        EnemyDirection = Direction | Submarine.enemies.ID.visited
        {UpdateEnemy ID Submarine [visited#EnemyDirection]}
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
        in
        Distance = {Abs (Submarine.position.x - Position.x)} + {Abs (Submarine.position.y - Position.y)}
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
            if Submarine.position.x == X then
                Answer = true
            else
                Answer = false
            end
        [] drone(column Y) then
            if Submarine.position.y == Y then
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
            Answer = pt(x:Submarine.position.x y:({OS.rand} mod Input.nColumn))
        else
            Answer = pt(x:({OS.rand} mod Input.nRow) y:Submarine.position.y)
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
        {System.show streamPlayer}{System.show Stream}
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
                SubmarineUpdated = {ChargeItem ID KindItem Submarine}
                {TreatStream S SubmarineUpdated}
            []fireItem(ID KindFire)|S then SubmarineUpdated in 
                SubmarineUpdated = {FireItem ID KindFire Submarine}
                {TreatStream S SubmarineUpdated} 
            []fireMine(ID Mine)|S then SubmarineUpdated in 
                SubmarineUpdated = {FireMine ID Mine Submarine}
                {TreatStream S SubmarineUpdated} 
            []isDead(ID Answer)|S then 
                SubmarineUpdated = {IsDead ID Answer Submarine}
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
        end
        Port
    end
end
