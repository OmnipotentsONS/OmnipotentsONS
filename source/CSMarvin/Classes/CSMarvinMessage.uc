class CSMarvinMessage extends LocalMessage;

#exec AUDIO IMPORT File="Sounds\Welcome.wav"
#exec AUDIO IMPORT File="Sounds\AccessDenied.wav"

var string WelcomeMasterString;
var string WelcomeBackMasterString;
var string NotMyMasterString;
var localized string MarvinMessages[2];

var sound WelcomeSound;
var sound WelcomeBackSound;
var sound AccessDeniedSound;

var sound MessageSounds[2];

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    local float Atten;

	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
    Atten = 2.0 * FClamp(0.1 + float(P.AnnouncerVolume)*0.225,0.2,1.0);
    P.ClientPlaySound(Default.MessageSounds[Min(Switch,2)], true, Atten, SLOT_Talk);
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    return Default.MarvinMessages[Min(Switch,1)];
}

defaultproperties
{
    MarvinMessages(0)="Welcome Pilot"
    MarvinMessages(1)="Access Denied. You are not my Pilot"
    MessageSounds(0)=Sound'CSMarvin.Welcome'
    MessageSounds(1)=Sound'CSMarvin.AccessDenied'

    bIsUnique=True
    bFadeMessage=True
    DrawColor=(B=0,G=0)
    StackMode=SM_Down
    PosY=0.242000
    FontSize=1
}