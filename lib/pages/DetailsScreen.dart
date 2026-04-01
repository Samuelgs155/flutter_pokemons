import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pokemos/controller/pokemon_controller.dart';
import 'package:flutter_pokemos/models/pokemon.dart';
import 'package:get/get.dart';

class DetailsScreen extends StatefulWidget {
  final int heroTag;
  final Pokemon pokemon;

  const DetailsScreen({
    super.key,
    required this.heroTag,
    required this.pokemon,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingCry = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'grass':
        return const Color(0xFF6CCB5F);
      case 'fire':
        return const Color(0xFFFF9D3D);
      case 'water':
        return const Color(0xFF5BA7FF);
      case 'electric':
        return const Color(0xFFF4C542);
      case 'poison':
        return const Color(0xFF9B6BDB);
      case 'bug':
        return const Color(0xFF8BC34A);
      case 'normal':
        return const Color(0xFFB9C2CF);
      case 'psychic':
        return const Color(0xFFFF6FAE);
      case 'ground':
        return const Color(0xFFD4A373);
      case 'rock':
        return const Color(0xFFA1887F);
      case 'fighting':
        return const Color(0xFFE76F51);
      case 'ghost':
        return const Color(0xFF6D5BD0);
      case 'ice':
        return const Color(0xFF7FDBFF);
      case 'dragon':
        return const Color(0xFF5E60CE);
      case 'dark':
        return const Color(0xFF5D4037);
      case 'steel':
        return const Color(0xFF78909C);
      case 'fairy':
        return const Color(0xFFFFAFCC);
      case 'flying':
        return const Color(0xFF81B3FF);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  String _cap(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).replaceAll('-', ' ');
  }

  String _formatHeight(int value) {
    if (value <= 0) return '-';
    return '${(value / 10).toStringAsFixed(1)} m';
  }

  String _formatWeight(int value) {
    if (value <= 0) return '-';
    return '${(value / 10).toStringAsFixed(1)} kg';
  }

  String _statLabel(String key) {
    switch (key) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Attack';
      case 'defense':
        return 'Defense';
      case 'special-attack':
        return 'Sp. Atk';
      case 'special-defense':
        return 'Sp. Def';
      case 'speed':
        return 'Speed';
      default:
        return _cap(key);
    }
  }

  Pokemon _getCurrentPokemon(PokemonController controller) {
    return controller.pokemons.firstWhere(
      (p) => p.id == widget.pokemon.id,
      orElse: () => widget.pokemon,
    );
  }

  Future<void> _playCry(String cryUrl) async {
    if (cryUrl.isEmpty) return;

    setState(() => _isPlayingCry = true);

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(cryUrl));
    } catch (_) {
      // Silenciar error de audio para no romper la UI
    } finally {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() => _isPlayingCry = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PokemonController>();
    final size = MediaQuery.of(context).size;

    return Obx(() {
      final pokemon = _getCurrentPokemon(controller);
      final accent = _typeColor(pokemon.type);

      return Scaffold(
        backgroundColor: accent,
        body: Stack(
          children: [
            Positioned(
              top: -35,
              right: -20,
              child: Opacity(
                opacity: 0.16,
                child: Icon(
                  Icons.catching_pokemon,
                  size: 220,
                  color: Colors.white,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Row(
                      children: [
                        _roundButton(
                          icon: Icons.arrow_back_ios_new,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        _roundButton(
                          icon: Icons.graphic_eq,
                          onTap: () => _playCry(pokemon.cryUrl),
                          active: _isPlayingCry,
                        ),
                        const SizedBox(width: 10),
                        _roundButton(
                          icon: pokemon.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          onTap: () {
                            controller.toggleFavorite(pokemon.id);
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _cap(pokemon.name),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: pokemon.types.isNotEmpty
                                    ? pokemon.types.map(_typeChip).toList()
                                    : [_typeChip(pokemon.type)],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '#${pokemon.id.toString().padLeft(3, '0')}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              pokemon.genus.isNotEmpty
                                  ? pokemon.genus
                                  : 'Unknown',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.18,
                    child: Center(
                      child: Hero(
                        tag: widget.heroTag,
                        child: Image.network(
                          pokemon.imageUrl,
                          width: 210,
                          height: 210,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Image.network(
                            pokemon.fallbackImageUrl,
                            width: 210,
                            height: 210,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          TabBar(
                            controller: _tabController,
                            labelColor: accent,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: accent,
                            dividerColor: Colors.transparent,
                            tabs: const [
                              Tab(text: 'About'),
                              Tab(text: 'Stats'),
                              Tab(text: 'Moves'),
                              Tab(text: 'Extra'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _aboutTab(pokemon),
                                _statsTab(pokemon, accent),
                                _movesTab(pokemon),
                                _extraTab(pokemon, accent),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return Material(
      color: active
          ? Colors.white.withOpacity(0.28)
          : Colors.white.withOpacity(0.14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        _cap(type),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _aboutTab(Pokemon pokemon) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_cap(pokemon.name)} belongs to the ${pokemon.genus.isNotEmpty ? pokemon.genus : _cap(pokemon.type)} category. '
            'This profile summarizes physical traits and some key battle-related information.',
            style: TextStyle(
              height: 1.5,
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _infoBox('Height', _formatHeight(pokemon.height)),
              const SizedBox(width: 12),
              _infoBox('Weight', _formatWeight(pokemon.weight)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Abilities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: pokemon.abilities.isNotEmpty
                ? pokemon.abilities
                    .map(
                      (a) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4F8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _cap(a),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList()
                : [
                    const Text('No abilities'),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _statsTab(Pokemon pokemon, Color accent) {
    final entries = pokemon.stats.entries.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        children: entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _statRow(
                  label: _statLabel(e.key),
                  value: e.value,
                  color: accent,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _movesTab(Pokemon pokemon) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            const Icon(Icons.sports_martial_arts_outlined),
            const SizedBox(width: 10),
            const Text(
              'Moves available',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '${pokemon.movesCount}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _extraTab(Pokemon pokemon, Color accent) {
    final totalStats = pokemon.stats.values.fold<int>(0, (a, b) => a + b);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _summaryTile(
                  title: 'Primary type',
                  value: _cap(pokemon.type),
                  accent: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryTile(
                  title: 'Base exp',
                  value: '${pokemon.baseExperience}',
                  accent: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _summaryTile(
                  title: 'Total stats',
                  value: '$totalStats',
                  accent: accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryTile(
                  title: 'Cry',
                  value: pokemon.cryUrl.isNotEmpty ? 'Available' : 'No',
                  accent: accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow({
    required String label,
    required int value,
    required Color color,
  }) {
    final progress = (value / 180).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 74,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryTile({
    required String title,
    required String value,
    required Color accent,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}