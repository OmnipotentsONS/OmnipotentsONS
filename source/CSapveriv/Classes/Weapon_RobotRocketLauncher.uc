//=============================================================================
class Weapon_RobotRocketLauncher extends Weapon
    config(user)
    HideDropDown
	CacheExempt;


var bool bTightSpread;
var bool bRight;
var rotator PrevRotation;
var float	LastTimeSeconds;
var Pawn SeekTarget;
var float LockTime, UnLockTime, SeekCheckTime;
var bool bLockedOn, bBreakLock;
var() float SeekCheckFreq, SeekRange;
var() float LockRequiredTime, UnLockRequiredTime;
var() float LockAim;
var color CrosshairColor;
var float CrosshairX, CrosshairY;
var texture CrosshairTexture;
replication
{
    reliable if (Role < ROLE_Authority)
        ServerSetTightSpread, ServerClearTightSpread;
    reliable if (Role == ROLE_Authority && bNetOwner)
        bLockedOn,SeekTarget;
}
simulated event RenderOverlays( Canvas Canvas )
{
    local int XPos, YPos;
	local vector ScreenPos;
	local float RatioX, RatioY;
	local float tileX, tileY;
	local float SizeX, SizeY, PosDotDir;
	local vector CameraLocation, CamDir;
	local rotator CameraRotation;
    if (bLockedOn)
    {
    Canvas.DrawColor = CrosshairColor;
       Canvas.DrawColor.A = 255;
       Canvas.Style = ERenderStyle.STY_Alpha;

    SizeX = 30.0;
	SizeY = 30.0;

	ScreenPos = Canvas.WorldToScreen(SeekTarget.Location);

	// Dont draw reticule if target is behind camera
	Canvas.GetCameraLocation( CameraLocation, CameraRotation );
	CamDir = vector(CameraRotation);
	PosDotDir = (SeekTarget.Location - CameraLocation) dot CamDir;
	if( PosDotDir < 0)
		return;

	RatioX = Canvas.SizeX / 640.0;
	RatioY = Canvas.SizeY / 480.0;

	tileX = sizeX * RatioX;
	tileY = sizeY * RatioX;

	XPos = ScreenPos.X;
	YPos = ScreenPos.Y;

    Canvas.DrawColor = CrosshairColor;
	Canvas.DrawColor.A = 255;
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.SetPos(XPos - tileX*0.5, YPos - tileY*0.5);
	Canvas.DrawTile( CrosshairTexture, tileX, tileY, 0.0, 0.0, 128, 128); //--- TODO : Fix HARDCODED USIZE




    }

    Super.RenderOverlays(Canvas);
}
function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Proj_MissileRocketProj Rocket;
    local vector StartVelocity;
    local bot B;
     bBreakLock = true;
    StartVelocity = Instigator.Velocity;
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
        Rocket = Spawn(class'Proj_MissileRocketProj',,, Start, Dir);
        Rocket.Velocity = StartVelocity;
        Rocket.CurrentTarget = SeekTarget;
        if (SeekTarget.IsA('Vehicle'))
		Vehicle(SeekTarget).NotifyEnemyLockedOn();
        if ( B != None )
        {
			//log("LOCKED");
			bLockedOn = false;
			SeekTarget = None;
		}
        return Rocket;
    }
   else
    {
        Rocket = Spawn(class'Proj_MissileRocketProj',,, Start, Dir);
        return Rocket;
    }
}

simulated event ClientStartFire(int Mode)
{
	local int OtherMode;

	if ( WeaponFire_RobotRocketMultiFire(FireMode[Mode]) != None )
	{
		SetTightSpread(true);
	}
    else
    {
		if ( Mode == 0 )
			OtherMode = 1;
		else
			OtherMode = 0;

		if ( FireMode[OtherMode].bIsFiring || (FireMode[OtherMode].NextFireTime > Level.TimeSeconds) )
		{
			if ( FireMode[OtherMode].Load > 0 )
				SetTightSpread(true);
			if ( bDebugging )
				log("No RL reg fire because other firing "$FireMode[OtherMode].bIsFiring$" next fire "$(FireMode[OtherMode].NextFireTime - Level.TimeSeconds));
			return;
		}
	}
    Super.ClientStartFire(Mode);
}

