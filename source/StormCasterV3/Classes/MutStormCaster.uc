/******************************************************************************
MutStormCaster

Creation date: 2013-09-09 18:10
Last change: $Id$
Copyright © 2013, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class MutStormCaster extends Mutator;


//=============================================================================
// Configuration
//=============================================================================

var config bool bReplaceTargetPainter;
var config bool bReplaceRedeemer;
var config bool bReplaceAllSuperWeapons;


//=============================================================================
// Localization
//=============================================================================

var localized string lblReplaceTargetPainter;
var localized string lblReplaceRedeemer;
var localized string lblReplaceAllSuperWeapons;

var localized string descReplaceTargetPainter;
var localized string descReplaceRedeemer;
var localized string descReplaceAllSuperWeapons;


//=============================================================================
// Variables
//=============================================================================

var bool bHasIonPainter, bHasTargetPainter, bHasOpenSky;


/**
Starts the timer and counts the player starts.
*/
event PostBeginPlay()
{
	local NavigationPoint NP;
	local vector HN, HL;
	local float Height;
	local int NumNavigationPoints, NumHighPoints;
	local xWeaponBase WB;

	for (NP = Level.NavigationPointList; NP != None; NP = NP.NextNavigationPoint)
	{
		++NumNavigationPoints;

		if ( Trace(HL, HN, NP.Location + vect(0,0,20000), NP.Location, False) != None )
		{
			Height += VSize(NP.Location - HL);
			if ( VSize(NP.Location - HL) > 5000 )
				++NumHighPoints;
		}
		else
		{
			Height += 20000;
			++NumHighPoints;
		}
	}

	if ( NumHighPoints > 5 )
		bHasOpenSky = True;

	foreach AllActors(class'xWeaponBase', WB)
	{
		if ( WB.WeaponType == class'Painter' )
			bHasIonPainter = True;
		else if ( string(WB.WeaponType) ~= "OnslaughtFull.ONSPainter" )
			bHasTargetPainter = True;
	}
}


/**
Replace the ion painter in UnrealPawn.CreateInventory()
*/
function string GetInventoryClassOverride(string InventoryClassName)
{
	local class<Weapon> WeaponClass;

	InventoryClassName = Super.GetInventoryClassOverride(InventoryClassName);
	if ( !(InventoryClassName ~= string(class'StormCaster')) )
	{
		if ( InventoryClassName ~= string(class'Painter') )
			InventoryClassName = string(class'StormCaster');
		else if ( bReplaceAllSuperWeapons && bHasOpenSky )
		{
			if ( InventoryClassName ~= "OnslaughtFull.ONSPainter" || InventoryClassName ~= "xWeapons.Redeemer" )
				InventoryClassName = string(class'StormCaster');
			else
			{
				WeaponClass = class<Weapon>(DynamicLoadObject(InventoryClassName, class'Class'));
				if ( WeaponClass != None && WeaponClass.default.InventoryGroup == 0 )
					InventoryClassName = string(class'StormCaster');
			}
		}
	}
	return InventoryClassName;
}


/**
Replace the ion painter.
*/
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local int i;

	if ( xWeaponBase(Other) != None )
	{
		if ( xWeaponBase(Other).WeaponType == class'Painter' )
			xWeaponBase(Other).WeaponType = class'StormCaster';
		else if ( !bHasIonPainter && bReplaceTargetPainter && string(xWeaponBase(Other).WeaponType) ~= "OnslaughtFull.ONSPainter" )
			xWeaponBase(Other).WeaponType = class'StormCaster';
		else if ( !bHasIonPainter && !bHasTargetPainter && bHasOpenSky && bReplaceRedeemer && xWeaponBase(Other).WeaponType == class'Redeemer' )
			xWeaponBase(Other).WeaponType = class'StormCaster';
		else if ( bReplaceAllSuperWeapons && bHasOpenSky && xWeaponBase(Other).WeaponType != None && xWeaponBase(Other).WeaponType.default.InventoryGroup == 0 )
			xWeaponBase(Other).WeaponType = class'StormCaster';
	}

	if ( PainterPickup(Other) != None && !Other.IsA('ONSPainterPickup') )
	{
		//log("Modifying"@Other, Class.Name);
		PainterPickup(Other).InventoryType = class'StormCaster';
	}

	// unlikely, but who knows...
	if ( WeaponLocker(Other) != None )
	{
		for (i = 0; i < WeaponLocker(Other).Weapons.Length; i++)
		{
			if ( WeaponLocker(Other).Weapons[i].WeaponClass == class'Painter' )
			{
				//log("Modifying"@Other@i, Class.Name);
				WeaponLocker(Other).Weapons[i].WeaponClass = class'StormCaster';
			}
		}
	}

	return Super.CheckReplacement(Other, bSuperRelevant);
}


/**
Add the configuration options to the PlayInfo.
*/
static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.FriendlyName, "bReplaceTargetPainter",   default.lblReplaceTargetPainter,   0, 1, "Check");
	PlayInfo.AddSetting(default.FriendlyName, "bReplaceRedeemer",        default.lblReplaceRedeemer,        0, 2, "Check");
	PlayInfo.AddSetting(default.FriendlyName, "bReplaceAllSuperWeapons", default.lblReplaceAllSuperWeapons, 0, 3, "Check");
}


/**
Returns a description for the specified configuration option.
*/
static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bReplaceTargetPainter":   return default.descReplaceTargetPainter;
		case "bReplaceRedeemer":        return default.descReplaceRedeemer;
		case "bReplaceAllSuperWeapons": return default.descReplaceAllSuperWeapons;
	}

	return Super.GetDescriptionText(PropName);
}


//=============================================================================
// Default properties
//=============================================================================

defaultproperties
{
     bReplaceTargetPainter=True
     bReplaceRedeemer=True
     lblReplaceTargetPainter="Replace Target Painter"
     lblReplaceRedeemer="Replace Redeemer"
     lblReplaceAllSuperWeapons="Replace all super weapons"
     descReplaceTargetPainter="Replace the Target Painter if there's no Ion Painter on the map."
     descReplaceRedeemer="Replace the Redeemer if there's no Ion Painter or (if selected) Target Painter on the map and there's actually a chance to use the painter."
     descReplaceAllSuperWeapons="Replace all super weapons (i.e. weapons in slot 0) with the Ion Painter if it can actually be used on the map."
     bAddToServerPackages=True
     GroupName="IonCannon"
     FriendlyName="Storm Caster V2"
     Description="Replaces the Ion Painter with the Storm Caster."
}
