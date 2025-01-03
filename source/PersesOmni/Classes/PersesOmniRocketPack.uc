/******************************************************************************
PersesRocketPack

Creation date: 2011-08-19 21:45
Last change: $Id$
Copyright © 2011, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class PersesOmniRocketPack extends ONSWeapon;


//=============================================================================
// Imports
//=============================================================================

#exec audio import file=Sounds\MercIgnite.wav
#exec audio import file=Sounds\FragMissileFire.wav
#exec audio import file=Sounds\HomingMissileFire.wav
#exec audio import file=Sounds\NapalmRocketFire.wav

//exec texture import file=Textures\PersesHud.dds alpha=1 lodset=5


//=============================================================================
// Structs
//=============================================================================

struct TProjectileType
{
	var() class<PersesOmniProjectileBase> ProjectileClass;
	var() Sound FireSound;
	var() float FireInterval;
	var() HudBase.SpriteWidget BarWeaponIcon;
	var() float BarBorderScaledPosition;
	var() HudBase.SpriteWidget BarBorder;
	var() HudBase.NumericWidget BarWeaponSlot;
};


//=============================================================================
// Properties
//=============================================================================

var() array<vector> FireOffsets;
var() array<TProjectileType> ProjectileTypes;


//=============================================================================
// Variables
//=============================================================================

var int CurrentOffsetIndex;
var int CurrentProjectileType;
var byte RepProjectileType;
var float ProjectileSwitchTime;


//=============================================================================
// Replication
//=============================================================================

replication
{
	reliable if (bNetInitial || bNetDirty)
		RepProjectileType;
}

simulated function PostNetReceive()
{
	Super.PostNetReceive();
	
	if (CurrentProjectileType != RepProjectileType)
		ChangeProjectile(RepProjectileType);
}

event bool AttemptFire(Controller C, bool bAltFire)
{
	if (Super.AttemptFire(C, bAltFire)) {
		CurrentOffsetIndex = (CurrentOffsetIndex + 1) % FireOffsets.Length;
		return true;
	}
	return false;
}

function byte BestMode()
{
	return 0;
}

simulated function ChangeProjectile(byte NewProjectileType)
{
	local HudCDeathMatch H;
	local PlayerController PC;
	
	if (CurrentProjectileType == NewProjectileType || NewProjectileType >= ProjectileTypes.Length)
		return;
	
	CurrentProjectileType = NewProjectileType;
	ProjectileClass = ProjectileTypes[CurrentProjectileType].ProjectileClass;
	FireSoundClass = ProjectileTypes[CurrentProjectileType].FireSound;
	FireInterval = ProjectileTypes[CurrentProjectileType].FireInterval;
	RepProjectileType = NewProjectileType;
	ProjectileSwitchTime = Level.TimeSeconds;
	
	PC = Level.GetLocalPlayerController();
	if (PC != None)
	{
		H = HudCDeathMatch(PC.MyHud);
		if (H.PawnOwner == Owner && H.PlayerOwner.Pawn == Owner)
		{
			H.VehicleName = ProjectileTypes[CurrentProjectileType].ProjectileClass.default.ProjectileName;
			H.VehicleDrawTimer = Level.TimeSeconds + 1.5;
		}
	}
}

simulated function CalcWeaponFire()
{
	local coords WeaponBoneCoords;
	local vector CurrentFireOffset;

	// Calculate fire offset in world space
	WeaponBoneCoords = GetBoneCoords(WeaponFireAttachmentBone);
	CurrentFireOffset = (WeaponFireOffset * vect(1,0,0)) + FireOffsets[CurrentOffsetIndex];

	// Calculate rotation of the gun
	WeaponFireRotation = rotator(vector(CurrentAim) >> Rotation);

	// Calculate exact fire location
	WeaponFireLocation = WeaponBoneCoords.Origin + (CurrentFireOffset >> WeaponFireRotation);

	// Adjust fire rotation taking dual offset into account
	if (bDualIndependantTargeting)
		WeaponFireRotation = rotator(CurrentHitLocation - WeaponFireLocation);
}


function bool CanAttack(Actor Other)
{
	local vector HitLocation, HitNormal;
	local actor HitActor;
	local float CheckDist;

	if (Instigator == None || Instigator.Controller == None || VSize(Instigator.Location - Other.Location) > MaxRange() || !LineOfSightTo(Other))
		return false;

	// happens before picking projectile type, so assumptions will have to suffice
	CheckDist = FMin(5000.0, VSize(Other.Location - Location));
	
	// check that would hit target, and not a friendly
	CalcWeaponFire();
	HitActor = Instigator.Trace(HitLocation, HitNormal, WeaponFireLocation + CheckDist * Normal(Other.Location + Other.CollisionHeight * vect(0,0,0.8) - Location), WeaponFireLocation, true);

	return (HitActor == None || HitActor == Other || Pawn(HitActor) == None || Pawn(HitActor).Controller == None || !Instigator.Controller.SameTeamAs(Pawn(HitActor).Controller));
}


/**
Controller.LineOfSightTo() checks from point above pawn center, which is very very wrong for the rocket pack.
This implementation should be similar to the Controller version, except that it actually checks from a useful location.
*/
function bool LineOfSightTo(Actor Other)
{
	local float dist;
	local vector X, Y, Z;

	if (Other == None || Instigator == None || Instigator.Controller == None)
		return False;

	dist = VSize(Location - Other.Location);
	if (Region.Zone.bDistanceFog && dist > Region.Zone.DistanceFogEnd + Other.CollisionRadius + Other.CollisionHeight)
		return false; // hidden in distance fog

	if (Other == Instigator.Controller.Enemy) {
		if (FastTrace(Other.Location, Location) || Instigator.Controller.Enemy.BaseEyeHeight != 0 && FastTrace(Instigator.Controller.Enemy.Location + vect(0,0,1) * Instigator.Controller.Enemy.BaseEyeHeight)) {
			// update enemy info
			Instigator.Controller.LastSeenTime    = Level.TimeSeconds;
			Instigator.Controller.LastSeeingPos   = Location;
			Instigator.Controller.LastSeenPos     = Instigator.Controller.Enemy.Location;
			Instigator.Controller.bEnemyInfoValid = true;
			return true;
		}
	}
	else {
		if (FastTrace(Other.Location, Location))
			return true;
		/*
		if (dist > 8000 || Pawn(Other) == None && dist > 2000)
			return false; // too far and not enemy, don't bother head or side checks
		*/
		if (Other.CollisionHeight > 0 && FastTrace(Other.Location + vect(0,0,0.8) * Other.CollisionHeight, Location))
			return true;
	}
	// only check sides if width of other is significant compared to distance
	if (Other.CollisionRadius / dist < 0.01)
		return false;

	GetAxes(rotator(Other.Location - Location), X, Y, Z); // we need Y to calculate cylinder side location (yes, I'm lazy)

	return (FastTrace(Other.Location + Y * Other.CollisionRadius, Location)
		|| FastTrace(Other.Location - Y * Other.CollisionRadius, Location));
}


