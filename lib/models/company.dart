import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/charlieutil.dart';

class WasteCompanyModel {

  static Query generateQuery(List<WasteType>? wasteTypes) {
    var companyQuery = FirebaseFirestore.instance.collection('companies')
        .orderBy('name');

    if (wasteTypes != null && wasteTypes.isNotEmpty) {
      companyQuery = companyQuery.where('waste_types',
          arrayContainsAny: wasteTypes.map((wasteType) => wasteType.name).toList());
    }

    return companyQuery;
  }

}

class WasteCompany {
  String id;
  String name;
  String address;
  List<WasteType> wasteTypes;
  String phone;
  GeoPoint location;

  WasteCompany({
    required this.id,
    required this.name,
    required this.address,
    required this.wasteTypes,
    required this.phone,
    required this.location,
  });

  WasteCompany.fromJson(String id, Map<String, dynamic> json): this(
    id: id,
    name: json['name'] as String,
    address: json['address'] as String,
    wasteTypes: (json['waste_types'] as List<dynamic>).map((wasteTypeName) {
      return WasteType.fromName(wasteTypeName);
    }).toList(),
    phone: json['phone'] as String,
    location: json['location'] as GeoPoint
  );

  Map<String, Object> toJson() {
    return {
      'name': name,
      'address': address,
      'waste_types': wasteTypes.map<String>((wasteType) {
        return wasteType.name;
      }),
      'phone': phone,
      'location': location
    };
  }
}
