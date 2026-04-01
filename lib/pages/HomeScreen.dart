import 'package:flutter/material.dart';
import 'package:flutter_pokemos/controller/pokemon_controller.dart';
import 'package:flutter_pokemos/models/pokemon.dart';
import 'package:flutter_pokemos/pages/DetailsScreen.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PokemonController pokemonController = Get.put(PokemonController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: Stack(
        children: [
          _backgroundImage(),
          _header(),
          Positioned(
            top: 150,
            bottom: 0,
            width: width,
            child: Obx(() {
              if (pokemonController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (pokemonController.error.value.isNotEmpty) {
                return Center(
                  child: Text(
                    pokemonController.error.value,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              final pokemons = pokemonController.filteredPokemons;

              if (pokemonController.filteredPokemons.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay pokémon con esos filtros',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔥 BOTÓN VOLVER
                      ElevatedButton.icon(
                        onPressed: () {
                          pokemonController.clearFilters();
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Volver a Home'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Stack(
                children: [
                  Column(
                    children: [
                      _topSearchBar(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(8, 6, 8, 110),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.38,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                          ),
                          itemCount: pokemons.length,
                          itemBuilder: (context, index) {
                            final pokemon = pokemons[index];

                            return InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(
                                    heroTag: pokemon.id,
                                    pokemon: pokemon,
                                  ),
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(25),
                                  ),
                                  color: _getPokemonColor(
                                    pokemon.type.isNotEmpty
                                        ? pokemon.type
                                        : 'normal',
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    _innerPokeball(),
                                    // _pokemonId(pokemon),
                                    _pokemonImage(pokemon),
                                    _pokemonName(pokemon),
                                    _pokemonType(pokemon),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          pokemonController.toggleFavorite(
                                            pokemon.id,
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Icon(
                                            pokemon.isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 16,
                    bottom: 24,
                    child: _filtersPanel(context),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Positioned(
      top: 92,
      left: 20,
      right: 20,
      child: Row(
        children: [
          Text(
            'Pokedex',
            style: TextStyle(
              color: Colors.black.withOpacity(0.75),
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.tune,
              color: Colors.black.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundImage() {
    return Positioned(
      top: -40,
      right: -35,
      width: 190,
      child: Opacity(
        opacity: 0.12,
        child: Image.asset(
          'images/pokeball.png',
          fit: BoxFit.fitWidth,
          width: 190,
        ),
      ),
    );
  }

  Widget _topSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: pokemonController.setSearch,
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre o ID',
                  border: InputBorder.none,
                ),
              ),
            ),
            Obx(() {
              return pokemonController.searchText.value.isNotEmpty
                  ? InkWell(
                      onTap: () {
                        _searchController.clear();
                        pokemonController.setSearch('');
                        FocusScope.of(context).unfocus();
                      },
                      child: const Icon(Icons.close, color: Colors.grey),
                    )
                  : const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _filtersPanel(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _filterActionButton(
            text: pokemonController.showOnlyFavorites.value
                ? 'Only Favorites'
                : 'Favorite Pokemon',
            icon: Icons.favorite,
            onTap: () {
              pokemonController.setFavoriteFilter(
                !pokemonController.showOnlyFavorites.value,
              );
            },
          ),
          const SizedBox(height: 10),
          _filterDropdownButton(
            text: pokemonController.selectedType.value,
            icon: Icons.auto_awesome,
            onTap: () => _showSelectionSheet(
              context: context,
              title: 'Filter by Type',
              options: pokemonController.availableTypes,
              selected: pokemonController.selectedType.value,
              onSelected: pokemonController.setTypeFilter,
            ),
          ),
          const SizedBox(height: 10),
          _filterDropdownButton(
            text: pokemonController.selectedGeneration.value,
            icon: Icons.bolt,
            onTap: () => _showSelectionSheet(
              context: context,
              title: 'Filter by Generation',
              options: pokemonController.availableGenerations,
              selected: pokemonController.selectedGeneration.value,
              onSelected: pokemonController.setGenerationFilter,
            ),
          ),
          const SizedBox(height: 10),
          _filterActionButton(
            text: 'Clear Filters',
            icon: Icons.refresh,
            onTap: () {
              _searchController.clear();
              pokemonController.clearFilters();
            },
          ),
        ],
      );
    });
  }

  Widget _filterActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: Colors.indigo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterDropdownButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: Colors.indigo),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSelectionSheet({
    required BuildContext context,
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Flexible(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: options.map((option) {
                        final isSelected = option == selected;
                        return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            onSelected(option);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.indigo
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              option,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _innerPokeball() {
    return Positioned(
      bottom: -5,
      right: -2,
      child: Image.asset(
        'images/pokeball.png',
        height: 75,
        fit: BoxFit.fitHeight,
        color: Colors.white.withOpacity(0.28),
        colorBlendMode: BlendMode.srcIn,
      ),
    );
  }

  Widget _pokemonImage(Pokemon pokemon) {
    return Positioned(
      bottom: 6,
      right: 6,
      child: Hero(
        tag: pokemon.id,
        child: Image.network(
          pokemon.imageUrl,
          height: 84,
          fit: BoxFit.fitHeight,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Image.network(
              pokemon.fallbackImageUrl,
              height: 84,
              fit: BoxFit.fitHeight,
            );
          },
        ),
      ),
    );
  }

  Widget _pokemonName(Pokemon pokemon) {
    final name = pokemon.name.isNotEmpty ? pokemon.name : 'Unknown';

    return Positioned(
      top: 18,
      left: 14,
      right: 42,
      child: Text(
        name[0].toUpperCase() + name.substring(1),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _pokemonId(Pokemon pokemon) {
    return Positioned(
      top: 18,
      right: 12,
      child: Text(
        '#${pokemon.id.toString().padLeft(3, '0')}',
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _pokemonType(Pokemon pokemon) {
    final type = pokemon.type.isNotEmpty ? pokemon.type : 'normal';

    return Positioned(
      top: 50,
      left: 14,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.16),
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Text(
          type[0].toUpperCase() + type.substring(1),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getPokemonColor(String type) {
    switch (type.toLowerCase()) {
      case 'grass':
        return const Color(0xFF63C74D);
      case 'fire':
        return const Color(0xFFE76E55);
      case 'water':
        return const Color(0xFF4D96FF);
      case 'electric':
        return const Color(0xFFF6C945);
      case 'psychic':
        return const Color(0xFFE76EB1);
      case 'ice':
        return const Color(0xFF79D8D8);
      case 'rock':
        return const Color(0xFFB69E31);
      case 'ground':
        return const Color(0xFFC8A35D);
      case 'poison':
        return const Color(0xFFA66BDB);
      case 'bug':
        return const Color(0xFF8CB330);
      case 'ghost':
        return const Color(0xFF70559B);
      case 'dragon':
        return const Color(0xFF6F35FC);
      case 'dark':
        return const Color(0xFF705746);
      case 'steel':
        return const Color(0xFFB7B9D0);
      case 'fairy':
        return const Color(0xFFD685AD);
      case 'fighting':
        return const Color(0xFFC22E28);
      case 'flying':
        return const Color(0xFFA98FF3);
      case 'normal':
      default:
        return const Color(0xFFA8A77A);
    }
  }
}