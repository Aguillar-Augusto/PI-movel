import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testetcc2/models/classes/livro.dart';

class LivrosMock {
  static const String _chaveCustomizados = 'livros_customizados';

  static final List<Livro> _base = [
    // Romance
    Livro(id: 'r1', titulo: 'A Dama das Camélias', autor: 'Alexandre Dumas Filho',
        urlCapa: 'https://picsum.photos/seed/r1/300/450',
        descricao: 'Um clássico romance francês sobre amor, sacrifício e redenção na Paris do século XIX.',
        genero: 'Romance', favorito: true),
    Livro(id: 'r2', titulo: 'Orgulho e Preconceito', autor: 'Jane Austen',
        urlCapa: 'https://picsum.photos/seed/r2/300/450',
        descricao: 'Elizabeth Bennet e o Sr. Darcy protagonizam um dos romances mais amados da literatura inglesa.',
        genero: 'Romance'),
    Livro(id: 'r3', titulo: 'O Morro dos Ventos Uivantes', autor: 'Emily Brontë',
        urlCapa: 'https://picsum.photos/seed/r3/300/450',
        descricao: 'Uma história intensa de amor e vingança nos pântanos ingleses.',
        genero: 'Romance'),
    Livro(id: 'r4', titulo: 'Cem Anos de Solidão', autor: 'Gabriel García Márquez',
        urlCapa: 'https://picsum.photos/seed/r4/300/450',
        descricao: 'A saga da família Buendía na cidade fictícia de Macondo.',
        genero: 'Romance', favorito: true),
    Livro(id: 'r5', titulo: 'Dom Casmurro', autor: 'Machado de Assis',
        urlCapa: 'https://picsum.photos/seed/r5/300/450',
        descricao: 'Bentinho narra sua obsessão e dúvida sobre a fidelidade de Capitu.',
        genero: 'Romance'),
    Livro(id: 'r6', titulo: 'O Grande Gatsby', autor: 'F. Scott Fitzgerald',
        urlCapa: 'https://picsum.photos/seed/r6/300/450',
        descricao: 'Jay Gatsby e sua obsessão por Daisy Buchanan na era do jazz.',
        genero: 'Romance'),

    // Aventura
    Livro(id: 'a1', titulo: 'A Ilha do Tesouro', autor: 'Robert Louis Stevenson',
        urlCapa: 'https://picsum.photos/seed/a1/300/450',
        descricao: 'Jim Hawkins parte em busca de um tesouro pirata escondido.',
        genero: 'Aventura', favorito: true),
    Livro(id: 'a2', titulo: 'As Viagens de Gulliver', autor: 'Jonathan Swift',
        urlCapa: 'https://picsum.photos/seed/a2/300/450',
        descricao: 'Lemuel Gulliver visita terras fantásticas habitadas por seres extraordinários.',
        genero: 'Aventura'),
    Livro(id: 'a3', titulo: 'Vinte Mil Léguas Submarinas', autor: 'Júlio Verne',
        urlCapa: 'https://picsum.photos/seed/a3/300/450',
        descricao: 'Uma jornada pelos oceanos a bordo do submarino Nautilus.',
        genero: 'Aventura'),
    Livro(id: 'a4', titulo: 'Robinson Crusoé', autor: 'Daniel Defoe',
        urlCapa: 'https://picsum.photos/seed/a4/300/450',
        descricao: 'A sobrevivência de um náufrago em uma ilha deserta.',
        genero: 'Aventura'),
    Livro(id: 'a5', titulo: 'O Hobbit', autor: 'J.R.R. Tolkien',
        urlCapa: 'https://picsum.photos/seed/a5/300/450',
        descricao: 'Bilbo Bolseiro é levado a uma jornada inesperada rumo à Montanha Solitária.',
        genero: 'Aventura', favorito: true),
    Livro(id: 'a6', titulo: 'Moby Dick', autor: 'Herman Melville',
        urlCapa: 'https://picsum.photos/seed/a6/300/450',
        descricao: 'A obsessiva caçada do capitão Ahab pela grande baleia branca.',
        genero: 'Aventura'),

    // Terror
    Livro(id: 't1', titulo: 'Drácula', autor: 'Bram Stoker',
        urlCapa: 'https://picsum.photos/seed/t1/300/450',
        descricao: 'O conde Drácula deixa a Transilvânia rumo à Inglaterra em busca de sangue novo.',
        genero: 'Terror'),
    Livro(id: 't2', titulo: 'Frankenstein', autor: 'Mary Shelley',
        urlCapa: 'https://picsum.photos/seed/t2/300/450',
        descricao: 'O Dr. Frankenstein cria vida e enfrenta as consequências de sua ambição.',
        genero: 'Terror', favorito: true),
    Livro(id: 't3', titulo: 'O Iluminado', autor: 'Stephen King',
        urlCapa: 'https://picsum.photos/seed/t3/300/450',
        descricao: 'Jack Torrance e sua família enfrentam forças sombrias no Hotel Overlook.',
        genero: 'Terror'),
    Livro(id: 't4', titulo: 'O Médico e o Monstro', autor: 'Robert Louis Stevenson',
        urlCapa: 'https://picsum.photos/seed/t4/300/450',
        descricao: 'O Dr. Jekyll luta contra seu alter ego perverso, Mr. Hyde.',
        genero: 'Terror'),
    Livro(id: 't5', titulo: 'A Queda da Casa de Usher', autor: 'Edgar Allan Poe',
        urlCapa: 'https://picsum.photos/seed/t5/300/450',
        descricao: 'Um conto sombrio sobre a decadência de uma família amaldiçoada.',
        genero: 'Terror'),
    Livro(id: 't6', titulo: 'It: A Coisa', autor: 'Stephen King',
        urlCapa: 'https://picsum.photos/seed/t6/300/450',
        descricao: 'Um grupo de amigos enfrenta uma entidade maligna que assombra a cidade de Derry.',
        genero: 'Terror'),
  ];

  static List<Livro> _customizados = [];

  static List<Livro> get todos => [..._base, ..._customizados];

  static Future<void> carregarCustomizados() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonData = prefs.getString(_chaveCustomizados);
    if (jsonData == null) return;
    final List<dynamic> lista = json.decode(jsonData);
    _customizados = lista.map((item) => Livro.fromMap(item)).toList();
  }

  static Future<void> adicionarLivro(Livro livro) async {
    _customizados.add(livro);
    final prefs = await SharedPreferences.getInstance();
    final String jsonData = json.encode(_customizados.map((l) => l.toMap()).toList());
    await prefs.setString(_chaveCustomizados, jsonData);
  }

  static List<Livro> porGenero(String genero) {
    if (genero.toLowerCase() == 'favoritos') {
      return todos.where((l) => l.favorito).toList();
    }
    return todos.where((l) => l.genero.toLowerCase() == genero.toLowerCase()).toList();
  }

  static List<Livro> pesquisar(String termo) {
    if (termo.trim().isEmpty) return todos;
    final t = termo.toLowerCase();
    return todos.where((l) => l.titulo.toLowerCase().contains(t) || l.autor.toLowerCase().contains(t)).toList();
  }

  static const List<String> generos = ['Romance', 'Aventura', 'Terror'];
}