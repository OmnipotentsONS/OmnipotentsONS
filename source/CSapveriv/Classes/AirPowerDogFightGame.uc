//=============================================================================
//
//
//=============================================================================
class AirPowerDogFightGame extends xTeamGame;

#exec OBJ LOAD FILE=TeamSymbols.utx				// needed right now for Link symbols, etc.


static function PrecacheGameTextures(LevelInfo myLevel)
{
	class'xDeathMatch'.static.PrecacheGameTextures(myLevel);

	myLevel.AddPrecacheMaterial(Material'TeamSymbols.TeamBeaconT');
	myLevel.AddPrecacheMaterial(Material'TeamSymbols.LinkBeaconT');
	myLevel.AddPrecacheMaterial(Material'XEffectMat.RedShell');
	myLevel.AddPrecacheMaterial(Material'XEffectMat.BlueShell');
	myLevel.AddPrecacheMaterial(Material'TeamSymbols.soundBeacon_a00');
	myLevel.AddPrecacheMaterial(Material'TeamSymbols.soundBeacon_a01');
	myLevel.AddPrecacheMaterial(Material'TeamSymbols.soundBeacon_a02');
	myLevel.AddPrecacheMaterial(Material'TeamSymbols.soundBeacon_a03');
}

static function PrecacheGameStaticMeshes(LevelInfo myLevel)
{
	class'xDeathMatch'.static.PrecacheGameStaticMeshes(myLevel);
}

function int VehicleScoreKill( Controller Killer, Controller Killed, Vehicle DestroyedVehicle, out string KillInfo )
{
	//log("VehicleScoreKill Killer:" @ Killer.GetHumanReadableName() @ "Killed:" @ Killed @ "DestroyedVehicle:" @ DestroyedVehicle );

	// Broadcast vehicle kill message if killed no player inside
	if ( Killed == None && PlayerController(Killer) != None )
		PlayerController(Killer).TeamMessage( Killer.PlayerReplicationInfo, YouDestroyed@DestroyedVehicle.VehicleNameString@YouDestroyedTrailer, 'CriticalEvent' );

	if ( KillInfo == "" )
	{
		if ( DestroyedVehicle.bKeyVehicle || DestroyedVehicle.bHighScoreKill )
		{
			KillInfo = "destroyed_key_vehicle";
			return 5;
		}
	if ( DestroyedVehicle.bAutoTurret==True)
		{
			KillInfo = "destroyed_key_vehicle";
			return 2;
		}

	}

	return 0;
}

defaultproperties
{
     bSpawnInTeamArea=True
     bAllowTrans=True
     bDefaultTranslocator=True
     DMHints(0)="To Launch Press Fire Button."
     bAllowVehicles=True
     MapPrefix="DOG"
     GoalScore=10
     GameName="Team DogFight"
     Description="Your Team must ShootDown the Enemy Team in Heated Battles in the Skies."
     Acronym="DOG"
}
