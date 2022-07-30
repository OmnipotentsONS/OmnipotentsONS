/******************************************************************************
DracoRocketPack

Creation date: 2013-04-28 09:23
Last change: $Id$
Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class DracoFireballSmallPack extends ONSWeapon;


//=============================================================================
// Imports
//=============================================================================

//#exec audio import file=Sounds\NapalmRocketFire.wav

var bool bTurnedOff;

simulated function Tick(float DeltaTime)
{
	if (bTurnedOff)
		return;

	if (Instigator != None && Instigator.PlayerReplicationInfo != None)
	{
		bForceCenterAim = False;
	}
	else if (!bActive && CurrentAim != rot(0,0,0))
	{
		bForceCenterAim = True;
		bActive = True;
	}
	else if (bActive && CurrentAim == rot(0,0,0))
	{
		bActive = False;
	}
}

function bool CanAttack(Actor Other)
{
	return Super.CanAttack(Other) && CheckAngle(Normal(Other.Location - WeaponFireLocation));
}

simulated function bool CheckAngle(vector Dir)
{
	local vector WeaponDir;
	
	WeaponDir = Normal(Owner.Location - Location) << Owner.Rotation;
	Dir = Dir << Owner.Rotation;
	
	if (Dir.Y > 0 ^^ WeaponDir.Y > 0)
		return true;
	
	if (Dir.X > 0)
		return Dir.X > 0.7 || Dir.Z < -0.8 || Dir.Z > 0.1;
	else
		return Dir.X < -0.5 || Dir.Z < -0.7 || Dir.Z > 0.0;
}

function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
	if (!CheckAngle(vector(WeaponFireRotation)))
	{
		if (Bot(Instigator.Controller) != None)
			DracoRocketPackPawn(Instigator).ConsiderSwitchingSides();
		else if (PlayerController(Instigator.Controller) != None)
			PlayerController(Instigator.Controller).ClientPlaySound(Sound'Denied1');
		return None;
	}
	return Super.SpawnProjectile(ProjClass, bAltFire);
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     YawBone="RocketPivot"
     PitchBone="RocketPacks"
     PitchUpLimit=12000
     PitchDownLimit=50000
   
     WeaponFireAttachmentBone="RocketPackFirePoint"
     DualFireOffset=32.000000
     bDualIndependantTargeting=True
     Spread=0.015000
     FireInterval=2.00000
     
     FireSoundClass=Sound'WVDraco.NapalmRocketFire'
     FireForce="RocketLauncherFire"
     ProjectileClass=Class'FireVehiclesV2Omni.FireballIncendiarySmall'
     AIInfo(0)=(bTrySplash=True,bLeadTarget=True,WarnTargetPct=1.000000,RefireRate=0.500000)
     Mesh=SkeletalMesh'ONSFullAnimations.MASrocketPack'
     DrawScale=0.400000
     Skins(0)=Shader'WVDraco.Skins.DracoRocketPackShader'
}
