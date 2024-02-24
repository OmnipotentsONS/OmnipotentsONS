//-----------------------------------------------------------
//Replaces the Raptor with the Fireblade
//-----------------------------------------------------------
class FireBladeOmniMut extends Mutator;

// #exec obj load file=..\system\FireBladeOmni.u

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{


	if ( ONSVehicleFactory(Other) != None )
	{
		if ( ONSVehicleFactory(Other).VehicleClass == class'Onslaught.ONSAttackcraft' )   // ONSAttackcraft
		{

		    // Spawn(class'FireBladeOmniFactory',,, (Other.Location+vect(400,400,300)));
			// return true;
			ONSVehicleFactory(Other).VehicleClass = class'FireBladeOmni.FireBladeOmni';  //NodeRunner.ONSNodeRunner
		}
		else
			return true;
	}
	else
		return true;
}

defaultproperties
{
     FriendlyName="FireBlade Omni Spawns Instead of Raptor"
     Description="Replaces the Raptor with the FireBladeOmni "
}
