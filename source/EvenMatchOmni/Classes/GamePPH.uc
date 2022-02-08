//class GamePPH extends Object;
class GamePPH extends Actor;

var float RedPPH;
var float BluePPH;

replication
{
    unreliable if(bNetDirty)
        RedPPH, BluePPH;
}

defaultproperties
{
    RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
    NetUpdateFrequency=1
    bNetNotify=True
}