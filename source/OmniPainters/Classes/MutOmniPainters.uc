class MutOmniPainters extends Mutator;
// this replaces stanard ONSPainter, or XWeapons.Painter with OmniIonPainter
// also replaces Strike Painter (nuke) with StrikePainterOmni

var() config bool bDebug;
var bool bInitialized;

function Initialize()
{

    bInitialized = true;
	  Log("Mutator "@ FriendlyName@" Initialized",'OmniPainters');
}

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	local int i;
	local WeaponLocker L;

  if ( !bInitialized )  Initialize();
	bSuperRelevant = 0;
	
  if ( xWeaponBase(Other) != None )
  {
		if ( xWeaponBase(Other).WeaponType.name == 'StrikePainter'  )
			xWeaponBase(Other).WeaponType = class'OmniPainters.StrikePainterOmni';
		if	( xWeaponBase(Other).WeaponType == class'OnslaughtFull.ONSPainter' ||  xWeaponBase(Other).WeaponType == class'XWeapons.Painter')
			xWeaponBase(Other).WeaponType = class'OmniPainters.IonPainterOmni';
	}
	else if ( ONSPainterPickup(Other) != None )
		ReplaceWith( Other, "OmniPainters.IonPainterOmniPickup");
	else if ( WeaponLocker(Other) != None ) //Who the hell puts the Target Painter in a weapon locker?
	{
		L = WeaponLocker(Other);
		for (i = 0; i < L.Weapons.Length; i++) {
			if (L.Weapons[i].WeaponClass == class'ONSPainter' || L.Weapons[i].WeaponClass == class'Painter')
				L.Weapons[i].WeaponClass = class'IonPainterOmni';
			if (L.Weapons[i].WeaponClass.Name == 'StrikePainter' )
				L.Weapons[i].WeaponClass = class'StrikePainterOmni';	
		}		
		return true;
	}
	else
		return true;
		
	
	return true;
}

defaultproperties
{
     FriendlyName="Omni Painters 1.03"
     Description="Replaces the Short Range Ion Painter, Nuke Strike Painters with Omni longer range versions"
     bAddToServerPackages=True
     bDebug=False
}
