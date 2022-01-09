class HammerheadFactory extends ONSTankFactory;

var() int Health; // How much health the vehicle should spawn with.
var() float DamageMomentumScale; // Momentum caused by hits is scaled by this value before being applied. Default is 4.0

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
			LastSpawned = spawn(VehicleClass,,, Location, Rotation + rot(0,32768,0));
		else
			LastSpawned = spawn(VehicleClass,,, Location, Rotation);

		if (LastSpawned != None )
		{
			VehicleCount++;
			LastSpawned.SetTeamNum(TeamNum);
			LastSpawned.Event = Tag;
			LastSpawned.ParentFactory = Self;
			LastSpawned.HealthMax = Health;
			LastSpawned.Health = Health;
			LastSpawned.MomentumMult = DamageMomentumScale;
			TriggerEvent(Event, Self, LastSpawned);
		}
	}
}

defaultproperties
{
     Health=800
     DamageMomentumScale=1.000000
     RespawnTime=35.000000
     VehicleClass=Class'CSHammerhead.Hammerhead'
     Mesh=SkeletalMesh'CSHammerhead.hammer'
     Skins(0)=Texture'Hammer_Tex.Hammerhead.HammerTex'
}
