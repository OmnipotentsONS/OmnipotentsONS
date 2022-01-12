class CSChuteInv extends Powerups;

//import sound
//#EXEC AUDIO IMPORT FILE="Sounds\chuteopen2.wav" NAME="chuteopen"
#EXEC AUDIO IMPORT FILE="Sounds\chuteopen.wav"
#EXEC AUDIO IMPORT FILE="Sounds\dangerzone.wav"

var float DelayOpenTime;
var bool bChuteOpen;
var Vehicle enteredVehicle;

replication
{
    reliable if(Role == ROLE_Authority)
        enteredVehicle;
}

state Activated
{
	function BeginState()
	{
		bActive = true;
		//Instigator.ClientMessage("Chute on stand by.");
		enable('tick');
	}

	function EndState()
	{
		bActive = false;
		disable('tick');
	}

	function Tick(float DeltaTime)
	{
        local xPawn player;
        player = XPawn(Instigator);
        if(player != None && Role == ROLE_Authority)
        {
            //TODO do we need to check if driver.pawn == instigator? (in case passenger/driver switch)
            if(player.DrivenVehicle != None)
            {
                enteredVehicle = player.DrivenVehicle;
                enteredVehicle.bEjectDriver = true;
                enteredVehicle.EjectMomentum = 1600;
                if(ONSVehicle(enteredVehicle) != None)
                {
                    ONSVehicle(enteredVehicle).ExplosionDamage = 0;
                }
            }
            else
            {
                if(enteredVehicle != None)
                {
                    if(enteredVehicle.Health <= 0)
                    {
                        if(PlayerController(player.Controller) != None)
                            PlayerController(player.Controller).ClientPlaySound(sound'CSEjectorSeat.dangerzone',,512);

                        SetTimer(10.0, false);
                    }

                    enteredVehicle.bEjectDriver = false;
                    enteredVehicle.EjectMomentum = 1000;
                    if(ONSVehicle(enteredVehicle) != None)
                    {
                        ONSVehicle(enteredVehicle).ExplosionDamage = ONSVehicle(enteredVehicle).default.ExplosionDamage;
                    }
                }

                enteredVehicle = None;
            }
        }

        if (bChuteOpen)
		{
            if(player.Controller != None && player.Controller.bDuck > 0)
            {
                DiscardChute();
            }
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

		Instigator.AirControl=3.5;

		Instigator.Velocity.Z=-400;
		Instigator.Velocity.X=Instigator.Velocity.X/2;
		Instigator.Velocity.Y=Instigator.Velocity.Y/2;

		Instigator.PlaySound(sound'chuteopen', SLOT_Misc ,512,true,128);

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

    function Timer()
    {
		bChuteOpen=false;

        if(Instigator != None)
        {
            Instigator.AccelRate = Instigator.default.AccelRate;
            Instigator.AirControl=Instigator.default.AirControl;

            //destroy decoration attachment
            DetachFromPawn(Instigator);
        }

		Destroy();
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
     AttachmentClass=Class'CSEjectorSeat.CSChuteInvAtt'
}
