class Info_ReaperStealthTimer extends Info;
var float CloakTimeCost;
var config float Duration;

simulated function PostBeginPlay()
{
    local Reaper R;

    R = Reaper(Owner);
    if (R == None)
    {
        Destroy();
        return;
    }

    Duration=R.ConfigCloakTime;
    StartEffect(R);
}

function StartEffect(Reaper R)
{
    R.SetInvisibility(Duration);
}

function StopEffect(Reaper R)
{
    R.SetInvisibility(0.0);
    R.bInvis=false;
    R.bOldInvis=true;
}
function Destroyed()
{
    local Reaper R;

    R = Reaper(Owner);

    if (R != None)
    {
        StopEffect(R);
    }
}
simulated function Tick(float DeltaTime)
{
    local Reaper R;

    R = Reaper(Owner);

    if (R == None)
	{
        Destroy();
        return;
    }
    //if ( (R.Controller.PlayerReplicationInfo != None) && (R.Controller.PlayerReplicationInfo.HasFlag != None) )
	//	DeltaTime *= 2;
    if(R.bInvis)
        R.CloakTime -= CloakTimeCost*DeltaTime/Duration;

    if (R.CloakTime <= 0.0)
    {
        R.CloakTime = 0.0;
        StopEffect(R);
        //Destroy();
    }
}

defaultproperties
{
     CloakTimeCost=100.000000
     Duration=60.000000
}
