//=============================================================================
// PredatorBladesDeco.
//=============================================================================
class Deco_PredatorBlades extends Decoration;

var bool bLeftBladeBroke;
var bool bRightBladeBroke;
var bool bClientLeftBladeBroke;
var bool bClientRightBladeBroke;
var bool bFrontBladeBroke;
var bool bRearBladeBroke;
var bool bClientFrontBladeBroke;
var bool bClientRearBladeBroke;

var() sound BladeBreakSound;
// Damage attributes.
var   float    Damage;
var	  float	   DamageRadius;
var   float	   MomentumTransfer; // Momentum magnitude imparted by impacting projectile.
var   class<DamageType>	   MyDamageType;
var Controller	InstigatorController;

var Actor LastTouched;
var Actor HurtWall;
var float MaxEffectDistance;
var float BladeInstigatorDamage;  // when blades to damage to others vehicle takes some damage.

replication
{
    reliable if (bNetDirty && Role == ROLE_Authority)
        bClientLeftBladeBroke, bClientRightBladeBroke,bClientFrontBladeBroke,bClientRearBladeBroke;
}
simulated function PostBeginPlay()
{

    if ( Role == ROLE_Authority && Instigator != None && Instigator.Controller != None )
    	InstigatorController = Instigator.Controller;
    super.PostBeginPlay();
}

singular function BaseChange();

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/


simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if ( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		{
		    if (Vehicle(Victims) != None )
		        return;

			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			if ( Victims == LastTouched )
				LastTouched = None;
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);

		}
	}
	if ( (LastTouched != None) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
	{
		Victims = LastTouched;
		LastTouched = None;
		dir = Victims.Location - HitLocation;
		dist = FMax(1,VSize(dir));
		dir = dir/dist;
		damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));
		if ( Instigator == None || Instigator.Controller == None )
			Victims.SetDelayedDamageInstigatorController(InstigatorController);
		Victims.TakeDamage
		(
			damageScale * DamageAmount,
			Instigator,
			Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
			(damageScale * Momentum * dir),
			DamageType
		);
	}

	bHurtEntry = false;
}

