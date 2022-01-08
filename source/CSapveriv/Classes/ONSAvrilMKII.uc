// AVRiL - Player held anti-aircraft weapon

class ONSAvrilMKII extends Weapon
	config(User);

var rotator PrevRotation;
var float	LastTimeSeconds;
var Pawn SeekTarget;
var float LockTime, UnLockTime, SeekCheckTime;
var bool bLockedOn, bBreakLock;
var bool bTightSpread;
var() float SeekCheckFreq, SeekRange;
var() float LockRequiredTime, UnLockRequiredTime;
var() float LockAim;
var Material BaseMaterial;
var Material ReticleOFFMaterial;
var Material ReticleONMaterial;
var Color CrosshairColor;
var float CrosshairX, CrosshairY;
var texture CrosshairTexture;
replication
{
    reliable if (Role == ROLE_Authority && bNetOwner)
        bLockedOn,SeekTarget;

}

simulated function OutOfAmmo()
{
}


// AI Interface
function float SuggestAttackStyle()
{
    return -0.4;
}

function float SuggestDefenseStyle()
{
    return 0.5;
}

function byte BestMode()
{
	return 0;
}

function float GetAIRating()
{
	local Bot B;
	local float ZDiff, dist, Result;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	if (Vehicle(B.Enemy) == None)
		return 0;

	result = AIRating;
	ZDiff = Instigator.Location.Z - B.Enemy.Location.Z;
	if ( ZDiff < -200 )
		result += 0.1;
	dist = VSize(B.Enemy.Location - Instigator.Location);
	if ( dist > 2000 )
		return ( FMin(2.0,result + (dist - 2000) * 0.0002) );

	return result;
}

function bool RecommendRangedAttack()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return true;

	return ( VSize(B.Enemy.Location - Instigator.Location) > 2000 * (1 + FRand()) );
}
// end AI Interface


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
                    PlayerController(Instigator.Controller).ClientPlaySound(Sound'WeaponSounds.LockOn');
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
    local Pawn P;
    P = Pawn(Other);

    if (P == None || P == Instigator || !P.bProjTarget)
        return false;

    if (!Level.Game.bTeamGame)
        return true;

    return ( (P.PlayerReplicationInfo == None) || (P.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team) );

}


simulated event RenderOverlays(Canvas Canvas)
{
	if (!FireMode[1].bIsFiring || ONSAVRiLAltFire(FireMode[1]) == None)
	{
		if (bLockedOn)
		{
			Canvas.DrawColor = CrosshairColor;
			Canvas.DrawColor.A = 255;
			Canvas.Style = ERenderStyle.STY_Alpha;
			Canvas.SetPos(Canvas.SizeX*0.5-CrosshairX, Canvas.SizeY*0.5-CrosshairY);
			Canvas.DrawTile(CrosshairTexture, CrosshairX*2.0, CrosshairY*2.0, 0.0, 0.0, CrosshairTexture.USize, CrosshairTexture.VSize);
		}

		Super.RenderOverlays(Canvas);
	}
}


function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local PROJ_AvrilMKII_Missile SeekingRocket;
	local bot B;

    bBreakLock = true;

	// decide if bot should be locked on
	B = Bot(Instigator.Controller);
	if ( (B != None) && (B.Skill > 2 + 5 * FRand()) && (FRand() < 0.6)
		&& (B.Target == B.Enemy) && (VSize(B.Enemy.Location - B.Pawn.Location) > 2000 + 2000 * FRand())
		&& (Level.TimeSeconds - B.LastSeenTime < 0.4) && (Level.TimeSeconds - B.AcquireTime > 1.5) )
	{
		bLockedOn = true;
		SeekTarget = B.Enemy;
	}

    if (bLockedOn && SeekTarget != None)
    {
        SeekingRocket = Spawn(class'CSAPVerIV.PROJ_AvrilMKII_Missile',,, Start, Dir);
        SeekingRocket.HomingTarget = SeekTarget;
        if(SeekTarget.IsA('Vehicle'))
         SeekingRocket.SetHomingTarget();
        if ( B != None )
        {
			//log("LOCKED");
			bLockedOn = false;
			SeekTarget = None;
		}
        return SeekingRocket;
    }
    else
    {
        SeekingRocket = Spawn(class'CSAPVerIV.PROJ_AvrilMKII_Missile',,, Start, Dir);
        return SeekingRocket;
    }
}

defaultproperties
{
     SeekCheckFreq=0.800000
     SeekRange=24000.000000
     LockRequiredTime=1.000000
     UnLockRequiredTime=1.000000
     LockAim=0.996000
     BaseMaterial=Texture'VMWeaponsTX.PlayerWeaponsGroup.AVRiLtex'
     ReticleOFFMaterial=Shader'VMWeaponsTX.PlayerWeaponsGroup.AVRiLreticleTEX'
     ReticleONMaterial=Shader'VMWeaponsTX.PlayerWeaponsGroup.AVRiLreticleTEXRed'
     CrossHairColor=(G=255,A=255)
     CrosshairX=32.000000
     CrosshairY=32.000000
     CrosshairTexture=Texture'ONSInterface-TX.avrilRETICLE'
     FireModeClass(0)=Class'CSAPVerIV.ONSAVRiLMKIIFire'
     FireModeClass(1)=Class'CSAPVerIV.ONSAVRiLMKIIAltFire'
     PutDownAnim="PutDown"
     SelectAnimRate=2.000000
     PutDownAnimRate=1.750000
     BringUpTime=0.450000
     SelectSound=Sound'WeaponSounds.FlakCannon.SwitchToFlakCannon'
     SelectForce="SwitchToFlakCannon"
     AIRating=0.550000
     CurrentRating=0.550000
     Description="The AVRiL MKII, or Anti-Vehicle Rocket Launcher, shoots homing missiles that pack quite a punch."
     EffectOffset=(X=100.000000,Y=32.000000,Z=-20.000000)
     DisplayFOV=45.000000
     Priority=8
     HudColor=(B=255,G=0,R=0)
     SmallViewOffset=(X=116.000000,Y=43.500000,Z=-40.500000)
     CenteredRoll=5500
     CustomCrosshair=16
     CustomCrossHairColor=(B=0,R=0)
     CustomCrossHairTextureName="ONSInterface-TX.avrilRETICLEtrack"
     MinReloadPct=0.000000
     InventoryGroup=8
     GroupOffset=1
     PickupClass=Class'CSAPVerIV.ONSAVRiLMKIIPickup'
     PlayerViewOffset=(X=100.000000,Y=35.500000,Z=-32.500000)
     BobDamping=2.200000
     AttachmentClass=Class'Onslaught.ONSAVRiLAttachment'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=429,Y1=212,X2=508,Y2=251)
     ItemName="AVRiL MKII"
     Mesh=SkeletalMesh'ONSWeapons-A.AVRiL_1st'
     AmbientGlow=64
}
