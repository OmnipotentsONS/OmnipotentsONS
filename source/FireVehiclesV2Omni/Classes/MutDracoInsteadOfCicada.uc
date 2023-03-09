/**
WVDraco.MutDracoInsteadOfCicada

Creation date: 2013-11-14 08:45
Last change: $Id$
Copyright (c) 2013, Wormbo
*/

class MutDracoInsteadOfCicada extends Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None && SVehicleFactory(Other).VehicleClass == class'ONSDualAttackCraft')
		SVehicleFactory(Other).VehicleClass = class'Draco';
	
	return true;
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="Draco instead of Cicada"
     Description="Replaces the Cicada with the Draco."
}
