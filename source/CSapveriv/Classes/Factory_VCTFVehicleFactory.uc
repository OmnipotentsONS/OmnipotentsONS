//-----------------------------------------------------------
//  Factory for Vehicles
//  for GameTypes Other than ONS
//-----------------------------------------------------------
class Factory_VCTFVehicleFactory extends SVehicleFactory
    abstract
	placeable;

var()   float           RespawnTime;
var     float           PreSpawnEffectTime;
var()   bool            bReverseBlueTeamDirection;
var     bool            bActive;
var     bool            bPreSpawn; // Neither the vehicle or build effect have been spawned yet
var     class<Emitter>  RedBuildEffectClass, BlueBuildEffectClass;
var     Emitter         BuildEffect;
var(FighterFactory)     byte             TeamNum;
var	Vehicle		LastSpawned;

function PreBeginPlay()
{
}
simulated event PostBeginPlay()
{
    if ( Level.NetMode != NM_DedicatedServer )
		VehicleClass.static.StaticPrecache(Level);
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'VMParticleTextures.buildEffects.PC_buildBorderNew');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.buildEffects.PC_buildStreaks');
    VehicleClass.static.StaticPrecache(Level);
}

function PostNetBeginPlay()
{
   		Activate();
}

function Activate()
{
        bActive = True;
        bPreSpawn = True;
        Timer();
}

function Deactivate()
{
    bActive = False;
}

event VehicleDestroyed(Vehicle V)
{
	Super.VehicleDestroyed(V);

    bPreSpawn = True;
    SetTimer(RespawnTime - PreSpawnEffectTime, False);
}

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


            LastSpawned = spawn(VehicleClass,,, Location, Rotation);

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

function SpawnBuildEffect()
{
    local rotator YawRot;

    YawRot = Rotation;
    YawRot.Roll = 0;
    YawRot.Pitch = 0;

    if (TeamNum == 0)
       BuildEffect = spawn(RedBuildEffectClass,,, Location, YawRot);
    else
       BuildEffect = spawn(BlueBuildEffectClass,,, Location, YawRot);
}

function Timer()
{
	if (bActive && VehicleCount < MaxVehicleCount)
	{
        if (bPreSpawn)
        {
            bPreSpawn = False;
            SpawnBuildEffect();
            SetTimer(PreSpawnEffectTime, False);
        }
        else
    	   SpawnVehicle();


    }
}

event Trigger( Actor Other, Pawn EventInstigator )
{
}

defaultproperties
{
     RespawnTime=30.000000
     PreSpawnEffectTime=2.000000
     RedBuildEffectClass=Class'Onslaught.ONSAttackCraftBuildEffectRed'
     BlueBuildEffectClass=Class'Onslaught.ONSAttackCraftBuildEffectBlue'
     DrawType=DT_Mesh
}
