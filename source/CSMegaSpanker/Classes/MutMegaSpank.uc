class MutMegaSpank extends Mutator;


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (SVehicleFactory(Other) != None 
        &&  SVehicleFactory(Other).VehicleClass == class'ONSMobileAssaultStation')
     {
		SVehicleFactory(Other).VehicleClass = class'CSMegaSpanker';
     }
	
	return true;
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="Mega Spanker"
     Description="Replaces the Leviathan with the Mega Spanker"
}
