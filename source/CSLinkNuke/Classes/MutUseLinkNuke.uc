class MutUseLinkNuke extends Mutator config(CSLinkNuke);

var() config bool bHealNodes;
var() config int NodeHealRate;
var() config float NodeHealDuration;

var() config bool bHealPlayers;
var() config int PlayerHealRate;
var() config float PlayerHealDuration;
var() config int PlayerHealMax;

var() config bool bHealVehicles;
var() config int VehicleHealRate;
var() config float VehicleHealDuration;
var() config int VehicleHealMax;

var() config int Damage;
var() config int CoreDamage;
var() config int RespawnTime;

var() config bool bFlipNodes;

defaultproperties
{
	bAddToServerPackages=True
	GroupName=""
	FriendlyName="Link Nuke Configuration"
	Description="Link Nuke Configuration"
	ConfigMenuClassName="CSLinkNuke.MutLinkNukeConfig"

	bHealNodes=True
	NodeHealRate=150
	NodeHealDuration=5.0

	bHealPlayers=True
	PlayerHealRate=10
	PlayerHealDuration=5.0
	PlayerHealMax=199

	bHealVehicles=True
	VehicleHealRate=100
	VehicleHealDuration=5.0
	VehicleHealMax=800
    CoreDamage=6000
	Damage=250
	RespawnTime=60

	bFlipNodes=True
}
