class MSG_PredatorMessages extends LocalMessage;

var localized string Message[8];

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return Default.Message[Min(Switch,7)];
}

static simulated function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

}

defaultproperties
{
     Message(0)="You Have the Phoenix!!!"
     Message(1)="Weapon Plasma Cannons"
     Message(2)="Press Fire for Stealth Mode"
     Message(3)="Weapon Missiles"
     Message(4)="Weapon HellFire Rockets!"
     Message(5)="Player on Rope Dropped"
     Message(6)="Player on Rope"
     Message(7)="Rope Deployed"
     bIsUnique=True
     bFadeMessage=True
     DrawColor=(B=0,G=0)
     StackMode=SM_Down
     PosY=0.242000
     FontSize=1
}
