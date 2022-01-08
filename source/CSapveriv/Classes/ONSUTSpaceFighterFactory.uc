//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSUTSpaceFighterFactory extends ONSVehicleFactory;


var()	class<Vehicle>		VehicleClassTeamBlue;
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
           {
            if(TeamNum==0)
            LastSpawned = spawn(VehicleClass,,, Location, Rotation + rot(0,32768,0));
            else
             LastSpawned = spawn(VehicleClassTeamBlue,,, Location, Rotation + rot(0,32768,0));
            }
        else
          {
            if(TeamNum==0)
            LastSpawned = spawn(VehicleClass,,, Location, Rotation);
            else
            LastSpawned = spawn(VehicleClassTeamBlue,,, Location, Rotation);
          }

		if (LastSpawned != None )
		{
			VehicleCount++;
			LastSpawned.SetTeamNum(TeamNum);
			LastSpawned.Event = Tag;
			LastSpawned.ParentFactory = Self;
		}
    }
}

defaultproperties
{
     VehicleClassTeamBlue=Class'CSAPVerIV.UTSpaceFighterSkarj'
     RedBuildEffectClass=Class'Onslaught.ONSAttackCraftBuildEffectRed'
     BlueBuildEffectClass=Class'Onslaught.ONSAttackCraftBuildEffectBlue'
     VehicleClass=Class'CSAPVerIV.UTSpaceFighter'
     Mesh=SkeletalMesh'AS_VehiclesFull_M.SpaceFighter_Human'
     DrawScale=1.500000
}
