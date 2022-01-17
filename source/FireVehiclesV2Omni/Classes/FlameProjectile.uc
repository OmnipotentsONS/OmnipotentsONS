class FlameProjectile extends Projectile;

var xEmitter Flame;
var() class<xEmitter> FlameClass;
var() class<DamageType> DamageType, BurnDamageType;
var bool bDoTouch;
var int MinDamage;

simulated function PreBeginPlay()
{
	if(Role < ROLE_Authority)
		return;

	if(FRand() > 0.6)
		AmbientSound = None;
	else
		SoundPitch = 16 + Rand(48);
}

simulated function PostBeginPlay()
{
        //No fire underwater.
	if(PhysicsVolume.bWaterVolume)
	{
		Destroy();
		return;
	}

	Super.PostBeginPlay();

	if(Level.Netmode != NM_DedicatedServer)
	{
		Flame = spawn(FlameClass);
		Flame.SetBase(self);

		if(FRand() > 0.8)
		{
			bDynamicLight = true;
			LightHue = Default.LightHue + Rand(20);
		}
	}

	SetTimer(0.1, true);
}

simulated function PostNetBeginPlay()
{
	Velocity = Vector(Rotation) * Speed;
	Acceleration = Velocity / 1.5;

	if(Instigator != None)
		Velocity += 0.7 * Instigator.Velocity;
}

 function Timer()
{
  	local Pawn P;
  	local Burner Inv;


	//Flames expand with time.
  	SetCollisionSize(CollisionRadius + 2.5, CollisionHeight + 2.5);

//Simple damage radius.
	
if(Role == ROLE_Authority)
{
	//Damage reduces with distance.
    Damage = Max(Default.Damage * Sqrt(Default.CollisionHeight / CollisionHeight), MinDamage);
    //always do at least MinDamage pts.
		HurtRadius(MinDamage/3, CollisionRadius * 5, MyDamageType, MomentumTransfer, Location);
	}

	//Setting people on fire is handled here.
  	if(Role == ROLE_Authority && bDoTouch)
  	{
    foreach TouchingActors(class'Pawn', P)
  		{
  			If(P != class'ONSPowerCore'&& P.Controller != None)
          {
          if(P.Health > 0 && (!Level.Game.bTeamGame || !P.Controller.SameTeamAs(InstigatorController)))
  			{
 				//P.CreateInventory("SiegeEngines.Burner");
 				P.CreateInventory("FireVehiclesV2Omni.BurnerFlame");
 				Inv = Burner(P.FindInventoryType(class'FireVehiclesV2Omni.BurnerFlame'));
  
  				if(Inv != None)
  				{
 					Inv.DamageType = BurnDamageType;
  					Inv.Chef = Instigator;
  					Inv.DamageDealt = 0;
  					Inv.Temperature += 1.5;  //was 0.6
  					Inv.WaitTime = 0;
  				}
  			}
  			
  			}
	  }
	}

 	bDoTouch = !bDoTouch;
}
//No fire underwater.
simulated function PhysicsVolumeChange(PhysicsVolume NewVolume)
{
	if(NewVolume.bWaterVolume)
	{
		PlaySound(sound'GeneralAmbience.steamfx4', SLOT_Interact);

		if(Level.Netmode != NM_DedicatedServer && !Level.bDropDetail && FRand() > 0.4)
			Spawn(class'SteamEmitter');

		Destroy();
	}
}

simulated function Landed(vector HitNormal)
{
	HitWall(HitNormal, None);
}

//Bounce, but stick close to surface.
simulated function HitWall(vector HitNormal, actor Wall)
{
        Velocity=(velocity *0);


}

simulated function ProcessTouch(Actor Other, Vector HitLocation){}
simulated function BlowUp(vector HitLocation){}
simulated function Explode(vector HitLocation, vector HitNormal){}

defaultproperties
{
     FlameClass=Class'FireEmitter'
     BurnDamageType=Class'Burned'
     Speed=2200.000000
     MaxSpeed=4000.000000
     TossZ=0.000000
     Damage=90.000000
     MinDamage = 18.0
     DamageRadius=220.000000
     MomentumTransfer=10000.000000
     MyDamageType=Class'FlameKill'
     LightType=LT_Steady
     LightHue=12
     LightSaturation=128
     LightBrightness=64.000000
     LightRadius=16.000000
     DrawType=DT_None
     LifeSpan=2.5000
     bFullVolume=True
     SoundVolume=255
     SoundPitch=56 
     SoundRadius=256.000000
     CollisionRadius=3.500000
     CollisionHeight=3.500000
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     bBounce=True
}
