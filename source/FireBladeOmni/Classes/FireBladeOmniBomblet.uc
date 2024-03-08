class FireBladeOmniBomblet extends flakshell;

var float 			DecoyRange;				// Much much range before the decoy says look at me
// Override Flakshell PostBeginPlay
var int NumBomblets;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	Velocity = Speed * Vector(Rotation);
	if (Instigator != None)
		Velocity += Instigator.Velocity;
}


simulated function Explode(vector HitLocation, vector HitNormal)
{
	  local vector start;
    local rotator rot;
    local int i;
    local Projectile NewChunk;
            // FlakRatChunk
            // FlakRatMortarBomblet

	start = Location + 10 * HitNormal;
	if ( Role == ROLE_Authority )
	{

		HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation);
	  if ( EffectIsRelevant(Location,false) )
       {
        Spawn(class'NewExplosionB',,, HitLocation, rotator(vect(0,0,1)));
		    Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }
		for (i=0; i<NumBomblets; i++)  // i<10 // i<20
		{
			rot = Rotation;
			rot.yaw += FRand()*32000-16000;
			rot.pitch += FRand()*32000-16000;
			rot.roll += FRand()*32000-16000;

			
			//NewChunk = Spawn( class'FireBladeOmniBomblet',,'', Start, rot);
			NewChunk = Spawn( class'FireBladeOmniNapalmGlob',,'', Start, rot);
      if (NewChunk != None) NewChunk.InstigatorController = InstigatorController;

		}
	}
    Destroy();
}


function bool CheckRange(actor Aggressor)
{
	return vsize(Aggressor.Location - location) <= DecoyRange;
}


defaultproperties
{
 
     Speed=400.000000
     MaxSpeed=800.0000
     LifeSpan=3.000000
     bOrientToVelocity=True
     ForceType=FT_Constant
     ForceRadius=512.000000
     ForceScale=2.000000
     Physics=PHYS_Falling
     TossZ=20.000000
     MyDamageType=Class'FireBladeOmni.DamTypeFBOFlakShell'
     StaticMesh=StaticMesh'WeaponStaticMesh.FlakShell'
     DrawScale=3.000000
     CullDistance=12000
     DamageRadius=512
     Damage=50 // close in flak chunkss/shrapnel do more
     NumBomblets=4
     MomentumTransfer=20000
}
