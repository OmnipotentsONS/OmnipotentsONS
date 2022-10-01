//-----------------------------------------------------------
//	Viper Speedboat
//	Colt Wohlers (aka CMan)
//	Beta 4.0 (July 2/2004)
//-----------------------------------------------------------
//  Viper Factory (Enabled for both teams, using 1 factory)
//  Red Team = Human Viper / Blue Team = Skaarj Viper
//-----------------------------------------------------------
class ViperFactory extends ONSVehicleFactory;

function SpawnVehicle()
{
	local Pawn P;
	local bool bBlocked;

    if (TeamNum == 0)
      {
      VehicleClass=Class'KopholusV2Omni.HumanViper';
      }
      if (TeamNum == 1)
      {
      VehicleClass=Class'KopholusV2Omni.SkaarjViper';
      }

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
        if (bReverseBlueTeamDirection && TeamNum == 1)
            LastSpawned = spawn(VehicleClass,,, Location, Rotation + rot(0,32768,0));
        else
            LastSpawned = spawn(VehicleClass,,, Location, Rotation);

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
     RedBuildEffectClass=Class'KopholusV2Omni.SkaarjViperBuildEffectRed'
     BlueBuildEffectClass=Class'KopholusV2Omni.SkaarjViperBuildEffectBlue'
     VehicleClass=Class'KopholusV2Omni.HumanViper'
     Mesh=SkeletalMesh'KASPvehicles.HumanViper'
}
