class CSHoverMechFactory extends ONSVehicleFactory
    placeable;

/*
var vector spawnoffset;

function SpawnVehicle()
{
	local Pawn P;
	local bool bBlocked;

    foreach CollidingActors(class'Pawn', P, VehicleClass.default.CollisionRadius * 1.25)
	{
		bBlocked = true;
		if (PlayerController(P.Controller) != None)
			PlayerController(P.Controller).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 11);
	}

    if (bBlocked)
    	SetTimer(1, false); //try again later
    else
    {
        if (bReverseBlueTeamDirection && ONSOnslaughtGame(Level.Game) != None && ((TeamNum == 1 && !ONSOnslaughtGame(Level.Game).bSidesAreSwitched) || (TeamNum == 0 && ONSOnslaughtGame(Level.Game).bSidesAreSwitched)))
            LastSpawned = spawn(VehicleClass,,, Location + spawnoffset, Rotation + rot(0,32768,0));
        else
            LastSpawned = spawn(VehicleClass,,, Location + spawnoffset, Rotation);

		if (LastSpawned != None )
		{
			VehicleCount++;
			LastSpawned.SetTeamNum(TeamNum);
			LastSpawned.Event = Tag;
			LastSpawned.ParentFactory = Self;
			TriggerEvent(Event, Self, LastSpawned);
		}
    }
}
*/

defaultproperties
{
    VehicleClass=class'CSHoverMech'
    Mesh=Mesh'CSMech.BotB'
	RedBuildEffectClass=class'ONSTankBuildEffectRed'
	BlueBuildEffectClass=class'ONSTankBuildEffectBlue'
	RespawnTime=30.0    
}