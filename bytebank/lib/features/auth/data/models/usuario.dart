class Usuario {
  final String id;
  final String nome;
  final String email;
  final DateTime criadoEm;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.criadoEm,
  });

  //Converter para Map - para salvar no Realtime DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'criadoEm': criadoEm.toIso8601String(),
    };
  }

  //Converter de Map - para ao buscar dados do DB
  factory Usuario.fromMap(Map<dynamic, dynamic> map) {
    return Usuario(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      criadoEm: DateTime.parse(map['criadoEm']),
    );
  }
}
