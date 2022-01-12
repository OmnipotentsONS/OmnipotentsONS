
class CSEjectorSeatPickup extends UTWeaponPickup;
//class CSEjectorSeatPickup extends TournamentPickUp;

#exec obj load file=StaticMeshes\CSEjectorSeat_SM.usx package=CSEjectorSeat
#exec obj load file=Textures\CSEjectorSeat_Tex.utx package=CSEjectorSeat
#EXEC AUDIO IMPORT FILE="Sounds\dangerzone.wav"

simulated function PostBeginPlay()
{
    SetRotation(rot(16384,0,0));
    super.PostBeginPlay();
}

function AnnouncePickup( Pawn Receiver )
{
	Receiver.HandlePickup(self);
	PlaySound( PickupSound,SLOT_Interact,512);
}

defaultproperties
{
    bWeaponStay=false
    InventoryType=class'CSEjectorSeat.CSChuteInv'

    PickupMessage="You got the ejector seat"
    //PickupSound=Sound'PickupSounds.ShockRiflePickup'
    PickupSound=sound'CSEjectorSeat.dangerzone'

    PickupForce="ShockRiflePickup"  // jdf

	MaxDesireability=+0.63

    Skins(0)=Texture'CSEjectorSeat.chute_up'
    Skins(1)=Texture'CSEjectorSeat.chute_down'
    StaticMesh=StaticMesh'CSEjectorSeat.AP_FX_ST.chutemesh'

    DrawType=DT_StaticMesh
    DrawScale=0.55
    //Standup=(Y=0.25,Z=0.0)
    RespawnTime=30.0
}
