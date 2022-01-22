//=============================================================================
// MegabadgerUseTrigger.
//=============================================================================
class MegabadgerUseTrigger extends UseTrigger;

// A trigger that follows the megabadger around, to assist players in getting in
// because the damn engine apparently ignores UseRadius

function UsedBy( Pawn user )
{
	if (Owner != None)
		Owner.UsedBy(user);
	else
		Destroy();
}

event Tick(float DT)
{
	Super.Tick(DT);

	if (Owner == None)
		Destroy();
	else
		SetLocation(Owner.Location);
}

defaultproperties
{
     CollisionRadius=200.000000
     CollisionHeight=320.000000
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     bSelected=True
}
