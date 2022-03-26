/**
Localizable HUD message about EvenMatch's actions and game state assessments.

Copyright (c) 2009-2015, Wormbo

(1) This source code and any binaries compiled from it are provided "as-is",
without warranty of any kind. (In other words, if it breaks something for you,
that's entirely your problem, not mine.)
(2) You are allowed to reuse parts of this source code and binaries compiled
from it in any way that does not involve making money, breaking applicable laws
or restricting anyone's human or civil rights.
(3) You are allowed to distribute binaries compiled from modified versions of
this source code only if you make the modified sources available as well. I'd
prefer being mentioned in the credits for such binaries, but please do not make
it seem like I endorse them in any way.
*/

class UnevenMessage extends CriticalEventPlus;


//=============================================================================
// Localization
//=============================================================================

var localized string QuickRoundBalanceString;
var localized string PrevMatchBalanceString;
var localized string FirstRoundWinnerString;
var localized string TeamsUnbalancedString;
var localized string SoftBalanceString;
var localized string ForcedBalanceString;
var localized string CallForBalanceString;
var localized string NoCallForBalanceNowString;
var localized string NoCallForBalanceEvenString;
var localized string YouWereSwitchedString;
var localized string PlayerWasSwitchedString;
var localized string TeamsImbalancedString;
var localized string TeamsAutobalanceString;


//=============================================================================
// Announcements
//=============================================================================

var name QuickRoundAnnouncement[2];


static function ClientReceive(PlayerController P, optional int MessageSwitch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	Super.ClientReceive(P, MessageSwitch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (TeamInfo(OptionalObject) != None && TeamInfo(OptionalObject).TeamIndex < 2) {
		switch (MessageSwitch) {
		case 0:
			P.QueueAnnouncement(default.QuickRoundAnnouncement[TeamInfo(OptionalObject).TeamIndex], 1, AP_NoDuplicates);
			break;
		}
	}
}


static function string GetString(optional int MessageSwitch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	switch (MessageSwitch) {
	case -7:
		return Repl(Repl(default.TeamsImbalancedString, "%r", int(GamePPH(OptionalObject).RedPPH)), "%b", int(GamePPH(OptionalObject).BluePPH));
	case -6:
		return Repl(Repl(default.PlayerWasSwitchedString, "%t", TeamInfo(OptionalObject).GetHumanReadableName()), "%p", RelatedPRI_1.PlayerName);
	case -5:
		return default.YouWereSwitchedString;
	case -4:
		return Repl(Repl(default.NoCallForBalanceEvenString, "%r", int(GamePPH(OptionalObject).RedPPH)), "%b", int(GamePPH(OptionalObject).BluePPH));
	case -3:
		return default.NoCallForBalanceNowString;
	case -2:
		return Repl(Repl(Repl(default.CallForBalanceString, "%p", RelatedPRI_1.PlayerName), "%r", int(GamePPH(OptionalObject).RedPPH)), "%b", int(GamePPH(OptionalObject).BluePPH));
	case -1:
		return Repl(Repl(default.PrevMatchBalanceString, "%r", int(GamePPH(OptionalObject).RedPPH)), "%b", int(GamePPH(OptionalObject).BluePPH));
	case 0:
		return default.QuickRoundBalanceString;
	case 1:
	case 2:
		return Repl(default.FirstRoundWinnerString, "%t", class'TeamInfo'.default.ColorNames[MessageSwitch - 1]);
	case 3:
		return default.SoftBalanceString;
	case 4:
		return Repl(Repl(default.ForcedBalanceString, "%r", int(GamePPH(OptionalObject).RedPPH)), "%b", int(GamePPH(OptionalObject).BluePPH));
	case 5:
		return default.TeamsAutobalanceString;
	default:
		if (MessageSwitch > 3)
			return Repl(default.TeamsUnbalancedString, "%n", 10 * (MessageSwitch - 4));
	}
	return "";
}


//=============================================================================
// Default values
//=============================================================================

defaultproperties
{
	QuickRoundBalanceString = "Mulligan!!! Restarting with balanced teams"
	PrevMatchBalanceString  = "Teams have been balanced based on skill: Red(%r) Blue(%b)"
	FirstRoundWinnerString  = "%t won the first round"
	SoftBalanceString       = "Teams are uneven, respawning players may switch to balance"
	TeamsUnbalancedString   = "Teams are uneven, balance will be forced in %n seconds"
	ForcedBalanceString     = "Teams rebalanced, new balance: Red(%r) Blue(%b)"
	CallForBalanceString    = "%p called for a team balance check: Red(%r) Blue(%b)"
	NoCallForBalanceNowString  = "You can't request a team balance check at this time."
	NoCallForBalanceEvenString = "Teams look even already: Red(%r) Blue(%b), not re-balancing."
	YouWereSwitchedString   = "Forced team change by EvenMatch"
	PlayerWasSwitchedString = "%p was switched to %t by EvenMatch"
	TeamsImbalancedString    = "Teams rebalanced: diff before(%r) after(%b)"
	TeamsAutobalanceString   = "Teams have been shuffled"

	QuickRoundAnnouncement(0) = red_team_dominating
	QuickRoundAnnouncement(1) = blue_team_dominating

	Lifetime  = 5
	DrawColor = (B=0,G=255,R=255)
	StackMode = SM_Down
	PosY      = 0.6
	bIsUnique = False
	bIsPartiallyUnique = True
}
