//-----------------------------------------------------------
//  When out in the world, this can be used to decoy an avril.
//-----------------------------------------------------------
class Proj_FighterChaff extends Projectile;

var class<emitter> 	DecoyFlightSFXClass; 	// Class of the emitter to spawn for the effect
var class<emitter> 	DecoyLaunchSFXClass;	// class of the emitter to spawn when launched
var emitter			DecoyFlightSFX;			// The actual effect

var AirPower_Fighter	ProtectedTarget;	// Protect this vehicle
var Predator	ProtectedTargetB;

replication
{
   	reliable if (Role == ROLE_Authority)
   	       ProtectedTarget,ProtectedTargetB;
}
simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	Velocity = Speed * Vector(Rotation);
}

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	if(Owner!=none)
	{
    if(Owner.IsA('AirPower_Fighter'))
        ProtectedTarget=AirPower_Fighter(Owner);
    if(Owner.IsA('Predator'))
        ProtectedTargetB=Predator(Owner);
    }
	if ( EffectIsRelevant(Location, false) )
		Spawn(DecoyLaunchSFXClass,,,location,Rotation);

	if ( (Level.NetMode != NM_DedicatedServer) && (DecoyFlightSFXClass != None) )
	{
		DecoyFlightSFX = spawn(DecoyFlightSFXClass);
		if (DecoyFlightSFX!=None)
			DecoyFlightSFX.SetBase(self);
	}
}

simulated event Destroyed()
{
	if (ProtectedTarget!=None)
	   {
	    ProtectedTarget.Decoy=none;
	    if (DecoyFlightSFX!=None)
		DecoyFlightSFX.Destroy();
				return;
        }
     if (ProtectedTargetB!=None)
	   {
	    ProtectedTargetB.Decoy=none;
	    if (DecoyFlightSFX!=None)
		DecoyFlightSFX.Destroy();
				return;
        }

	if (DecoyFlightSFX!=None)
		DecoyFlightSFX.Destroy();
	super.Destroyed();
}


simulated function Landed( vector HitNormal )
{
	super.Landed(HitNormal);
	Destroy();
}

defaultproperties
{
     DecoyFlightSFXClass=Class'OnslaughtBP.ONSDecoyFlight'
     DecoyLaunchSFXClass=Class'OnslaughtBP.ONSDecoyLaunch'
     Speed=1000.000000
     MaxSpeed=1500.000000
     Damage=50.000000
     DamageRadius=250.000000
     MomentumTransfer=10000.000000
     Physics=PHYS_Falling
     AmbientSound=Sound'CicadaSnds.Decoy.DecoyFlight'
     LifeSpan=5.000000
     bBounce=True
}
