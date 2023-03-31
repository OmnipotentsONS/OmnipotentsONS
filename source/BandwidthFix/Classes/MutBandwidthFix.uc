// work around 10000 netspeed cap when MaxPlayers > 16
// usage - set MaxPlayers = 16 in game settings, then set real max players using this mutator

class MutBandwidthFix extends Mutator;

var() config int MaxPlayers;
var() config int ClientNetSpeed;
var() config bool bSetClientNetSpeed;
var() config bool bPersistClientNetSpeed;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientNetSpeed, bSetClientNetSpeed, bPersistClientNetSpeed;
}

function PreBeginPlay()
{
    super.PreBeginPlay();
    if(Level != None && Level.Game != None)
        Level.Game.MaxPlayers = Clamp(MaxPlayers,0,32);

}

function bool MutatorIsAllowed()
{
	return true;
}

simulated function BeginPlay()
{
    local PlayerController PC;
    super.BeginPlay();
    if(Level.NetMode == NM_Client)
    {
        PC = Level.GetLocalPlayerController();
        if(bSetClientNetSpeed && PC != None && PC.Player.CurrentNetSpeed < ClientNetSpeed)
        {
            PC.SetNetSpeed(ClientNetSpeed);
        }

        if(bPersistClientNetSpeed && class'Engine.Player'.default.ConfiguredInternetSpeed < ClientNetSpeed)
        {
            log("Updating User.ini -> ConfiguredInternetSpeed to "$ClientNetSpeed);
            class'Engine.Player'.default.ConfiguredInternetSpeed=ClientNetSpeed;
            class'Engine.Player'.static.StaticSaveConfig();
        }
    }
}

defaultproperties
{
    bAddToServerPackages=true
    IconMaterialName="MutatorArt.nosym"
    ConfigMenuClassName=""
    GroupName=""
    FriendlyName="Bandwidth Fix"
    Description="Workaround 16 player 10000 netspeed bandwidth cap.  Set MaxPlayers=16 in ut2004.ini, then set real max players here"
    MaxPlayers=32
    ClientNetSpeed=20000
    bSetClientNetSpeed=true
    bPersistClientNetSpeed=false
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=true
}