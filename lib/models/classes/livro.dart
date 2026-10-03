class Livro {
  final String id;
  final String titulo;
  final String autor;
  final String urlCapa;
  final String descricao;
  final String genero;
  final bool favorito;

  const Livro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.urlCapa,
    required this.descricao,
    required this.genero,
    this.favorito = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'urlCapa': urlCapa,
      'descricao': descricao,
      'genero': genero,
      'favorito': favorito,
    };
  }

  factory Livro.fromMap(Map<String, dynamic> map) {
    return Livro(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      autor: map['autor'] ?? '',
      urlCapa: map['urlCapa'] ?? '',
      descricao: map['descricao'] ?? '',
      genero: map['genero'] ?? '',
      favorito: map['favorito'] ?? false,
    );
  }
}