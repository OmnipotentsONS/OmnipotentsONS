//=============================================================================
// Proj_TankShellBlue
//=============================================================================
class Proj_TankShell extends Projectile;
#exec OBJ LOAD FILE=..\Sounds\AdvancedArmor_SND.uax
var	xemitter trail;
var vector initialDir;




simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if ( Other != Instigator )
	{
		Explode(HitLocation,Normal(HitLocation-Other.Location));
	}
}

function BlowUp(vector HitLocation)
{
	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	MakeNoise(1.0);
}


simulated function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	Landed(HitNormal);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{


	if ( EffectIsRelevant(Location,false) )
	{
	    PlaySound (Sound'AdvancedArmor_SND.ExplodeLg',,6*TransientSoundVolume);
		spawn(class'CSAdvancedArmor.FX_ExplosionLg',,,HitLocation + HitNormal*16 );
	    Spawn(class'ONSTankHitRockEffect',,,HitLocation + HitNormal*16,rotator(HitNormal));

    	if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
	}
	BlowUp(HitLocation);
    Destroy();
}
simulated function Tick (float DeltaTime)
{
 if (LifeSpan < 4.5)
    {
     if (Physics != Phys_Falling)
        {
         SetPhysics(Phys_Falling);
         Velocity = Vector(Rotation) * Speed;
	     Velocity.z += TossZ;
        }
    }
 }

defaultproperties
{
     Speed=3575.000000
     Damage=650.000000
     DamageRadius=800.000000
     MomentumTransfer=98000.000000
     MyDamageType=Class'CSAdvancedArmor.DamType_HTankShell'
     ExplosionDecal=Class'XEffects.RocketMark'
     DrawType=DT_Sprite
     AmbientSound=Sound'VMVehicleSounds-S.HoverTank.IncomingShell'
     LifeSpan=6.500000
     Texture=Texture'AdvancedArmor_Tex.FlashRed'
     DrawScale=1.500000
     Skins(0)=Texture'AdvancedArmor_Tex.FlashRed'
     AmbientGlow=100
     Style=STY_Translucent
     SoundVolume=255
     SoundRadius=100.000000
     bProjTarget=True
     ForceType=FT_Constant
     ForceRadius=60.000000
     ForceScale=5.000000
}
