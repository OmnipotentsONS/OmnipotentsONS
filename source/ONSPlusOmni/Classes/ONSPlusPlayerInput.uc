// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusPlayerInput extends PlayerInput;

event PlayerInput(float DeltaTime)
{
	// Ignore input if we're playing back a client-side demo.
	if( Outer.bDemoOwner && !Outer.default.bDemoOwner )
		return;

	// Check for Double click move
	// flag transitions
	bEdgeForward = (bWasForward ^^ (aBaseY > 0));
	bEdgeBack = (bWasBack ^^ (aBaseY < 0));
	bEdgeLeft = (bWasLeft ^^ (aStrafe < 0));
	bEdgeRight = (bWasRight ^^ (aStrafe > 0));
	bWasForward = (aBaseY > 0);
	bWasBack = (aBaseY < 0);
	bWasLeft = (aStrafe < 0);
	bWasRight = (aStrafe > 0);
}

function Actor.eDoubleClickDir CheckForDoubleClickMove(float DeltaTime)
{
	local Actor.eDoubleClickDir DoubleClickMove, OldDoubleClick;

	if (!bEnableDodging)
	{
		DoubleClickMove = DCLICK_None;
		return DoubleClickMove;
	}

	if (DoubleClickDir == DCLICK_Active)
		DoubleClickMove = DCLICK_Active;
	else
		DoubleClickMove = DCLICK_None;

	if (DoubleClickTime > 0.0)
	{
		if (DoubleClickDir == DCLICK_Active)
		{
			if (Pawn != None && (Pawn.Physics == PHYS_Walking || (Vehicle(Pawn) != none && DoubleClickDir == DCLICK_Active)))
			{
				DoubleClickTimer = 0;
				DoubleClickDir = DCLICK_Done;
			}
		}
		else if (DoubleClickDir != DCLICK_Done)
		{
			OldDoubleClick = DoubleClickDir;
			DoubleClickDir = DCLICK_None;

			if (bEdgeForward && bWasForward)
				DoubleClickDir = DCLICK_Forward;
			else if (bEdgeBack && bWasBack)
				DoubleClickDir = DCLICK_Back;
			else if (bEdgeLeft && bWasLeft)
				DoubleClickDir = DCLICK_Left;
			else if (bEdgeRight && bWasRight)
				DoubleClickDir = DCLICK_Right;

			if (DoubleClickDir == DCLICK_None)
				DoubleClickDir = OldDoubleClick;
			else if (DoubleClickDir != OldDoubleClick)
				DoubleClickTimer = DoubleClickTime + 0.5 * DeltaTime;
			else
				DoubleClickMove = DoubleClickDir;
		}

		if (DoubleClickDir == DCLICK_Done)
		{
			DoubleClickTimer = FMin(DoubleClickTimer-DeltaTime, 0);

			if (DoubleClickTimer < -0.35)
			{
				DoubleClickDir = DCLICK_None;
				DoubleClickTimer = DoubleClickTime;
			}
		}
		else if (DoubleClickDir != DCLICK_None && DoubleClickDir != DCLICK_Active)
		{
			DoubleClickTimer -= DeltaTime;

			if (DoubleClickTimer < 0)
			{
				DoubleClickDir = DCLICK_None;
				DoubleClickTimer = DoubleClickTime;
			}
		}
	}

	return DoubleClickMove;
}