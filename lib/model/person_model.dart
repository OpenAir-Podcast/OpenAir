class Person {
  final String name;
  final String? role;
  final String? group;
  final String? img;
  final String? href;

  Person({
    required this.name,
    this.role,
    this.group,
    this.img,
    this.href,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'] as String,
      role: json['role'] as String?,
      group: json['group'] as String?,
      img: json['img'] as String?,
      href: json['href'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        if (role != null) 'role': role,
        if (group != null) 'group': group,
        if (img != null) 'img': img,
        if (href != null) 'href': href,
      };
}