simulated function bool StartFire(int Mode)
{
	local int OtherMode;

	if ( Mode == 0 )
		OtherMode = 1;
	else
		OtherMode = 0;
	if ( FireMode[OtherMode].bIsFiring || (FireMode[OtherMode].NextFireTime > Level.TimeSeconds) )
		return false;

	return Super.StartFire(Mode);
}

simulated function SetTightSpread(bool bNew, optional bool bForce)
{
	if ( (bTightSpread != bNew) || bForce )
	{
		bTightSpread = bNew;
		if ( bTightSpread )
			ServerSetTightSpread();
		else
			ServerClearTightSpread();
	}
}

function ServerClearTightSpread()
{
	bTightSpread = false;
}

function ServerSetTightSpread()
{
	bTightSpread = true;
}




// tell bot how valuable this weapon would be to use, based on the bot's combat situation
// also suggest whether to use regular or alternate fire mode
function float GetAIRating()
{
	local Bot B;
	local float EnemyDist, Rating, ZDiff;
	local vector EnemyDir;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	// if standing on a lift, make sure not about to go around a corner and lose sight of target
	// (don't want to blow up a rocket in bot's face)
	if ( (Instigator.Base != None) && (Instigator.Base.Velocity != vect(0,0,0))
		&& !B.CheckFutureSight(0.1) )
		return 0.1;

	EnemyDir = B.Enemy.Location - Instigator.Location;
	EnemyDist = VSize(EnemyDir);
	Rating = AIRating;

	// don't pick rocket launcher if enemy is too close
	if ( EnemyDist < 360 )
	{
		if ( Instigator.Weapon == self )
		{
			// don't switch away from rocket launcher unless really bad tactical situation
			if ( (EnemyDist > 250) || ((Instigator.Health < 50) && (Instigator.Health < B.Enemy.Health - 30)) )
				return Rating;
		}
		return 0.05 + EnemyDist * 0.001;
	}

	// rockets are good if higher than target, bad if lower than target
	ZDiff = Instigator.Location.Z - B.Enemy.Location.Z;
	if ( ZDiff > 120 )
		Rating += 0.25;
	else if ( ZDiff < -160 )
		Rating -= 0.35;
	else if ( ZDiff < -80 )
		Rating -= 0.05;
	if ( (B.Enemy.Weapon != None) && B.Enemy.Weapon.bMeleeWeapon && (EnemyDist < 2500) )
		Rating += 0.25;

	return Rating;
}

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

defaultproperties
{
     SeekCheckFreq=0.800000
     SeekRange=28000.000000
     LockRequiredTime=0.250000
     UnLockRequiredTime=2.000000
     LockAim=0.996000
     CrossHairColor=(R=255,A=255)
     CrosshairX=40.000000
     CrosshairY=40.000000
     CrosshairTexture=Texture'ONSInterface-TX.tankBarrelAligned'
     FireModeClass(0)=Class'CSAPVerIV.WeaponFire_RobotRocketMultiFire'
     FireModeClass(1)=Class'CSAPVerIV.WeaponFire_DummyFire'
     AIRating=0.780000
     CurrentRating=0.780000
     bCanThrow=False
     bNoInstagibReplace=True
     Priority=4
     SmallViewOffset=(X=30.000000,Z=-40.000000)
     CustomCrosshair=8
     CustomCrossHairColor=(B=0,G=0)
     CustomCrossHairTextureName="Crosshairs.Hud.Crosshair_Triad2"
     InventoryGroup=6
     PlayerViewOffset=(X=30.000000,Z=-40.000000)
     AttachmentClass=Class'CSAPVerIV.WA_RoboRocketAttachment'
     ItemName="Rocket Launcher"
     DrawType=DT_None
     AmbientGlow=0
}
