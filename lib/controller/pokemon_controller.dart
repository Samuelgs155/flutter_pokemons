import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pokemos/models/pokemon.dart';

class PokemonController extends GetxController {
  var isLoading = false.obs;
  var error = ''.obs;

  var pokemons = <Pokemon>[].obs;

  var showOnlyFavorites = false.obs;
  var selectedType = 'All'.obs;
  var selectedGeneration = 'All'.obs;
  var searchText = ''.obs;

  List<String> get availableTypes {
    final types = <String>{'All'};
    for (final p in pokemons) {
      for (final t in p.types) {
        types.add(_capitalize(t));
      }
      if (p.types.isEmpty && p.type.isNotEmpty) {
        types.add(_capitalize(p.type));
      }
    }
    final list = types.toList();
    list.sort();
    list.remove('All');
    return ['All', ...list];
  }

  List<String> get availableGenerations => const [
        'All',
        'Gen 1',
        'Gen 2',
        'Gen 3',
        'Gen 4',
        'Gen 5',
        'Gen 6',
        'Gen 7',
        'Gen 8',
        'Gen 9',
      ];

  List<Pokemon> get filteredPokemons {
    return pokemons.where((pokemon) {
      final matchesFavorite =
          !showOnlyFavorites.value || pokemon.isFavorite == true;

      final matchesType = selectedType.value == 'All' ||
          pokemon.types
              .map((e) => e.toLowerCase())
              .contains(selectedType.value.toLowerCase()) ||
          pokemon.type.toLowerCase() == selectedType.value.toLowerCase();

      final matchesGeneration = selectedGeneration.value == 'All' ||
          _generationLabel(pokemon.generation) == selectedGeneration.value;

      final query = searchText.value.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          pokemon.name.toLowerCase().contains(query) ||
          pokemon.id.toString() == query;

      return matchesFavorite &&
          matchesType &&
          matchesGeneration &&
          matchesSearch;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchPokemons();
  }

  Future<void> fetchPokemons({int limit = 151, int offset = 0}) async {
    try {
      isLoading.value = true;
      error.value = '';

      final uri = Uri.parse(
        'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        error.value = 'Error HTTP: ${response.statusCode}';
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = (data['results'] as List?) ?? [];

      final List<Pokemon> loadedPokemons = [];

      for (final item in results) {
        final basicPokemon = Pokemon.fromJson(item as Map<String, dynamic>);

        try {
          final detailResponse = await http.get(
            Uri.parse('https://pokeapi.co/api/v2/pokemon/${basicPokemon.id}'),
          );

          final speciesResponse = await http.get(
            Uri.parse(
              'https://pokeapi.co/api/v2/pokemon-species/${basicPokemon.id}',
            ),
          );

          String mainType = 'normal';
          int height = 0;
          int weight = 0;
          int baseExperience = 0;
          List<String> parsedTypes = [];
          List<String> parsedAbilities = [];
          Map<String, int> parsedStats = {};
          int movesCount = 0;
          String genus = '';
          String cryUrl = '';
          int generation = _calculateGenerationFromId(basicPokemon.id);

          if (detailResponse.statusCode == 200) {
            final detailData =
                jsonDecode(detailResponse.body) as Map<String, dynamic>;

            final List typesJson = (detailData['types'] as List?) ?? [];
            parsedTypes = typesJson
                .map((t) => t['type']?['name'])
                .whereType<String>()
                .toList();

            if (parsedTypes.isNotEmpty) {
              mainType = parsedTypes.first;
            }

            height = (detailData['height'] as num?)?.toInt() ?? 0;
            weight = (detailData['weight'] as num?)?.toInt() ?? 0;
            baseExperience =
                (detailData['base_experience'] as num?)?.toInt() ?? 0;

            final List abilitiesJson = (detailData['abilities'] as List?) ?? [];
            parsedAbilities = abilitiesJson
                .map((a) => a['ability']?['name'])
                .whereType<String>()
                .toList();

            final List movesJson = (detailData['moves'] as List?) ?? [];
            movesCount = movesJson.length;

            final List statsJson = (detailData['stats'] as List?) ?? [];
            parsedStats = {
              for (final stat in statsJson)
                if (stat['stat']?['name'] is String && stat['base_stat'] is num)
                  stat['stat']['name'] as String:
                      (stat['base_stat'] as num).toInt(),
            };

            final cries = detailData['cries'] as Map<String, dynamic>?;
            cryUrl = (cries?['latest'] ?? '') as String;
          }

          if (speciesResponse.statusCode == 200) {
            final speciesData =
                jsonDecode(speciesResponse.body) as Map<String, dynamic>;

            final genera = (speciesData['genera'] as List?) ?? [];
            for (final g in genera) {
              final language = g['language']?['name'];
              if (language == 'en') {
                genus = (g['genus'] ?? '') as String;
                genus = genus.replaceAll(' Pokémon', '').trim();
                break;
              }
            }

            final generationData =
                speciesData['generation'] as Map<String, dynamic>?;
            final generationName = generationData?['name'] as String?;
            if (generationName != null) {
              generation = _mapGenerationName(generationName);
            }
          }

          loadedPokemons.add(
            basicPokemon.copyWith(
              type: mainType,
              types: parsedTypes,
              height: height,
              weight: weight,
              baseExperience: baseExperience,
              abilities: parsedAbilities,
              stats: parsedStats,
              movesCount: movesCount,
              genus: genus,
              cryUrl: cryUrl,
              generation: generation,
            ),
          );
        } catch (_) {
          loadedPokemons.add(basicPokemon);
        }
      }

      pokemons.assignAll(loadedPokemons);
    } catch (e) {
      error.value = 'Error al cargar Pokémon: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleFavorite(int pokemonId) {
    final index = pokemons.indexWhere((p) => p.id == pokemonId);
    if (index == -1) return;

    final updated = pokemons[index].copyWith(
      isFavorite: !pokemons[index].isFavorite,
    );

    pokemons[index] = updated;
    pokemons.refresh();
  }

  void setFavoriteFilter(bool value) {
    showOnlyFavorites.value = value;
  }

  void setTypeFilter(String type) {
    selectedType.value = type;
  }

  void setGenerationFilter(String generation) {
    selectedGeneration.value = generation;
  }

  void setSearch(String text) {
    searchText.value = text;
  }

  void clearFilters() {
    showOnlyFavorites.value = false;
    selectedType.value = 'All';
    selectedGeneration.value = 'All';
    searchText.value = '';
  }

  String _generationLabel(int gen) => 'Gen $gen';

  int _calculateGenerationFromId(int id) {
    if (id <= 151) return 1;
    if (id <= 251) return 2;
    if (id <= 386) return 3;
    if (id <= 493) return 4;
    if (id <= 649) return 5;
    if (id <= 721) return 6;
    if (id <= 809) return 7;
    if (id <= 905) return 8;
    return 9;
  }

  int _mapGenerationName(String generationName) {
    switch (generationName) {
      case 'generation-i':
        return 1;
      case 'generation-ii':
        return 2;
      case 'generation-iii':
        return 3;
      case 'generation-iv':
        return 4;
      case 'generation-v':
        return 5;
      case 'generation-vi':
        return 6;
      case 'generation-vii':
        return 7;
      case 'generation-viii':
        return 8;
      case 'generation-ix':
        return 9;
      default:
        return 1;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}