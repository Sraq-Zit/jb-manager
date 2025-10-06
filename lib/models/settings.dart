class Settings {
  final String idDevise;
  final List<Devise> devises;
  final Map<String, Tva> listTva;
  final Map<String, Unities> unities;
  final List<String> linesTypes;
  final List<Priority> priorities;
  final List<UserDetail>? users;

  Settings({
    required this.idDevise,
    required this.devises,
    required this.listTva,
    required this.unities,
    required this.linesTypes,
    required this.priorities,
    required this.users,
  });

  static Settings sample() => Settings(
    idDevise: 'EUR',
    devises: [Devise.sample()],
    listTva: {Tva.sample().id: Tva.sample()},
    unities: {Unities.sample().id: Unities.sample()},
    linesTypes: ['product', 'service'],
    priorities: [Priority.sample()],
    users: [UserDetail.sample()],
  );

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    idDevise: json['id_devise'],
    devises: List<Devise>.from(json['devises'].map((e) => Devise.fromJson(e))),
    listTva: Map.fromEntries(
      (json['list_tva'] as List)
          .map((e) => Tva.fromJson(e))
          .map((tva) => MapEntry(tva.id, tva)),
    ),
    unities: Map.fromEntries(
      (json['unities'] as List)
          .map((e) => Unities.fromJson(e))
          .map((unit) => MapEntry(unit.id, unit)),
    ),
    linesTypes: List<String>.from(json['lines_types']),
    priorities: List<Priority>.from(
      json['priorities'].map((e) => Priority.fromJson(e)),
    ),
    users: json['users'] == null
        ? null
        : List<UserDetail>.from(
            json['users'].map((e) => UserDetail.fromJson(e)),
          ),
  );

  Map<String, dynamic> toJson() => {
    'id_devise': idDevise,
    'devises': devises
        .map((e) => {'id': e.id, 'designation': e.designation})
        .toList(),
    'list_tva': listTva.values
        .map((e) => {'id': e.id, 'taux': e.taux})
        .toList(),
    'unities': unities.values.map((e) => {'id': e.id, 'code': e.code}).toList(),
    'lines_types': linesTypes,
    'priorities': priorities.map((e) => {'id': e.id, 'name': e.name}).toList(),
    'users': users
        ?.map(
          (e) => {
            'id': e.id,
            'firstname': e.firstname,
            'lastname': e.lastname,
            'email': e.email,
          },
        )
        .toList(),
  };
}

class Devise {
  final String id;
  final String designation;

  Devise({required this.id, required this.designation});

  static Devise sample() => Devise(id: 'USD', designation: 'US Dollar');

  factory Devise.fromJson(Map<String, dynamic> json) =>
      Devise(id: json['id'], designation: json['designation']);
}

class Tva {
  final String id;
  final String taux;

  Tva({required this.id, required this.taux});

  static Tva sample() => Tva(id: '1', taux: '20%');

  factory Tva.fromJson(Map<String, dynamic> json) =>
      Tva(id: json['id'], taux: json['taux']);
}

class Unities {
  final String id;
  final String code;

  Unities({required this.id, required this.code});

  static Unities sample() => Unities(id: '1', code: 'kg');

  factory Unities.fromJson(Map<String, dynamic> json) =>
      Unities(id: json['id'], code: json['code']);
}

class Priority {
  final String id;
  final String name;

  Priority({required this.id, required this.name});

  static Priority sample() => Priority(id: '1', name: 'High');

  factory Priority.fromJson(Map<String, dynamic> json) =>
      Priority(id: json['id'], name: json['name']);
}

class UserDetail {
  final String id;
  final String firstname;
  final String lastname;
  final String email;

  UserDetail({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
  });

  static UserDetail sample() => UserDetail(
    id: '123',
    firstname: 'John',
    lastname: 'Doe',
    email: 'john.doe@example.com',
  );

  factory UserDetail.fromJson(Map<String, dynamic> json) => UserDetail(
    id: json['id'],
    firstname: json['firstname'],
    lastname: json['lastname'],
    email: json['email'],
  );
}
