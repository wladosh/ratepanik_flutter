import '../core/supabase_config.dart';

class MatchReward {
  final int placement;
  final int xpAwarded;
  final int hirncoinsAwarded;

  MatchReward({
    required this.placement,
    required this.xpAwarded,
    required this.hirncoinsAwarded,
  });
}

class LootboxResult {
  final bool ok;
  final bool duplicate;
  final String? itemId;
  final String? slot;
  final String? rarity;
  final String? nameDe;
  final String? assetPath;
  final int hirncoins;
  final int consolationHc;

  LootboxResult({
    required this.ok,
    required this.duplicate,
    this.itemId,
    this.slot,
    this.rarity,
    this.nameDe,
    this.assetPath,
    required this.hirncoins,
    required this.consolationHc,
  });
}

class ProfileService {
  /// Call after match finishes — awards XP + Hirncoins.
  Future<MatchReward?> grantMatchRewards(String roomId) async {
    final user = supabase.auth.currentUser;
    if (user == null || user.isAnonymous) return null;

    try {
      final resp = await supabase.rpc('grant_match_rewards', params: {
        'p_room_id': roomId,
      });
      final data = resp as Map<String, dynamic>?;
      if (data == null || data['ok'] != true) return null;
      return MatchReward(
        placement: data['placement'] as int? ?? 0,
        xpAwarded: data['xp_awarded'] as int? ?? 0,
        hirncoinsAwarded: data['hirncoins_awarded'] as int? ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  /// Updates daily streak on profiles.
  Future<int?> recordDailyPlay() async {
    final user = supabase.auth.currentUser;
    if (user == null || user.isAnonymous) return null;

    try {
      final resp = await supabase.rpc('record_daily_play');
      final data = resp as Map<String, dynamic>?;
      if (data == null || data['ok'] != true) return null;
      return data['streak'] as int?;
    } catch (_) {
      return null;
    }
  }

  /// Claim username for a fresh profile.
  Future<({bool ok, String? error})> claimUsername(String username) async {
    try {
      final resp = await supabase.rpc('claim_username', params: {
        'desired_username': username.trim(),
      });
      final data = resp as Map<String, dynamic>?;
      if (data == null) return (ok: false, error: 'Keine Antwort');
      if (data['ok'] == true) return (ok: true, error: null);
      return (ok: false, error: data['error'] as String? ?? 'Fehler');
    } catch (e) {
      return (ok: false, error: e.toString());
    }
  }

  /// Load the user's profile.
  Future<Map<String, dynamic>?> loadProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;
    try {
      return await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
    } catch (_) {
      return null;
    }
  }

  // ── Friends ──

  Future<String?> ensureFriendCode() async {
    try {
      final resp = await supabase.rpc('ensure_friend_code');
      final data = resp as Map<String, dynamic>?;
      return data?['friend_code'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<({bool ok, String? error, bool accepted})> requestFriend(
      String identifier) async {
    try {
      final resp = await supabase.rpc('request_friend', params: {
        'identifier': identifier.trim(),
      });
      final data = resp as Map<String, dynamic>?;
      if (data == null) return (ok: false, error: 'Keine Antwort', accepted: false);
      return (
        ok: data['ok'] == true,
        error: data['error'] as String?,
        accepted: data['accepted'] == true,
      );
    } catch (e) {
      return (ok: false, error: e.toString(), accepted: false);
    }
  }

  Future<({bool ok, String? error})> respondFriend(
      String friendshipId, bool accept) async {
    try {
      final resp = await supabase.rpc('respond_friend', params: {
        'friendship_id': friendshipId,
        'accept': accept,
      });
      final data = resp as Map<String, dynamic>?;
      if (data?['ok'] == true) return (ok: true, error: null);
      return (ok: false, error: data?['error'] as String? ?? 'Fehler');
    } catch (e) {
      return (ok: false, error: e.toString());
    }
  }

  Future<({bool ok, String? error})> removeFriend(String friendshipId) async {
    try {
      final resp = await supabase.rpc('remove_friend', params: {
        'friendship_id': friendshipId,
      });
      final data = resp as Map<String, dynamic>?;
      if (data?['ok'] == true) return (ok: true, error: null);
      return (ok: false, error: data?['error'] as String? ?? 'Fehler');
    } catch (e) {
      return (ok: false, error: e.toString());
    }
  }

  /// Load friendships (accepted + pending incoming).
  Future<List<Map<String, dynamic>>> loadFriendships() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final data = await supabase
          .from('friendships')
          .select('id, requester_id, addressee_id, status, created_at')
          .or('requester_id.eq.$userId,addressee_id.eq.$userId');
      return (data as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Load a profile by user id for friend display.
  Future<Map<String, dynamic>?> loadProfileById(String userId) async {
    try {
      return await supabase
          .from('profiles')
          .select('id, username, avatar_id, last_seen_at, friend_code')
          .eq('id', userId)
          .maybeSingle();
    } catch (_) {
      return null;
    }
  }

  // ── Shop / Lootbox ──

  Future<LootboxResult?> openLootbox(String boxId, String requestId) async {
    try {
      final resp = await supabase.rpc('open_lootbox', params: {
        'box_id': boxId,
        'request_id': requestId,
      });
      final data = resp as Map<String, dynamic>?;
      if (data == null || data['ok'] != true) return null;
      return LootboxResult(
        ok: true,
        duplicate: data['duplicate'] == true,
        itemId: data['item_id'] as String?,
        slot: data['slot'] as String?,
        rarity: data['rarity'] as String?,
        nameDe: data['name_de'] as String?,
        assetPath: data['asset_path'] as String?,
        hirncoins: data['hirncoins'] as int? ?? 0,
        consolationHc: data['consolation_hc'] as int? ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  /// List owned cosmetics for the current user.
  Future<List<Map<String, dynamic>>> loadOwnedCosmetics() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final data = await supabase
          .from('user_cosmetics')
          .select('item_id, acquired_at, source')
          .eq('user_id', userId);
      return (data as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Load current loadout.
  Future<List<Map<String, dynamic>>> loadLoadout() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final data = await supabase
          .from('user_loadout')
          .select('slot, item_id')
          .eq('user_id', userId);
      return (data as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Equip a cosmetic item into a slot (or null to unequip).
  Future<({bool ok, String? error})> equipSlot(
      String slot, String? itemId) async {
    try {
      final params = <String, dynamic>{'p_slot': slot};
      if (itemId != null) {
        params['p_item_id'] = itemId;
      }
      final resp = await supabase.rpc('equip_slot', params: params);
      final data = resp as Map<String, dynamic>?;
      if (data?['ok'] == true) return (ok: true, error: null);
      return (ok: false, error: data?['error'] as String? ?? 'Fehler');
    } catch (e) {
      return (ok: false, error: e.toString());
    }
  }

  /// Load all cosmetic item definitions.
  Future<List<Map<String, dynamic>>> loadCosmeticItems() async {
    try {
      final data = await supabase
          .from('cosmetic_items')
          .select()
          .eq('active', true)
          .order('sort_order');
      return (data as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
