class UsuarioModel {
  final String id;
  final String nome;
  final String email;
  final DateTime dataNascimento;

  UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.dataNascimento,
  });

  //Converter para Map - para salvar no Realtime DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'dataNascimento': dataNascimento.toIso8601String(),
    };
  }

  //Converter de Map - para ao buscar dados do DB
  factory UsuarioModel.fromMap(Map<dynamic, dynamic> map) {
    return UsuarioModel(
      id: map['id'],
      nome: map['nome'],
      email: map['email'],
      dataNascimento: DateTime.parse(map['dataNascimento']),
    );
  }
}
