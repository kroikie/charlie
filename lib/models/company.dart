import 'package:cloud_firestore/cloud_firestore.dart';

class WasteCompanyModel {
  Stream<List<WasteCompany>> get stream => FirebaseFirestore.instance.collection('companies')
      .withConverter(
        fromFirestore: (snapshot, _) => WasteCompany.fromJson(snapshot.id, snapshot.data()!),
        toFirestore: (company, _) => company.toJson()
      )
      .orderBy('name')
      .snapshots().map((event) => event.docs.map((ele) => ele.data()).toList());
}

class WasteCompany {
  String id;
  final String name;
  final String address;
  final String type;
  final String phone;
  final GeoPoint location;

  WasteCompany({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.phone,
    required this.location,
  });

  WasteCompany.fromJson(String id, Map<String, Object?> json): this(
    id: id,
    name: json['name'] as String,
    address: json['address'] as String,
    type: json['waste_type'] as String,
    phone: json['phone'] as String,
    location: json['location'] as GeoPoint
  );

  Map<String, Object> toJson() {
    return {
      'name': name,
      'address': address,
      'waste_type': type,
      'phone': phone,
      'location': location
    };
  }
}