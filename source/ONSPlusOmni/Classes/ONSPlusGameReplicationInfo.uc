// ONSPlus: Coded by Shambler (Shambler__@Hotmail.com or Shambler@OldUnreal.com , ICQ:108730864)
Class ONSPlusGameReplicationInfo extends GameReplicationInfo;

// Useable (i.e. variables that have clientside significance)
var bool bSelectableExits;
var bool bAllowEnhancedRadar;

// Display (i.e. variables which only serve to display enabled/disabled features to clients...some variables are used for serverside code too)
var bool bDropChecks;
var bool bNodeHealScoreFix;
var bool bVehicleHealScoreFix;
var bool bVehicleDamageScore;
var bool bPallyShieldScore;
var bool bIsolateNodeBonus;
var bool bAllowPreferredTeam;
var bool bRestrictMissileLock;
var bool bDisablePreMatchTeamSwitch;
//var bool bAllowFlyingLevi;

var bool bVehicleDistanceCheck;
var float RespawnTimerDistance;
var int DistanceCheckTimer;

var float HealScoreQuota;
var float DamageScoreQuota;
var float PallyScoreQuota;
var int IsolateBonusPctPerNode;

replication
{
	reliable if (Role == ROLE_Authority)
		bSelectableExits, bAllowEnhancedRadar, bDropChecks, bNodeHealScoreFix, bVehicleHealScoreFix,
		bVehicleDamageScore, bPallyShieldScore, bIsolateNodeBonus, HealScoreQuota, DamageScoreQuota,
		PallyScoreQuota, IsolateBonusPctPerNode, bAllowPreferredTeam, bDisablePreMatchTeamSwitch, bVehicleDistanceCheck,
		RespawnTimerDistance, DistanceCheckTimer;//, bAllowFlyingLevi;
}