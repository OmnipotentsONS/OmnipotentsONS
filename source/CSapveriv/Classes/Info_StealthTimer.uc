class Info_StealthTimer extends Info config (CSAPVerIV);
var float CloakTimeCost;
var config float Duration;

function PostBeginPlay()
{
    local Phantom P;

    P = Phantom(Owner);
    if (P == None)
    {
        Destroy();
        return;
    }

    StartEffect(P);
}
function StartEffect(Phantom P)
{
    P.SetInvisibility(Duration);
}

function StopEffect(Phantom P)
{
    P.SetInvisibility(0.0);
}
function Destroyed()
{
    local Phantom P;

    P = Phantom(Owner);

    if (P != None)
    {
        StopEffect(P);
    }
}
simulated function Tick(float DeltaTime)
{
    local Phantom P;

    P = Phantom(Owner);

    if ( (P == None) || (P.Controller == None) )
	{
        Destroy();
        return;
    }
    if ( (P.Controller.PlayerReplicationInfo != None) && (P.Controller.PlayerReplicationInfo.HasFlag != None) )
		DeltaTime *= 2;
    P.CloakTime -= CloakTimeCost*DeltaTime/Duration;
    if (P.CloakTime <= 0.0)
    {
        P.CloakTime = 0.0;
        Destroy();
    }
}

defaultproperties
{
     CloakTimeCost=100.000000
     Duration=60.000000
}
