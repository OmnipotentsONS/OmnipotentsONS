//=============================================================================
// Weapon_Missiles
//=============================================================================
// Adapted from Laurent Delayen
// � 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class Weapon_Missiles extends Weapon
    config(user)
    HideDropDown
	CacheExempt;
var rotator PrevRotation;
var float	LastTimeSeconds;
var Pawn SeekTarget;
var float LockTime, UnLockTime, SeekCheckTime;
var bool bLockedOn, bBreakLock;
var() float SeekCheckFreq, SeekRange;
var() float LockRequiredTime, UnLockRequiredTime;
var() float LockAim;

replication
{
    reliable if (Role == ROLE_Authority && bNetOwner)
        bLockedOn,SeekTarget;
}
/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	if ( Instigator.Controller.Enemy == None )
		return 0;
	if ( GameObjective(Instigator.Controller.Focus) != None )
		return 0;

	if ( Instigator.Controller.bFire != 0 )
		return 0;
	else if ( Instigator.Controller.bAltFire != 0 )
		return 1;
	if ( FRand() < 0.65 )
		return 1;
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
function Tick(float dt)
{
    local Pawn Other;
    local Vector StartTrace;
    local Rotator Aim;
    local float BestDist, BestAim;

    if (Instigator == None || Instigator.Weapon != self)
        return;

	if ( Role < ROLE_Authority )
		return;

    if ( !Instigator.IsHumanControlled() )
        return;

    if (Level.TimeSeconds > SeekCheckTime)
    {
        if (bBreakLock)
        {
            bBreakLock = false;
            bLockedOn = false;
            SeekTarget = None;
        }

        StartTrace = Instigator.Location + Instigator.EyePosition();
        Aim = Instigator.GetViewRotation();

        BestAim = LockAim;
        Other = Instigator.Controller.PickTarget(BestAim, BestDist, Vector(Aim), StartTrace, SeekRange);

        if ( CanLockOnTo(Other) )
        {
            if (Other == SeekTarget)
            {
                LockTime += SeekCheckFreq;
                if (!bLockedOn && LockTime >= LockRequiredTime)
                {
                    bLockedOn = true;
                    PlayerController(Instigator.Controller).ClientPlaySound(Sound'CicadaSnds.Hud.TargetLock');
                 }
            }
            else
            {
                SeekTarget = Other;
                LockTime = 0.0;
            }
            UnLockTime = 0.0;
        }
        else
        {
            if (SeekTarget != None)
            {
                UnLockTime += SeekCheckFreq;
                if (UnLockTime >= UnLockRequiredTime)
                {
                    SeekTarget = None;
                    if (bLockedOn)
                    {
                        bLockedOn = false;
                        PlayerController(Instigator.Controller).ClientPlaySound(Sound'WeaponSounds.SeekLost');
                    }
                }
            }
            else
                 bLockedOn = false;
         }
        SeekCheckTime = Level.TimeSeconds + SeekCheckFreq;
    }
}

function bool CanLockOnTo(Actor Other)
{
    local Vehicle V;
    V = Vehicle(Other);

    if (V == None || V == Instigator || !V.bProjTarget)
        return false;

    if (!Level.Game.bTeamGame)
        return true;

    return ( (V.PlayerReplicationInfo == None) || (V.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team) );
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
    local PROJ_Fighter_Missile Missile;
    local bot B;
     bBreakLock = true;
    //StartVelocity = Instigator.Velocity;
     // decide if bot should be locked on
	B = Bot(Instigator.Controller);
	if  ((B != None) && (B.Target == B.Enemy) && (VSize(B.Enemy.Location - B.Pawn.Location) > 2000 + 2000 * FRand())&& (Level.TimeSeconds - B.LastSeenTime < 0.4))
	{
		bLockedOn = true;
		SeekTarget = B.Enemy;
		if (SeekTarget.IsA('Vehicle'))
		Vehicle(SeekTarget).NotifyEnemyLockedOn();
	}

  if (bLockedOn && SeekTarget != None)
    {
        Missile = Spawn(class'PROJ_Fighter_Missile',,, Start, Dir);
        //Missile.Velocity = StartVelocity;

        if (SeekTarget.IsA('Vehicle'))
          {
		   Vehicle(SeekTarget).NotifyEnemyLockedOn();
		   Missile.HomingTarget = Vehicle(SeekTarget);
		   }
        if ( B != None )
        {
			//log("LOCKED");
			bLockedOn = false;
			SeekTarget = None;
		}
        return Missile;
    }
   else
    {
        Missile = Spawn(class'PROJ_Fighter_Missile',,, Start, Dir);
        return Missile;
    }
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
//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     SeekCheckFreq=0.800000
     SeekRange=35000.000000
     LockRequiredTime=0.250000
     UnLockRequiredTime=3.000000
     LockAim=0.996000
     FireModeClass(0)=Class'CSAPVerIV.WeaponFire_FighterMissileFire'
     FireModeClass(1)=Class'CSAPVerIV.WeaponFire_DummyFire'
     AIRating=0.780000
     CurrentRating=0.780000
     bCanThrow=False
     bNoInstagibReplace=True
     Priority=8
     SmallViewOffset=(X=30.000000,Z=-40.000000)
     InventoryGroup=8
     PlayerViewOffset=(X=30.000000,Z=-40.000000)
     AttachmentClass=Class'CSAPVerIV.WA_FighterMissileAttachment'
     ItemName="Missiles"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'APVerIV_ST.Excalibur_ST.Ex_Cockpit'
     DrawScale3D=(Z=0.700000)
     AmbientGlow=100
}
