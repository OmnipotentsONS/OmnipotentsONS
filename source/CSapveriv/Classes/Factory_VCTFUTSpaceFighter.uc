//-----------------------------------------------------------
//
//-----------------------------------------------------------
class Factory_VCTFUTSpaceFighter extends Factory_VCTFVehicleFactory;

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

            if(TeamNum==0)
            LastSpawned = spawn(VehicleClass,,, Location, Rotation);
            else
            LastSpawned = spawn(VehicleClassTeamBlue,,, Location, Rotation);

		if (LastSpawned != None )
		{
			VehicleCount++;
			LastSpawned.SetTeamNum(TeamNum);
			LastSpawned.Event = Tag;
			LastSpawned.ParentFactory = Self;
			LastSpawned.DrivingStatusChanged();
		}
    }
}

defaultproperties
{
     VehicleClassTeamBlue=Class'CSAPVerIV.UTSpaceFighterSkarj'
     VehicleClass=Class'CSAPVerIV.UTSpaceFighter'
     Mesh=SkeletalMesh'AS_VehiclesFull_M.SpaceFighter_Human'
     DrawScale=1.500000
}
