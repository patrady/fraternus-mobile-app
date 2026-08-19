/// Adapted from docs/app_concept.md's `Frat Night Virtue` table — e.g.
/// justice, prudence, temperance. Referenced by [FratNightTemplate].
class FratNightVirtue {
  const FratNightVirtue({required this.id, required this.key, required this.name});

  final String id;

  /// Lowercase form of [name], e.g. 'justice'. Referenced by
  /// [FratNightTemplate.fratNightVirtueKey].
  final String key;
  final String name;

  factory FratNightVirtue.fromJson(Map<String, dynamic> json) {
    return FratNightVirtue(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
    );
  }
}
