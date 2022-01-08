class DropShipMessages extends LocalMessage;

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
     Message(1)="Press Fire to Eject Passengers and Vehicles"
     Message(2)="Alt Fire Switches Fire Type"
     Message(3)="Back of DropShip can pick up Vehicles"
     Message(4)="Press Fire To Launch Rockets!"
     Message(5)="Eagle Eye!"
     Message(6)="Top Gun!"
     Message(7)="Fender Bender!"
     bIsUnique=True
     bFadeMessage=True
     DrawColor=(B=0,G=0)
     StackMode=SM_Down
     PosY=0.242000
     FontSize=1
}
