class Pet {
  final int? id;
  final String name;
  final String species;
  final String? breed;
  final int? age;
  final String? personality;

  Pet({
    this.id,
    required this.name,
    required this.species,
    this.breed,
    this.age,
    this.personality,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as int?,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      age: json['age'] as int?,
      personality: json['personality'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'personality': personality,
    };
  }
}