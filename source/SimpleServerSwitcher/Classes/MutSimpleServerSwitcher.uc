
class MutSimpleServerSwitcher extends Mutator;

var bool bSwitched;

simulated function bool IsUpdatedToGameSpy()
{
    return class'IpDrv.MasterServerLink'.default.MasterServerList.Length == 1 &&
    class'IpDrv.MasterServerLink'.default.MasterServerList[0].Address == "utmaster.openspy.net";
}

simulated function UpdateToGameSpy()
{
    class'IpDrv.MasterServerLink'.default.MasterServerList.Length = 1;
    class'IpDrv.MasterServerLink'.default.MasterServerList[0].Address = "utmaster.openspy.net";
    class'IpDrv.MasterServerLink'.default.MasterServerList[0].Port = 28902;
    class'IpDrv.MasterServerLink'.static.StaticSaveConfig();
}

simulated function Tick(float DT)
{
    super.Tick(DT);
    if(Role < ROLE_Authority && !bSwitched)
    {

        if(!IsUpdatedToGameSpy())
            UpdateToGameSpy();
        Disable('Tick');
        bSwitched=true;
    }
}

defaultproperties
{
    FriendlyName="Simple Server Switcher"
    Description="Simple Server Switcher changes the players master server configuration from Epic to OpenSpy"
    RemoteRole=ROLE_SimulatedProxy
    bNetTemporary=true
    bAlwaysRelevant=true
    bAddToServerPackages=True
    bSwitched=False
}