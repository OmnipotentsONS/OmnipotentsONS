//=============================================================================
// Weapon_Rockets
//=============================================================================
// Adapted from Laurent Delayen
// � 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class Weapon_FRockets extends Weapon
    config(user)
    HideDropDown
	CacheExempt;
var rotator PrevRotation;
var float	LastTimeSeconds;
var PROJ_PredatorRocket Rocket;
var rotator WeaponFireRotation;
var vector WeaponFireLocation,ProjSpawnOffset;
var vector FireLocA,FireLocB,FireLocC,FireLocD,FireLocE;
var()   sound           FireSoundClass;
var()   float           FireSoundVolume;
var()   float           FireSoundRadius;
var()	float           FireSoundPitch;
var Vector  X,Y,Z;
var vector RocketOffsetA,RocketOffsetB;
/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	return 0;
}
simulated final function float	CalcInertia(float DeltaTime, float FrictionFactor, float OldValue, float NewValue)
{
	local float	Friction;

	Friction = 1.f - FClamp( (0.02*FrictionFactor) ** DeltaTime, 0.f, 1.f);
	return	OldValue*Friction + NewValue;
}

simulated function PreDrawFPWeapon()
{
	local Rotator	DeltaRot, NewRot;
	local float		myDeltaTime;

	PlayerViewOffset = default.PlayerViewOffset;
	SetLocation( Instigator.Location + Instigator.CalcDrawOffset(Self) );

	if ( PrevRotation == rot(0,0,0) )
		PrevRotation = Instigator.Rotation;

	myDeltaTime		= Level.TimeSeconds - LastTimeSeconds;
	LastTimeSeconds	= Level.TimeSeconds;
	DeltaRot		= Normalize(Instigator.Rotation - PrevRotation);
	NewRot.Yaw		= CalcInertia(myDeltaTime, 0.0001, DeltaRot.Yaw, PrevRotation.Yaw);
	NewRot.Pitch	= CalcInertia(myDeltaTime, 0.0001, DeltaRot.Pitch, PrevRotation.Pitch);
	NewRot.Roll		= CalcInertia(myDeltaTime, 0.0001, DeltaRot.Roll, PrevRotation.Roll);
	PrevRotation	= NewRot;
	SetRotation( NewRot );
}


simulated function bool HasAmmo()
{
    return true;
}

function float SuggestAttackStyle()
{
    return 1.0;
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    //StartVelocity = Instigator.Velocity;
     // decide if bot should be locked on
        WeaponFireLocation=Start;
        WeaponFireRotation=Dir;
        Rocket = Spawn(class'PROJ_PredatorRocket',,, Start, Dir);
        gotostate('FireRocketVolly');
        return Rocket;

}

state FireRocketVolly
{
 Begin:
      PlaySound(FireSoundClass,SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
      WeaponFireLocation=MyGetFireStart();
      FireLocA = WeaponFireLocation + Vect(0,30,0);
      spawn(class'PROJ_PredatorRocket', self, , FireLocA,WeaponFireRotation);
      sleep(0.15);
      PlaySound(FireSoundClass,SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
      WeaponFireLocation=MyGetFireStart();
      FireLocB = WeaponFireLocation + Vect(0,-30,0);
      spawn(class'PROJ_PredatorRocket', self, , FireLocB,WeaponFireRotation);
      sleep(0.15);
      PlaySound(FireSoundClass,SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
      WeaponFireLocation=MyGetFireStart();
      FireLocC = WeaponFireLocation + Vect(0,-30,-30);
      spawn(class'PROJ_PredatorRocket', self, , FireLocC,WeaponFireRotation);
      sleep(0.15);
      PlaySound(FireSoundClass,SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
      WeaponFireLocation=MyGetFireStart();
      FireLocD = WeaponFireLocation + Vect(0,30,-30);
      spawn(class'PROJ_PredatorRocket', self, , FireLocD,WeaponFireRotation);
      sleep(0.15);
      PlaySound(FireSoundClass,SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
      WeaponFireLocation=MyGetFireStart();
      FireLocE = WeaponFireLocation + Vect(0,0,-30);
      spawn(class'PROJ_PredatorRocket', self, , FireLocE,WeaponFireRotation);
}
simulated function bool PutDown()
{
    local int Mode;

    if (ClientState == WS_BringUp || ClientState == WS_ReadyToFire)
    {
        if ( (Instigator.PendingWeapon != None) && !Instigator.PendingWeapon.bForceSwitch )
        {
            for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
            {
                if ( FireMode[Mode].bFireOnRelease && FireMode[Mode].bIsFiring )
                    return false;
            }
        }

        if (Instigator.IsLocallyControlled())
        {
            for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
            {
                if ( FireMode[Mode].bIsFiring )
                    ClientStopFire(Mode);
            }

        }
        ClientState = WS_PutDown;
    }
    for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
    {
		FireMode[Mode].bServerDelayStartFire = false;
		FireMode[Mode].bServerDelayStopFire = false;
	}
    Instigator.AmbientSound = None;
    OldWeapon = None;
    return true; // return false if preventing weapon switch
}

simulated function vector MyGetFireStart()
{
   if(AirPower_Fighter(Instigator).bLeftRocket==false)
   return AirPower_Fighter(Instigator).Location + RocketOffsetA;
   else
   return AirPower_Fighter(Instigator).Location + RocketOffsetB;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     ProjSpawnOffset=(Z=-25.000000)
     FireSoundClass=Sound'CicadaSnds.Missile.MissileIgnite'
     FireSoundVolume=70.000000
     FireSoundRadius=300.000000
     FireSoundPitch=1.000000
     RocketOffsetA=(X=-20.000000,Y=-86.000000,Z=-32.000000)
     RocketOffsetB=(X=-20.000000,Y=86.000000,Z=-32.000000)
     FireModeClass(0)=Class'CSAPVerIV.WeaponFire_FighterRocketFire'
     FireModeClass(1)=Class'CSAPVerIV.WeaponFire_DummyFire'
     AIRating=0.780000
     CurrentRating=0.780000
     bCanThrow=False
     bNoInstagibReplace=True
     Priority=9
     SmallViewOffset=(X=30.000000,Z=-40.000000)
     InventoryGroup=5
     PlayerViewOffset=(X=30.000000,Z=-40.000000)
     AttachmentClass=Class'CSAPVerIV.WA_FighterMissileAttachment'
     ItemName="rockets"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'APVerIV_ST.Excalibur_ST.Ex_Cockpit'
     DrawScale3D=(Z=0.700000)
     AmbientGlow=100
}
