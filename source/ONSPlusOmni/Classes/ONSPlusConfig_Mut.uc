Class ONSPlusConfig_Mut extends Object
	dependson(ONSPlusMutator)
	PerObjectConfig
	config(ONSPlus);

var config bool bDisablePlayerClass;
var config bool bDropChecks;
var config bool bSelectableExits;
var config bool bNodeHealScoreFix;
var config bool bVehicleHealScore;
var config bool bVehicleDamageScore;
var config bool bPallyShieldScore;

var config float HealValueScore;
var config float DamageValueScore;
var config float PallyValueScore;

var config bool bNodeIsolateBonus;
var config int IsolateBonusPctPerNode;

var config bool bAllowEnhancedRadar;
var config bool bRestrictMissileLock;
var config bool bDisablePreferredTeam;
var config bool bDisableVersionCheck;
var config bool bDisableONSPlusTurrets;
var config bool bDisablePreMatchTeamSwitch;

var config bool bVehicleDistanceCheck;
var config float RespawnTimerDistance;
var config int DistanceCheckTimer;

var config array<ONSPlusMutator.EFilteredWord> BlackListedWords;
var config int MaxWordHits;
var config ONSPlusMutator.EMaxHitAction MaxHitAction;
var config bool bEnableWordFilter;
var config bool bClientSendFilter;

var config bool bFilterAdmin;

var config bool bEnableCustomVehiclePlugins;
var config array<String> CustomVehiclePlugins;

var config bool bRPGCompatible;

defaultproperties
{
	bDropChecks=True
	bAllowEnhancedRadar=True
	bRestrictMissileLock=True

	bSelectableExits=True

	bNodeHealScoreFix=True
	bVehicleHealScore=True
	bVehicleDamageScore=True
	bPallyShieldScore=True

	bNodeIsolateBonus=True
	IsolateBonusPctPerNode=20

	HealValueScore=200.000000
	DamageValueScore=400.000000
	PallyValueScore=1000.000000

	bVehicleDistanceCheck=True
	RespawnTimerDistance=2500.000000
	DistanceCheckTimer=30

	bEnableCustomVehiclePlugins=False

	bRPGCompatible=False
}