simulated function ClientSideTouch(Actor Other, Vector HitLocation)
{
    if(Other.IsA('Vehicle'))
       Other.TakeDamage(Damage/3, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
	else
    Other.TakeDamage(Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
    Instigator.TakeDamage(BladeInstigatorDamage, Instigator, HitLocation, Velocity * 100, class'DamType_Crashed');
}


simulated function Tick(float DT)
{
    local coords BladeBaseCoords, BladeLTipCoords,BladeRTipCoords,BladeFTipCoords,BladeRearTipCoords;
    local vector HitLocation, HitNormal;
    local actor Victim;

    Super.Tick(DT);

    // Left Blade System
    if (Role == ROLE_Authority && !bLeftBladeBroke)
    {
        BladeBaseCoords = GetBoneCoords('BladeAttMain');
        BladeLTipCoords = GetBoneCoords('LeftBlade');
        Victim = Trace(HitLocation, HitNormal, BladeLTipCoords.Origin, BladeBaseCoords.Origin);

        if (Victim != None && Victim.bBlockActors)
        {
            if (Victim.IsA('Pawn') && !Victim.IsA('Vehicle'))
                Pawn(Victim).TakeDamage(1000, Instigator, HitLocation, Velocity * 100, class'DamType_PredatorBlades');
            else
            {
                bLeftBladeBroke = True;
                bClientLeftBladeBroke = True;
                BladeBreakOff();
                Instigator.TakeDamage(BladeInstigatorDamage, Instigator, HitLocation, Velocity * 100, class'DamType_Crashed');
            }
        }
    }
    if (Role < ROLE_Authority && bClientLeftBladeBroke)
    {
        bLeftBladeBroke = True;
        bClientLeftBladeBroke = False;
        BladeBreakOff();
    }

    // Right Blade System
    if (Role == ROLE_Authority && !bRightBladeBroke)
    {
        BladeBaseCoords = GetBoneCoords('BladeAttMain');
        BladeRTipCoords = GetBoneCoords('RightBlade');
        Victim = Trace(HitLocation, HitNormal, BladeRTipCoords.Origin, BladeBaseCoords.Origin);

        if (Victim != None && Victim.bBlockActors)
        {
            if (Victim.IsA('Pawn') && !Victim.IsA('Vehicle'))
                Pawn(Victim).TakeDamage(1000, Instigator, HitLocation, Velocity * 100, class'DamType_PredatorBlades');
            else
            {
                bRightBladeBroke = True;
                bClientRightBladeBroke = True;
                BladeBreakOff();
                Instigator.TakeDamage(BladeInstigatorDamage, Instigator, HitLocation, Velocity * 100, class'DamType_Crashed');
            }
        }
    }
    if (Role < ROLE_Authority && bClientRightBladeBroke)
    {
        bRightBladeBroke = True;
        bClientRightBladeBroke = False;
        BladeBreakOff();
    }
  // Front Blade System
    if (Role == ROLE_Authority && !bFrontBladeBroke)
    {
        BladeBaseCoords = GetBoneCoords('BladeAttMain');
        BladeFTipCoords = GetBoneCoords('FrontBlade');
        Victim = Trace(HitLocation, HitNormal, BladeFTipCoords.Origin, BladeBaseCoords.Origin);

        if (Victim != None && Victim.bBlockActors)
        {
            if (Victim.IsA('Pawn') && !Victim.IsA('Vehicle'))
                Pawn(Victim).TakeDamage(1000, Instigator, HitLocation, Velocity * 100, class'DamType_PredatorBlades');
            else
            {
                bFrontBladeBroke = True;
                bClientFrontBladeBroke = True;
                BladeBreakOff();
                Instigator.TakeDamage(BladeInstigatorDamage, Instigator, HitLocation, Velocity * 100, class'DamType_Crashed');
            }
        }
    }
    if (Role < ROLE_Authority && bClientFrontBladeBroke)
    {
        bFrontBladeBroke = True;
        bClientFrontBladeBroke = False;
        BladeBreakOff();
    }

    // Rear Blade System
    if (Role == ROLE_Authority && !bRearBladeBroke)
    {
        BladeBaseCoords = GetBoneCoords('BladeAttMain');
        BladeRearTipCoords = GetBoneCoords('BackBlade');
        Victim = Trace(HitLocation, HitNormal, BladeRearTipCoords.Origin, BladeBaseCoords.Origin);

        if (Victim != None && Victim.bBlockActors)
        {
            if (Victim.IsA('Pawn') && !Victim.IsA('Vehicle'))
                Pawn(Victim).TakeDamage(1000, Instigator, HitLocation, Velocity * 100, class'DamType_PredatorBlades');
            else
            {
                bRearBladeBroke = True;
                bClientRearBladeBroke = True;
                BladeBreakOff();
                Instigator.TakeDamage(BladeInstigatorDamage, Instigator, HitLocation, Velocity * 100, class'DamType_Crashed');
            }
        }
    }
    if (Role < ROLE_Authority && bClientRearBladeBroke)
    {
        bRearBladeBroke = True;
        bClientRearBladeBroke = False;
        BladeBreakOff();
    }

}

simulated function BladeBreakOff()
{
    PlaySound(BladeBreakSound, SLOT_None, 2.0,,,, False);

}

defaultproperties
{
     BladeBreakSound=Sound'ONSVehicleSounds-S.RV.RVBladeBreakOff'
     Damage=175.000000
     DamageRadius=256.000000
     MomentumTransfer=200000.000000
     BladeInstigatorDamage=10
     MyDamageType=Class'CSAPVerIV.DamType_PredatorBlades'
     bStatic=False
     bStasis=False
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'APVerIV_Anim.PBladesB'
     Style=STY_Additive
     bShouldBaseAtStartup=False
     bHardAttach=True
     CollisionRadius=256.000000
     CollisionHeight=4.000000
     bUseCylinderCollision=True
     Mass=0.000000
}
