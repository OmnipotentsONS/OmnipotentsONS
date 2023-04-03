// work around 10000 netspeed cap when MaxPlayers > 16
// usage - set MaxPlayers = 16 in game settings, then set real max players using this mutator

class MutBandwidthFix extends Mutator;

var() config int MaxPlayers;
var() config int ClientNetSpeed;
var() config bool bSetClientNetSpeed;
var() config bool bPersistClientNetSpeed;
var() config bool bSetMaxClientRate;
var() config int MaxClientRateValue;

var() config bool bSetMaxClientRateCompleted;

replication
{
    reliable if(Role == ROLE_Authority)
        ClientNetSpeed, bSetClientNetSpeed, bPersistClientNetSpeed, bSetMaxClientRate, MaxClientRateValue;
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
        if(bSetMaxClientRate && !bSetMaxClientRateCompleted)
        {
            log("Updating UT2004.ini -> MaxClientRate to "$MaxClientRateValue);
            //IpDrv.TcpNetDriver is not exposed via script, need to use console to access it
            ConsoleCommand("set IpDrv.TcpNetDriver MaxClientRate "$MaxClientRateValue);
            ConsoleCommand("set IpDrv.TcpNetDriver MaxInternetClientRate "$MaxClientRateValue);
            class'MutBandwidthFix'.default.bSetMaxClientRateCompleted=true;
            class'MutBandwidthFix'.static.StaticSaveConfig();
        }

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

simulated function Tick(float DT)
{
    super.Tick(DT);
    if(Role == ROLE_Authority)
    {
        //for whatever reason MaxPlayers slowly gets smaller... force it to always be what we want
        //here
        if(Level != None && Level.Game != None)
            Level.Game.MaxPlayers = Clamp(MaxPlayers,0,32);
    }
}

defaultproperties
{
    bAddToServerPackages=true
    IconMaterialName="MutatorArt.nosym"
    ConfigMenuClassName=""
    GroupName=""
    FriendlyName="Bandwidth Fix 1.2"
    Description="Workaround 16 player 10000 netspeed bandwidth cap.  Set MaxPlayers=16 in ut2004.ini, then set real max players here"
    MaxPlayers=32
    ClientNetSpeed=30000
    bSetClientNetSpeed=true
    bPersistClientNetSpeed=false
    bSetMaxClientRate=true
    MaxClientRateValue=100000
    //this is to keep track on client and should always default to false
    bSetMaxClientRateCompleted=false
    RemoteRole=ROLE_SimulatedProxy
    bAlwaysRelevant=true
}