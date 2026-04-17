class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<AddressModel> addresses;
  final int selectedAddressIndex;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.addresses = const [],
    this.selectedAddressIndex = 0,
  });

  UserModel copyWith({
    String? name, String? email, String? phone,
    List<AddressModel>? addresses, int? selectedAddressIndex,
  }) => UserModel(
    id: id, name: name ?? this.name, email: email ?? this.email,
    phone: phone ?? this.phone, addresses: addresses ?? this.addresses,
    selectedAddressIndex: selectedAddressIndex ?? this.selectedAddressIndex,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'email': email, 'phone': phone,
    'addresses': addresses.map((a) => a.toMap()).toList(),
    'selectedAddressIndex': selectedAddressIndex,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'], name: map['name'], email: map['email'],
    phone: map['phone'] ?? '',
    addresses: (map['addresses'] as List? ?? []).map((a) => AddressModel.fromMap(a)).toList(),
    selectedAddressIndex: map['selectedAddressIndex'] ?? 0,
  );
}

class AddressModel {
  final String id;
  final String title;       // Ev / İş / Okul / Diğer
  final double lat;
  final double lng;
  // Auto-filled from reverse geocode
  final String city;        // İl
  final String district;    // İlçe
  final String neighborhood;// Mahalle
  // User-filled
  final String street;      // Cadde/Sokak
  final String aptName;     // Site/Apt Adı (Ev) veya Üniversite Adı (Okul)
  final String buildingNo;  // Bina/Blok (Ev/İş) veya Fakülte/Blok (Okul)
  final String floor;       // Kat (Ev/İş)
  final String doorNo;      // Daire No (Ev/İş)
  final String description; // Adres tarifi (opsiyonel)

  const AddressModel({
    required this.id,
    required this.title,
    required this.lat,
    required this.lng,
    required this.city,
    required this.district,
    required this.neighborhood,
    required this.street,
    required this.buildingNo,
    required this.floor,
    required this.doorNo,
    this.aptName = '',
    this.description = '',
  });

  String get displayAddress {
    final parts = [
      if (aptName.isNotEmpty) aptName,
      if (street.isNotEmpty) street,
      if (buildingNo.isNotEmpty) buildingNo,
      if (floor.isNotEmpty) 'Kat:$floor',
      if (doorNo.isNotEmpty) 'D:$doorNo',
      neighborhood,
      district,
      city,
    ];
    return parts.join(', ');
  }

  String get shortAddress => '$neighborhood, $district / $city';

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'lat': lat, 'lng': lng,
    'city': city, 'district': district, 'neighborhood': neighborhood,
    'street': street, 'aptName': aptName, 'buildingNo': buildingNo,
    'floor': floor, 'doorNo': doorNo, 'description': description,
  };

  factory AddressModel.fromMap(Map<String, dynamic> map) => AddressModel(
    id: map['id'] ?? '', title: map['title'] ?? 'Ev',
    lat: (map['lat'] ?? 41.01).toDouble(), lng: (map['lng'] ?? 28.97).toDouble(),
    city: map['city'] ?? '', district: map['district'] ?? '',
    neighborhood: map['neighborhood'] ?? '', street: map['street'] ?? '',
    aptName: map['aptName'] ?? '', buildingNo: map['buildingNo'] ?? '',
    floor: map['floor'] ?? '', doorNo: map['doorNo'] ?? '',
    description: map['description'] ?? '',
  );
}
