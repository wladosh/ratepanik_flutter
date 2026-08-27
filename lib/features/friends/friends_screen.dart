import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase_config.dart';
import '../../l10n/rp_strings.dart';
import '../../services/profile_service.dart';
import '../../theme/rp_colors.dart';
import '../../widgets/rp_buttons.dart';
import '../../widgets/rp_hero_background.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _service = ProfileService();
  final _addCtrl = TextEditingController();
  String? _friendCode;
  List<_FriendEntry> _accepted = [];
  List<_FriendEntry> _pending = [];
  bool _loading = true;
  String? _addError;
  String? _addSuccess;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final code = await _service.ensureFriendCode();
    final friendships = await _service.loadFriendships();

    final accepted = <_FriendEntry>[];
    final pending = <_FriendEntry>[];

    for (final f in friendships) {
      final fId = f['id'] as String;
      final requesterId = f['requester_id'] as String;
      final addresseeId = f['addressee_id'] as String;
      final status = f['status'] as String;
      final otherId = requesterId == userId ? addresseeId : requesterId;
      final profile = await _service.loadProfileById(otherId);
      final name = profile?['username'] as String? ?? otherId.substring(0, 8);

      final entry = _FriendEntry(
        friendshipId: fId,
        name: name,
        isIncoming: addresseeId == userId && status == 'pending',
      );

      if (status == 'accepted') {
        accepted.add(entry);
      } else if (status == 'pending') {
        pending.add(entry);
      }
    }

    if (mounted) {
      setState(() {
        _friendCode = code;
        _accepted = accepted;
        _pending = pending;
        _loading = false;
      });
    }
  }

  Future<void> _sendRequest() async {
    final text = _addCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _sending = true;
      _addError = null;
      _addSuccess = null;
    });

    final result = await _service.requestFriend(text);
    if (mounted) {
      setState(() {
        _sending = false;
        if (result.ok) {
          _addSuccess = result.accepted
              ? 'Direkt als Freund hinzugefügt!'
              : RpStrings.friendsRequestSent;
          _addCtrl.clear();
          _loadAll();
        } else {
          _addError = result.error ?? 'Fehler';
        }
      });
    }
  }

  Future<void> _respond(String friendshipId, bool accept) async {
    await _service.respondFriend(friendshipId, accept);
    _loadAll();
  }

  Future<void> _remove(String friendshipId) async {
    await _service.removeFriend(friendshipId);
    _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return RpHeroBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text(
                        RpStrings.friendsTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              if (_loading)
                const Expanded(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: RpColors.purple)))
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Friend code
                      if (_friendCode != null)
                        RpCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                RpStrings.friendsCodeLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: RpColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: _friendCode!));
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(const SnackBar(
                                        content: Text('Code kopiert!')));
                                },
                                child: Text(
                                  _friendCode!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 4,
                                        color: RpColors.purple,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Add friend
                      RpCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              RpStrings.friendsAdd,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _addCtrl,
                              decoration: InputDecoration(
                                hintText: RpStrings.friendsAddHint,
                                errorText: _addError,
                              ),
                              onSubmitted: (_) => _sendRequest(),
                            ),
                            if (_addSuccess != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _addSuccess!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: RpColors.success),
                              ),
                            ],
                            const SizedBox(height: 12),
                            RpPrimaryButton(
                              label: _sending
                                  ? RpStrings.loading
                                  : RpStrings.friendsRequest,
                              enabled: !_sending,
                              onPressed: _sendRequest,
                            ),
                          ],
                        ),
                      ),

                      // Pending
                      if (_pending.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          RpStrings.friendsPending,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        ..._pending.map((f) => _PendingTile(
                              entry: f,
                              onAccept: () =>
                                  _respond(f.friendshipId, true),
                              onDecline: () =>
                                  _respond(f.friendshipId, false),
                            )),
                      ],

                      // Accepted
                      const SizedBox(height: 24),
                      Text(
                        RpStrings.friendsAccepted,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      if (_accepted.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/rp/rp_icon_friends_slimes_128.png',
                                width: 72,
                                height: 72,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.people_alt_rounded,
                                        size: 48, color: RpColors.purple),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                RpStrings.friendsEmpty,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: RpColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._accepted.map((f) => _FriendTile(
                              entry: f,
                              onRemove: () => _remove(f.friendshipId),
                            )),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendEntry {
  final String friendshipId;
  final String name;
  final bool isIncoming;

  _FriendEntry({
    required this.friendshipId,
    required this.name,
    required this.isIncoming,
  });
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.entry, required this.onRemove});
  final _FriendEntry entry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RpCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: RpColors.mint,
              child: Text(
                entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person_remove_rounded, size: 18),
              color: RpColors.danger,
              onPressed: onRemove,
              tooltip: RpStrings.friendsRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingTile extends StatelessWidget {
  const _PendingTile({
    required this.entry,
    required this.onAccept,
    required this.onDecline,
  });
  final _FriendEntry entry;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RpCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: RpColors.sky,
              child: Text(
                entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (entry.isIncoming) ...[
              IconButton(
                icon: const Icon(Icons.check_circle_rounded, size: 22),
                color: RpColors.success,
                onPressed: onAccept,
                tooltip: RpStrings.friendsAccept,
              ),
              IconButton(
                icon: const Icon(Icons.cancel_rounded, size: 22),
                color: RpColors.danger,
                onPressed: onDecline,
                tooltip: RpStrings.friendsDecline,
              ),
            ] else
              Text(
                RpStrings.friendsPending,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: RpColors.textSecondary,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
