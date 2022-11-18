/******************************************************************************
HoverTankFactory

Creation date: 2011-08-15 20:19
Last change: $Id$
Copyright © 2011, Wormbo
Website: http://www.koehler-homepage.de/Wormbo/
Feel free to reuse this code. Send me a note if you found it helpful or want
to report bugs/provide improvements.
Please ask for permission first, if you intend to make money off reused code.
******************************************************************************/

class OVHoverTankFactory extends ONSVehicleFactory abstract;


var() float AirControlOverride;


function SpawnVehicle()
{
	local OVHoverTank HT;

	Super.SpawnVehicle();

	HT = OVHoverTank(LastSpawned);
	if (HT != None && AirControlOverride >= 0.0)
	{
		HT.AirControl = AirControlOverride;
	}
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
     AirControlOverride=-1.000000
     RespawnTime=30.000000
     RedBuildEffectClass=Class'Onslaught.ONSTankBuildEffectRed'
     BlueBuildEffectClass=Class'Onslaught.ONSTankBuildEffectBlue'
     VehicleClass=Class'WVHoverTankV2.HoverTank'
     Mesh=SkeletalMesh'ONSNewTank-A.HoverTank'
     CollisionRadius=250.000000
     CollisionHeight=60.000000
}
