class Livro {
  final String id;
  final String titulo;
  final String autor;
  final String urlCapa;
  final String urlPdf;
  final String descricao;
  final String genero;
  final String generoSecundario;
  final bool favorito;

  static const List<String> generos = [
    "Ação e Aventura",
    "Biografia",
    "Chick-Lit",
    "Clássicos",
    "Conto",
    "Crônica",
    "Distopia",
    "Drama",
    "Ensaio",
    "Fantasia",
    "Ficção Científica",
    "Ficção Histórica",
    "Ficção Policial",
    "Horror/Terror",
    "Infanto-juvenil",
    "Mistério",
    "Não Ficção",
    "Novela",
    "Poesia",
    "Realismo Mágico",
    "Religião e Espiritualidade",
    "Filosofia",
    "Romance",
    "Suspense/Thriller",
    "Tragédia",
    "Young Adult (YA)",
  ];

  const Livro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.urlCapa,
    required this.urlPdf,
    required this.descricao,
    required this.genero,
    this.generoSecundario = '',
    this.favorito = false,
  });

  Livro copyWith({bool? favorito}) {
    return Livro(
      id: id,
      titulo: titulo,
      autor: autor,
      urlCapa: urlCapa,
      urlPdf: urlPdf,
      descricao: descricao,
      genero: genero,
      generoSecundario: generoSecundario,
      favorito: favorito ?? this.favorito,
    );
  }

  bool pertenceAoGenero(String generoBusca) {
    final alvo = generoBusca.trim().toLowerCase();
    return genero.trim().toLowerCase() == alvo ||
        (generoSecundario.isNotEmpty &&
            generoSecundario.trim().toLowerCase() == alvo);
  }

  bool correspondeAPesquisa(String termo) {
    final texto = termo.trim().toLowerCase();
    if (texto.isEmpty) return true;
    return titulo.toLowerCase().contains(texto) ||
        autor.toLowerCase().contains(texto) ||
        genero.toLowerCase().contains(texto) ||
        generoSecundario.toLowerCase().contains(texto);
  }

  factory Livro.fromMap(Map<String, dynamic> map, {bool? favoritoForcado}) {
    return Livro(
      id: (map['id'] ?? '').toString(),
      titulo: (map['name'] ?? map['titulo'] ?? 'Sem Título').toString(),
      autor: (map['autor'] ?? 'Autor Desconhecido').toString(),
      urlCapa: (map['capa_path'] ?? map['urlCapa'] ?? '').toString(),
      urlPdf: (map['pdf_path'] ?? map['urlPdf'] ?? '').toString(),
      descricao: (map['sinopse'] ?? map['descricao'] ?? 'Sem descrição.').toString(),
      genero: (map['genero1'] ?? map['genero'] ?? 'Outros').toString(),
      generoSecundario: (map['genero2'] ?? '').toString(),
      favorito: favoritoForcado ?? (map['favorito'] == true),
    );
  }
}