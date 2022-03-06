//class GamePPH extends Object;
class GamePPH extends Actor;

var float RedPPH;
var float BluePPH;

replication
{
    reliable if(bNetDirty && Role == ROLE_Authority)
        RedPPH, BluePPH;
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
    NetUpdateFrequency=1
    bNetNotify=True
    bHidden=True
}