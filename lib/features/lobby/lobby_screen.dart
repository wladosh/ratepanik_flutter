import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app.dart';
import '../../l10n/rp_strings.dart';
import '../../routing/app_router.dart';
import '../../services/game_service.dart';
import '../../theme/rp_colors.dart';
import '../../theme/rp_theme.dart';
import '../../widgets/rp_buttons.dart';
import '../../widgets/rp_hero_background.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = RatepanikApp.gameOf(context);

    return ListenableBuilder(
      listenable: game,
      builder: (context, _) {
        final state = game.state;

        // Navigate away if game phase changed
        if (state.phase == GamePhase.home) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(RpRoutes.home);
          });
        }
        if (state.phase != GamePhase.lobby && state.phase != GamePhase.home) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(RpRoutes.match);
          });
        }

        final room = state.room;
        final players = state.players;
        final isHost = state.isHost;

        return RpHeroBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                await game.leaveRoom();
                                if (context.mounted) {
                                  context.go(RpRoutes.home);
                                }
                              },
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            Expanded(
                              child: Text(
                                RpStrings.lobbyTitle,
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

                      // Room code
                      if (room != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _RoomCodeBanner(code: room.code),
                        ),

                      // Error / notice
                      if (state.error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            state.error!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: RpColors.danger),
                          ),
                        ),
                      if (state.notice != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            state.notice!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: RpColors.purple),
                          ),
                        ),

                      // Player list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: players.length,
                          itemBuilder: (context, index) {
                            final p = players[index];
                            final isMe = p.id == state.myPlayerId;
                            return _PlayerTile(
                              name: p.displayName,
                              isHost: p.isHost,
                              isMe: isMe,
                              canKick: isHost &&
                                  !isMe &&
                                  room?.status == 'lobby',
                              onKick: () => game.kickPlayer(p.id),
                            );
                          },
                        ),
                      ),

                      // Player count
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '${players.length}/${state.roomSettings.maxPlayers} ${RpStrings.lobbyPlayersSuffix}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: RpColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Start / waiting
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (isHost)
                              RpPrimaryButton(
                                label: state.loading
                                    ? RpStrings.loading
                                    : RpStrings.lobbyStart,
                                enabled:
                                    players.length >= 2 && !state.loading,
                                onPressed: () async {
                                  await game.startGame();
                                  if (context.mounted) {
                                    context.go(RpRoutes.match);
                                  }
                                },
                              )
                            else
                              Center(
                                child: Text(
                                  RpStrings.lobbyWaiting,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: RpColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            const SizedBox(height: 12),
                            RpOutlineButton(
                              label: RpStrings.lobbyLeave,
                              color: RpColors.danger,
                              onPressed: () async {
                                await game.leaveRoom();
                                if (context.mounted) {
                                  context.go(RpRoutes.home);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoomCodeBanner extends StatelessWidget {
  const _RoomCodeBanner({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return RpCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Text(
            RpStrings.lobbyCode,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: RpColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Code kopiert!')),
                );
            },
            child: Text(
              code,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 6,
                    color: RpColors.purple,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            RpStrings.lobbyShareLink,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: RpColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({
    required this.name,
    required this.isHost,
    required this.isMe,
    required this.canKick,
    required this.onKick,
  });

  final String name;
  final bool isHost;
  final bool isMe;
  final bool canKick;
  final VoidCallback onKick;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? RpColors.purpleSoft.withValues(alpha: 0.3)
            : RpColors.bgElevated,
        borderRadius: BorderRadius.circular(RpRadii.md),
        border: isMe
            ? Border.all(color: RpColors.purple, width: 2)
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isHost ? RpColors.purple : RpColors.mint,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (isHost)
                  Text(
                    RpStrings.lobbyHost,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: RpColors.purple,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
              ],
            ),
          ),
          if (isMe)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: RpColors.purple,
                borderRadius: BorderRadius.circular(RpRadii.pill),
              ),
              child: Text(
                'Du',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          if (canKick)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              color: RpColors.danger,
              onPressed: onKick,
              tooltip: RpStrings.lobbyKick,
            ),
        ],
      ),
    );
  }
}
