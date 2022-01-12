class MutUseEjectorSeat extends Mutator;
function bool ReplaceWith(actor Other, string aClassName)
{
	local Actor A;
	local class<Actor> aClass;

	if ( aClassName == "" )
		return true;

	aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	if ( aClass != None )
		A = Spawn(aClass,Other.Owner,Other.tag,Other.Location, Other.Rotation);
	if ( Other.IsA('Pickup') )
	{
		if ( Pickup(Other).MyMarker != None )
		{
			Pickup(Other).MyMarker.markedItem = Pickup(A);
			if ( Pickup(A) != None )
			{
				Pickup(A).MyMarker = Pickup(Other).MyMarker;
				A.SetLocation(A.Location
					+ (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
			}
			Pickup(Other).MyMarker = None;
		}
        //wtf did they do this?
		//else if ( A.IsA('Pickup') )
			//Pickup(A).Respawntime = 0.0;
	}
	if ( A != None )
	{
		A.event = Other.event;
		A.tag = Other.tag;
		return true;
	}
	return false;
}
function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
	bSuperRelevant = 0;
	if ( ONSMineLayerPickup(Other) != None && CSEjectorSeatPickUp(Other) == None )
    {
		ReplaceWith( Other, "CSEjectorSeat.CSEjectorSeatPickup");
        Other.Destroy();
    }

	return true;
}

defaultproperties
{
    bAddToServerPackages=True
    IconMaterialName="MutatorArt.nosym"
    GroupName=""
    FriendlyName="Ejector seat"
    Description="Replace spider mine pickup with ejector seat."
}