simulated function DrawWeaponBar(Canvas C)
{
    local int i;
    //local float IconOffset;
	local float HudScaleOffset, HudMinScale;
	local HudCDeathMatch H;
	
	H = HudCDeathMatch(C.Viewport.Actor.MyHud);
	
	HudMinScale=0.5;

    for (i = 0; i < ProjectileTypes.Length; i++)
    {
		// Keep weaponbar organized when scaled
		HudScaleOffset = 1 - (H.HudScale - HudMinScale) / HudMinScale;
    	ProjectileTypes[i].BarBorder.PosX =  default.ProjectileTypes[i].BarBorder.PosX + (ProjectileTypes[i].BarBorderScaledPosition - default.ProjectileTypes[i].BarBorder.PosX) * HudScaleOffset;
		ProjectileTypes[i].BarBorder.OffsetY = 0;
		ProjectileTypes[i].BarWeaponIcon.PosX = ProjectileTypes[i].BarBorder.PosX;

		//IconOffset = (default.ProjectileTypes[i].BarBorder.TextureCoords.X2 - default.ProjectileTypes[i].BarBorder.TextureCoords.X1) * 0.5;
	    //ProjectileTypes[i].BarWeaponIcon.OffsetX = IconOffset;
		ProjectileTypes[i].BarWeaponIcon.OffsetY = default.ProjectileTypes[i].BarWeaponIcon.OffsetY;
		ProjectileTypes[i].BarWeaponSlot.OffsetY = default.ProjectileTypes[i].BarWeaponSlot.OffsetY;
		
        ProjectileTypes[i].BarBorder.Tints[0] = H.HudColorRed;
        ProjectileTypes[i].BarBorder.Tints[1] = H.HudColorBlue;
		ProjectileTypes[i].BarWeaponIcon.Tints[H.TeamIndex] = H.HudColorNormal;

		if (i == CurrentProjectileType)
		{
			// Change color to highlight and possibly changeTexture or animate it
			ProjectileTypes[i].BarBorder.Tints[H.TeamIndex] = H.HudColorHighLight;
			ProjectileTypes[i].BarBorder.OffsetY = -10;
			ProjectileTypes[i].BarWeaponIcon.OffsetY -= 15;
			ProjectileTypes[i].BarWeaponSlot.OffsetY -= 20;
		}
		
		ProjectileTypes[i].BarWeaponSlot.Value = i + ONSVehicle(Owner).WeaponPawns.Length + 2;

		H.DrawSpriteWidget(C, ProjectileTypes[i].BarBorder);
		H.DrawNumericWidget(C, ProjectileTypes[i].BarWeaponSlot, H.DigitsBig);
		H.DrawSpriteWidget(C, ProjectileTypes[i].BarWeaponIcon);
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     FireOffsets(0)=(Y=41.000000,Z=19.000000)
     FireOffsets(1)=(Y=-65.000000,Z=19.000000)
     FireOffsets(2)=(Y=65.000000)
     FireOffsets(3)=(Y=-41.000000)
     FireOffsets(4)=(Y=41.000000,Z=-19.000000)
     FireOffsets(5)=(Y=-65.000000,Z=-19.000000)
     FireOffsets(6)=(Y=65.000000,Z=19.000000)
     FireOffsets(7)=(Y=-41.000000,Z=19.000000)
     FireOffsets(8)=(Y=41.000000)
     FireOffsets(9)=(Y=-65.000000)
     FireOffsets(10)=(Y=65.000000,Z=-19.000000)
     FireOffsets(11)=(Y=-41.000000,Z=-19.000000)
     ProjectileTypes(0)=(ProjectileClass=Class'PersesOmni.PersesOmniMercuryMissile',FireSound=Sound'PersesOmni.MercIgnite',FireInterval=0.400000,BarWeaponIcon=(WidgetTexture=Texture'PersesOmni_Tex.HUD.PersesHud',RenderStyle=STY_Alpha,TextureCoords=(X1=123,Y1=1,X2=249,Y2=28),TextureScale=0.350000,DrawPivot=DP_LowerMiddle,PosX=0.400000,PosY=1.000000,OffsetY=-15,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)),BarBorderScaledPosition=0.480000,BarBorder=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=39,X2=94,Y2=93),TextureScale=0.530000,DrawPivot=DP_LowerMiddle,PosX=0.400000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200)),BarWeaponSlot=(RenderStyle=STY_Alpha,TextureScale=0.265000,DrawPivot=DP_LowerMiddle,PosX=0.400000,PosY=1.000000,OffsetX=-65,OffsetY=-60,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)))
     ProjectileTypes(1)=(ProjectileClass=Class'PersesOmni.PersesOmniHomingMissile',FireSound=Sound'PersesOmni.HomingMissileFire',FireInterval=0.700000,BarWeaponIcon=(WidgetTexture=Texture'PersesOmni_Tex.HUD.PersesHud',RenderStyle=STY_Alpha,TextureCoords=(X1=11,Y1=29,X2=110,Y2=63),TextureScale=0.350000,DrawPivot=DP_LowerMiddle,PosX=0.480000,PosY=1.000000,OffsetY=-10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)),BarBorderScaledPosition=0.520000,BarBorder=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=39,X2=94,Y2=93),TextureScale=0.530000,DrawPivot=DP_LowerMiddle,PosX=0.480000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200)),BarWeaponSlot=(RenderStyle=STY_Alpha,TextureScale=0.265000,DrawPivot=DP_LowerMiddle,PosX=0.480000,PosY=1.000000,OffsetX=-65,OffsetY=-60,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)))
     ProjectileTypes(2)=(ProjectileClass=Class'PersesOmni.PersesOmniFragMissile',FireSound=Sound'PersesOmni.FragMissileFire',FireInterval=0.500000,BarWeaponIcon=(WidgetTexture=Texture'PersesOmni_Tex.HUD.PersesHud',RenderStyle=STY_Alpha,TextureCoords=(X1=9,X2=110,Y2=29),TextureScale=0.350000,DrawPivot=DP_LowerMiddle,PosX=0.560000,PosY=1.000000,OffsetY=-13,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)),BarBorderScaledPosition=0.560000,BarBorder=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=39,X2=94,Y2=93),TextureScale=0.530000,DrawPivot=DP_LowerMiddle,PosX=0.560000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200)),BarWeaponSlot=(RenderStyle=STY_Alpha,TextureScale=0.265000,DrawPivot=DP_LowerMiddle,PosX=0.560000,PosY=1.000000,OffsetX=-65,OffsetY=-60,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)))
     ProjectileTypes(3)=(ProjectileClass=Class'PersesOmni.PersesOmniNapalmRocket',FireSound=Sound'PersesOmni.NapalmRocketFire',FireInterval=0.600000,BarWeaponIcon=(WidgetTexture=Texture'PersesOmni_Tex.HUD.PersesHud',RenderStyle=STY_Alpha,TextureCoords=(X1=123,Y1=28,X2=249,Y2=64),TextureScale=0.350000,DrawPivot=DP_LowerMiddle,PosX=0.640000,PosY=1.000000,OffsetY=-10,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)),BarBorderScaledPosition=0.600000,BarBorder=(WidgetTexture=Texture'HUDContent.Generic.HUD',RenderStyle=STY_Alpha,TextureCoords=(Y1=39,X2=94,Y2=93),TextureScale=0.530000,DrawPivot=DP_LowerMiddle,PosX=0.640000,PosY=1.000000,ScaleMode=SM_Right,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=200),Tints[1]=(B=255,G=255,R=255,A=200)),BarWeaponSlot=(RenderStyle=STY_Alpha,TextureScale=0.265000,DrawPivot=DP_LowerMiddle,PosX=0.640000,PosY=1.000000,OffsetX=-65,OffsetY=-60,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255)))
     YawBone="RocketPivot"
     PitchBone="RocketPacks"
     PitchUpLimit=16300
     WeaponFireAttachmentBone="RocketPackFirePoint"
     DualFireOffset=45.000000
     Spread=0.001000
     FireInterval=0.400000
     FireSoundClass=Sound'PersesOmni.MercIgnite'
     FireForce="RocketLauncherFire"
     ProjectileClass=Class'PersesOmni.PersesOmniMercuryMissile'
     AIInfo(0)=(bTrySplash=True,bLeadTarget=True,WarnTargetPct=0.500000)
     Mesh=SkeletalMesh'ONSFullAnimations.MASrocketPack'
     DrawScale=0.800000
     CollisionRadius=60.000000
     bNetNotify=True
}
