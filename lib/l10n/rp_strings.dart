/// German-first copy for the app shell. Swap for a real i18n layer later.
abstract final class RpStrings {
  static const appName = 'Ratepanik';
  static const soon = 'Bald';
  static const or = 'oder';
  static const player = 'Spieler';
  static const partyPlayer = 'Partyspieler';
  static const back = 'Zurück';
  static const loading = 'Laden…';

  // Landing
  static const landingTagline = 'Wer falsch liegt, lebt gefährlich.';
  static const landingGuestTitle = 'Als Gast beitreten';
  static const landingGuestSubtitle = 'Du hast einen Raum-Code?';
  static const landingJoin = 'Beitreten';
  static const landingRegister = 'Registrieren';
  static const landingLogin = 'Anmelden';
  static const landingFooter = 'Als Gast brauchst du nur den Code vom Host.';
  static const landingCodeError = 'Code muss genau 6 Zeichen haben.';
  static const landingJoinHint = 'ABC123';

  // Login
  static const loginSubtitle = 'Anmelden zum Spielen';
  static const loginEmailLabel = 'Mit E-Mail anmelden';
  static const loginEmail = 'E-Mail';
  static const loginPassword = 'Passwort';
  static const loginSubmit = 'Anmelden';
  static const loginNoAccount = 'Noch kein Konto? Registrieren';
  static const loginMoreOptions = 'Weitere Optionen';
  static const loginGoogle = 'Mit Google anmelden';
  static const loginGuest = 'Als Gast beitreten (nur mitspielen)';
  static const loginBackHome = '← Zurück zur Startseite';
  static const loginShowPassword = 'Zeigen';
  static const loginHidePassword = 'Verbergen';
  static const loginError = 'Anmeldung fehlgeschlagen.';
  static const loginErrorCredentials = 'E-Mail oder Passwort falsch.';
  static const loginGuestLoading = 'Gast-Konto wird erstellt…';

  // Register
  static const registerTitle = 'Konto erstellen';
  static const registerSubtitle = 'Erstelle dein Ratepanik-Konto';
  static const registerSubmit = 'Registrieren';
  static const registerHaveAccount = 'Schon ein Konto? Anmelden';
  static const registerSuccess =
      'Konto erstellt! Prüfe deine E-Mail für die Bestätigung.';
  static const registerError = 'Registrierung fehlgeschlagen.';

  // Home
  static const homeStreakTitle = 'Streak';
  static const homeStreakNull =
      'Kalendertage in Folge — noch nicht gespeichert.';
  static String homeStreakDays(int n) =>
      'Kalendertage in Folge gespielt.';
  static const homeCreateKicker = 'Du bist der Host';
  static const homeCreateTitle = 'Raum erstellen';
  static const homeCreateBody = 'Quiz wählen, Freunde einladen, losraten.';
  static const homeJoinKicker = 'Raumcode bereit?';
  static const homeJoinTitle = 'Spiel beitreten';
  static const homeJoinButton = 'Beitreten';
  static const homeJoinCodeLength = 'Code muss genau 6 Zeichen haben.';
  static const homeHirncoinsAria = 'Hirncoins';
  static const homePreviewHint = '0/6 Zeichen';
  static const homeFriends = 'Freunde';
  static const homeFriendsBody = 'Crew aufbauen';
  static const homeStats = 'Statistik';
  static const homeErfolge = 'Erfolge';
  static const homeShop = 'Shop';
  static const homeShopBody = 'Hirnkiste';
  static const homeLogout = 'Abmelden';

  // Lobby
  static const lobbyTitle = 'Lobby';
  static const lobbyCode = 'Raum-Code';
  static const lobbyStart = 'Spiel starten';
  static const lobbyWaiting = 'Warten auf Host…';
  static const lobbyPlayersSuffix = 'Spieler';
  static const lobbyKick = 'Rauswerfen';
  static const lobbyLeave = 'Raum verlassen';
  static const lobbyHost = 'Host';
  static const lobbyGuest = 'Gast';
  static const lobbySettings = 'Einstellungen';
  static const lobbyShareLink = 'Teile den Code mit Freunden!';

  // Match / game
  static const matchBlock = 'Block';
  static const matchRound = 'Runde';
  static const matchNext = 'Weiter';
  static const matchFinish = 'Ergebnis anzeigen';
  static const matchWaiting = 'Warte auf andere Spieler…';
  static const matchScoreboard = 'Punkte';
  static const matchFinal = 'Endergebnis';
  static const matchPlayAgain = 'Nochmal spielen';
  static const matchBackHome = 'Zurück zum Start';

  // Number guess
  static const guessTitle = 'Wie viel?';
  static const guessPlaceholder = 'Deine Schätzung';
  static const guessSubmit = 'Abschicken';
  static const guessRevealTitle = 'Auflösung';
  static const guessCorrectAnswer = 'Richtige Antwort';

  // Find lie
  static const findLieTitle = 'Welche Aussage ist die Lüge?';
  static const findLieRevealTitle = 'Auflösung';

  // Order it
  static const orderItTitle = 'Bringe in die richtige Reihenfolge';
  static const orderItSubmit = 'Absenden';
  static const orderItRevealTitle = 'Richtige Reihenfolge';

  // Pick correct
  static const pickCorrectTitle = 'Finde die passenden Karten!';

  // Theme picker
  static const themePickTitle = 'Wähle ein Thema';
  static const themePickWaiting = 'wartet…';

  // Shop
  static const shopTitle = 'Hirnkiste';
  static const shopBuy = 'Kaufen';
  static const shopOpen = 'Öffnen';
  static const shopNotEnough = 'Nicht genug Hirncoins';

  // Profile
  static const profileTitle = 'Profil';
  static const profileLevel = 'Level';
  static const profileXp = 'XP';
  static const profileHirncoins = 'Hirncoins';

  // Friends
  static const friendsTitle = 'Freunde';
  static const friendsAdd = 'Freund hinzufügen';
  static const friendsEmpty = 'Noch keine Freunde.';

  // Achievements
  static const achievementsTitle = 'Erfolge';
  static const achievementsEmpty = 'Noch keine Erfolge freigeschaltet.';
}
