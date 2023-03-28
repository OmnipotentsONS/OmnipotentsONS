//-----------------------------------------------------------
// (c) RBThinkTank 07
//  Coded by milk & Charybdis + Significant chunks of code from the original link gun.
//   MutLinkScorpon.uc - A simple mutator with some adjustable settings
//-----------------------------------------------------------
class MutLinkScorpion extends Mutator
	config(LinkVehiclesOmni);

var config int LinkDamage;
var config int LinkRange;
var config int VehicleMass;
var config int StartingHealth;
var config int MaxHealth;
var config int JumpForce;
var config int SpeedScale;
var config bool bAirControl;
var config bool bJumping;
var config bool bIfFlippedEject;
var config bool bReplaceScorpions;

replication
{

	reliable if( Role == ROLE_Authority && bNetDirty)
		LinkRange, StartingHealth, MaxHealth,bJumping, bAirControl,JumpForce;

}

function bool CheckReplacement( Actor Other, out byte bSuperRelevant )
{
    if ( ONSVehicleFactory(Other) != None && bReplaceScorpions)
	{
		if ( ONSVehicleFactory(Other).VehicleClass == class'Onslaught.ONSRV' )
		{
			ONSVehicleFactory(Other).VehicleClass = Class'LinkVehiclesOmni.LinkScorpion3Omni';
		}
		else
			return true;
	}
	else
		return true;
}


simulated function PostNetBeginPlay()
{
	local int i;
	
	Super.PostNetBeginPlay();
	class'LinkVehiclesOmni.LinkScorpion3Gun'.default.TraceRange = LinkRange;
	class'LinkVehiclesOmni.LinkScorpion3Omni'.default.Health = StartingHealth;			
	class'LinkVehiclesOmni.LinkScorpion3Omni'.default.HealthMax = MaxHealth;	
	class'LinkVehiclesOmni.LinkScorpion3Omni'.default.bAllowAirControl = bAirControl;	
	class'LinkVehiclesOmni.LinkScorpion3Omni'.default.bAllowChargingJump = bJumping;	
	class'LinkVehiclesOmni.LinkScorpion3Omni'.default.MaxJumpForce = JumpForce;
	if(Role == Role_Authority)
	{
	    For (i = 0; i < 5; i++)
			class'LinkVehiclesOmni.LinkScorpion3Omni'.default.GearRatios[i] *= SpeedScale;
		class'LinkVehiclesOmni.LinkScorpion3Gun'.default.Damage = LinkDamage;
		class'LinkVehiclesOmni.LinkScorpion3Omni'.default.VehicleMass = VehicleMass;						

		class'LinkVehiclesOmni.LinkScorpion3Omni'.default.bEjectPassengersWhenFlipped = bIfFlippedEject;
		class'LinkVehiclesOmni.LinkScorpion3Omni'.default.TorqueCurve.Points[0].OutVal *=  SpeedScale;
		class'LinkVehiclesOmni.LinkScorpion3Omni'.default.TorqueCurve.Points[1].OutVal *= SpeedScale;
		class'LinkVehiclesOmni.LinkScorpion3Omni'.default.TorqueCurve.Points[2].OutVal *= SpeedScale;
		class'LinkVehiclesOmni.LinkScorpion3Omni'.default.TorqueCurve.Points[2].InVal *= SpeedScale;
		class'LinkVehiclesOmni.LinkScorpion3Omni'.default.TorqueCurve.Points[3].InVal *= SpeedScale;
		class'LinkVehiclesOmni.LinkScorpion3Omni'.default.TorqueCurve.Points[3].OutVal *= SpeedScale * 2;
	}
}


static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.RulesGroup, "LinkDamage", "Link Damage (Default 9)", 0, 0, "Text",   "20;0:100");
	PlayInfo.AddSetting(default.RulesGroup, "LinkRange", "Link Range (Default 2000)", 0, 0, "Text",   "20;50:10000000");
	PlayInfo.AddSetting(default.RulesGroup, "VehicleMass", "Vehicle Mass (Default 3.5)", 0, 0, "Text",   "20;0.0000:1000.00");
	PlayInfo.AddSetting(default.RulesGroup, "MaxHealth", "Max Health (Default 300)", 0, 0, "Text",   "20;1:1000000");
	PlayInfo.AddSetting(default.RulesGroup, "StartingHealth", "Starting Health (Default 300)", 0, 0, "Text",   "20;1:1000000");
	PlayInfo.AddSetting(default.RulesGroup, "JumpForce", "Jump Force (Default 2000000)", 0, 0, "Text",   "20;1:20000000");
	PlayInfo.AddSetting(default.RulesGroup, "SpeedScale", "Speed Scale (Default 1)", 0, 0, "Text",   "20;1.00000:20000000.0000");
    PlayInfo.AddSetting(default.RulesGroup, "bReplaceScorpions", "Replace Scorpions", 0, 1, "Check");
    PlayInfo.AddSetting(default.RulesGroup, "bAirControl", "Allow Air Control", 0, 1, "Check");
    PlayInfo.AddSetting(default.RulesGroup, "bJumping", "Allow Jumping", 0, 1, "Check");
    PlayInfo.AddSetting(default.RulesGroup, "bIfFlippedEject", "Eject When Flipped", 0, 1, "Check");
	
}

defaultproperties
{
     LinkDamage=9
     LinkRange=2000
     VehicleMass=3
     StartingHealth=300
     MaxHealth=300
     JumpForce=2000000
     SpeedScale=1
     bAirControl=True
     bAddToServerPackages=True
     FriendlyName="Link Scorpion 3.0"
     Description="Replaces Scorpions with Link Scorpion 3.0. Many settings available in mutator configuration."
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
