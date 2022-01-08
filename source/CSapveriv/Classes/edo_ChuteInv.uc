//=============================================================================
// edo_ChuteInv items - activatable inventory.
//=============================================================================
class edo_ChuteInv extends Powerups;

//TODO:
//1 ons_special raptor only mutator
//2 manual activation of the chute
//3 space discards it
//4 destroyable cute
//Bugs?

//import sound
//#EXEC AUDIO IMPORT FILE="Sounds\chuteopen2.wav" NAME="chuteopen"

var float LastFallTime;
var float DelayOpenTime;
var bool bChuteOpen;

//=============================================================================
// Active state: this inventory item is armed and ready to rock!

state Activated
{
	function BeginState()
	{
		bActive = true;
		Instigator.ClientMessage("Chute on stand by.");
		enable('tick');
	}

	function EndState()
	{
		bActive = false;
		disable('tick');
	}

	function Tick(float DeltaTime)
	{

		//DelayOpenTime - not implemented yet
		LastFallTime += DeltaTime;

        if (bChuteOpen)
		{
			if (Instigator.Physics == PHYS_Falling)
			{
				//keep chuteing
				Instigator.Velocity.Z=-400;
			}
			else
			{
				DiscardChute();
			}
		}
		else
		{
			//If player is travelling down fast and long enough then open
			if(Instigator.Physics == PHYS_Falling
				&& Instigator.Velocity.Z < (-1)*Instigator.MaxFallSpeed) //-1000)
			{
				OpenChute();
			}
		}

	}

	function OpenChute()
	{
		bChuteOpen=true;

		//Instigator.Acceleration = vect(0,0,0);
		//Instigator.AccelRate = 0;
		Instigator.AirControl=3.5;

		Instigator.Velocity.Z=-400;
		Instigator.Velocity.X=Instigator.Velocity.X/2;
		Instigator.Velocity.Y=Instigator.Velocity.Y/2;

		Instigator.PlaySound(sound'chuteopen', SLOT_Misc
			,512,true,128);


		//set decoration attachment
		AttachToPawn(Instigator);

		Instigator.ClientMessage("Chute Open");

	}


	function DiscardChute()
	{

		bChuteOpen=false;

		Instigator.AccelRate = Instigator.default.AccelRate;
		Instigator.AirControl=Instigator.default.AirControl;

		//destroy decoration attachment
		DetachFromPawn(Instigator);
		Destroy();
		Instigator.ClientMessage("Chute Closed!");

    }
}

function AttachToPawn(Pawn P)
{
	Instigator = P;
	if ( ThirdPersonActor == None )
	{
		ThirdPersonActor = Spawn(AttachmentClass,Owner);
		InventoryAttachment(ThirdPersonActor).InitFor(self);

    }
	else
		ThirdPersonActor.NetUpdateTime = Level.TimeSeconds - 1;


	P.AttachToBone(ThirdPersonActor,'spine');
}

defaultproperties
{
     bAutoActivate=True
     bActivatable=True
     AttachmentClass=Class'CSAPVerIV.edo_ChuteInvAtt'
}
