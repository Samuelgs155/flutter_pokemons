class Pokemon {
  final String name;
  final String url;
  final int id;
  final String imageUrl;
  final String fallbackImageUrl;
  final String type;
  final int height;
  final int weight;
  final int baseExperience;
  final List<String> abilities;
  final List<String> types;
  final Map<String, int> stats;
  final int movesCount;
  final String genus;
  final String cryUrl;
  final int generation;
  final bool isFavorite;

  const Pokemon({
    required this.name,
    required this.url,
    required this.id,
    required this.imageUrl,
    required this.fallbackImageUrl,
    this.type = 'normal',
    this.height = 0,
    this.weight = 0,
    this.baseExperience = 0,
    this.abilities = const [],
    this.types = const [],
    this.stats = const {},
    this.movesCount = 0,
    this.genus = '',
    this.cryUrl = '',
    this.generation = 1,
    this.isFavorite = false,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final dynamic rawUrl = json['url'];
    final String url = rawUrl is String ? rawUrl : '';

    int id = 0;
    if (url.isNotEmpty) {
      final segments = Uri.parse(url).pathSegments;
      if (segments.length >= 2) {
        id = int.tryParse(segments[segments.length - 2]) ?? 0;
      }
    }

    final dynamic rawName = json['name'];
    final String name = rawName is String ? rawName : '';

    return Pokemon(
      name: name,
      url: url,
      id: id,
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/versions/generation-v/black-white/animated/$id.gif',
      fallbackImageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
      type: 'normal',
      height: 0,
      weight: 0,
      baseExperience: 0,
      abilities: const [],
      types: const [],
      stats: const {},
      movesCount: 0,
      genus: '',
      cryUrl: '',
      generation: 1,
      isFavorite: false,
    );
  }

  Pokemon copyWith({
    String? name,
    String? url,
    int? id,
    String? imageUrl,
    String? fallbackImageUrl,
    String? type,
    int? height,
    int? weight,
    int? baseExperience,
    List<String>? abilities,
    List<String>? types,
    Map<String, int>? stats,
    int? movesCount,
    String? genus,
    String? cryUrl,
    int? generation,
    bool? isFavorite,
  }) {
    return Pokemon(
      name: name ?? this.name,
      url: url ?? this.url,
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      fallbackImageUrl: fallbackImageUrl ?? this.fallbackImageUrl,
      type: type ?? this.type,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      baseExperience: baseExperience ?? this.baseExperience,
      abilities: abilities ?? this.abilities,
      types: types ?? this.types,
      stats: stats ?? this.stats,
      movesCount: movesCount ?? this.movesCount,
      genus: genus ?? this.genus,
      cryUrl: cryUrl ?? this.cryUrl,
      generation: generation ?? this.generation,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}