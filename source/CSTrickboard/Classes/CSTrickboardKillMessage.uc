class CSTrickboardKillMessage extends LocalMessage;

var Sound AwardSound;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return "OWNAGE";
}

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
    local float Atten;	
    Atten = 2.0 * FClamp(0.1 + float(P.AnnouncerVolume)*0.225,0.2,1.0);

	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
    P.ClientPlaySound(Default.AwardSound, true, Atten, SLOT_Talk);
}

defaultproperties
{
    AwardSound=Sound'AnnouncerMale2K4.Generic.Ownage'
    bIsUnique=True
    bFadeMessage=True
    DrawColor=(B=0,G=0)
    StackMode=SM_Down
    PosY=0.242000
    FontSize=1
}