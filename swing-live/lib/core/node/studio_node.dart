enum NodeType {
  camera,
  studio,
  controller
}

class StudioNode {
  final String id;
  final String name;
  final NodeType type;
  final String? ipAddress;
  final int? port;
  final DateTime lastSeen;

  StudioNode({
    required this.id,
    required this.name,
    required this.type,
    this.ipAddress,
    this.port,
    required this.lastSeen,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'ipAddress': ipAddress,
      'port': port,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  factory StudioNode.fromJson(Map<String, dynamic> json) {
    return StudioNode(
      id: json['id'],
      name: json['name'],
      type: NodeType.values[json['type']],
      ipAddress: json['ipAddress'],
      port: json['port'],
      lastSeen: DateTime.parse(json['lastSeen']),
    );
  }

  StudioNode copyWith({
    String? name,
    NodeType? type,
    String? ipAddress,
    int? port,
    DateTime? lastSeen,
  }) {
    return StudioNode(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
