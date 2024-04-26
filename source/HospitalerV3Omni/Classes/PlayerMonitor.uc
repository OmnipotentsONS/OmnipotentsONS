// server actor used to update players rep info with teleporter rep info
class PlayerMonitor extends Actor;

function PostBeginPlay()
{
    SetTimer(1.0, true);
}

// continuously monitor the player list and add repinfo as needed
// this could be done more efficiently in a mutator -> ModifyPlayer 
function Timer()
{
    local Controller C;
    for(C=Level.ControllerList;C!=None;C=C.NextController)
    {
        if(PlayerController(C) != None)
            class'TeleporterReplicationInfo'.static.AddInfo(C);
    }
}

static function Init(LevelInfo Level)
{
    local PlayerMonitor PM;
    ForEach Level.AllActors(class'PlayerMonitor', PM)
        break;
    
    if(PM == None)
        Level.spawn(class'PlayerMonitor');
}

defaultproperties
{
    bHidden=true
    RemoteRole=ROLE_None
}