class CSMarvinPoisonMessage extends LocalMessage;

#exec AUDIO IMPORT File="Sounds\PortalPoisoned.wav" Name="PortalPoisoned"
#exec AUDIO IMPORT File="Sounds\PoisonRemoved.wav" Name="PoisonRemoved"

var localized string PoisonMessages[2];
var Sound PoisonSounds[2];

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
    P.ClientPlaySound(Default.PoisonSounds[Switch],,, SLOT_Interact);
}

static function string GetString(
	optional int MessageNum,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    return Default.PoisonMessages[MessageNum];
}

defaultproperties
{
    PoisonMessages(0)="Portal Poisoned"
    PoisonMessages(1)="Poison Removed"
    PoisonSounds(0)=Sound'PortalPoisoned'
    PoisonSounds(1)=Sound'PoisonRemoved'
    bIsUnique=True
    bFadeMessage=True
    DrawColor=(R=0,G=0)
    StackMode=SM_Down
    PosY=0.242000
    FontSize=1
}