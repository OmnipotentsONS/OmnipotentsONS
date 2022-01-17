class MutOmnitaur extends Mutator;

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	if ( ONSVehicleFactory(Other) != None )
	{
		if ( ONSVehicleFactory(Other).VehicleClass == class'Onslaught.ONSHoverTank' )
		{
			ONSVehicleFactory(Other).VehicleClass = class'omnitaur.omnitaur';
		}
		else
			return true;
	}
	else
		return true;
}

defaultproperties
{
     FriendlyName="Min)o(taur"
     Description="Replace the Goliath Tank with the Min)o(taur, the more powerful )O(mnipotents variant of this supertank."
}
