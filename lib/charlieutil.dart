import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CharlieUtil {
  static Future<bool> isAdmin() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return false;
    } else {
      final customClaims = (await currentUser.getIdTokenResult()).claims;
      if (customClaims != null && customClaims['user-type'] == 'admin') {
        return true;
      }
    }
    return false;
  }

  static IconData getWasteIcon(WasteType wasteType) {
    switch(wasteType) {
      case WasteType.bulky:
        return Icons.local_shipping;
      case WasteType.electronic:
        return Icons.electric_bolt;
      case WasteType.batteries:
        return Icons.battery_charging_full;
      case WasteType.usedCookingOil:
        return Icons.soup_kitchen;
      case WasteType.beverageContainers:
        return Icons.local_drink;
      case WasteType.organic:
        return Icons.grass;
      case WasteType.paper:
        return Icons.feed;
      case WasteType.carOil:
        return Icons.local_gas_station;
      case WasteType.flourescentBulbsTubes:
        return Icons.light_mode;
      default:
        return Icons.recycling;
    }
  }
}

enum WasteType {
  bulky(label: 'Bulky'),
  electronic(label: 'Electronic'),
  batteries(label: 'Batteries'),
  usedCookingOil(label: 'Used Cooking Oil'),
  beverageContainers(label: 'Beverage Containers'),
  organic(label: 'Organic'),
  paper(label: 'Paper'),
  carOil(label: 'Car Oil'),
  flourescentBulbsTubes(label: 'Flourescent Bulbs/Tubes'),
  general(label: 'General');

  const WasteType({required this.label});
  factory WasteType.fromLabel(String wasteTypeLabel) {
    switch(wasteTypeLabel) {
      case 'Bulky':
        return WasteType.bulky;
      case 'Electronic':
        return WasteType.electronic;
      case 'Batteries':
        return WasteType.batteries;
      case 'Used Cooking Oil':
        return WasteType.usedCookingOil;
      case 'Beverage Containers':
        return WasteType.beverageContainers;
      case 'Organic':
        return WasteType.organic;
      case 'Paper':
        return WasteType.paper;
      case 'Car Oil':
        return WasteType.carOil;
      case 'Flourescent Bulbs/Tubes':
        return WasteType.flourescentBulbsTubes;
      default:
        return WasteType.general;
    }
  }
  factory WasteType.fromName(String wasteTypeName) {
    switch(wasteTypeName) {
      case 'bulky':
        return WasteType.bulky;
      case 'electronic':
        return WasteType.electronic;
      case 'batteries':
        return WasteType.batteries;
      case 'usedCookingOil':
        return WasteType.usedCookingOil;
      case 'beverageContainers':
        return WasteType.beverageContainers;
      case 'organic':
        return WasteType.organic;
      case 'paper':
        return WasteType.paper;
      case 'carOil':
        return WasteType.carOil;
      case 'flourescentBulbsTubes':
        return WasteType.flourescentBulbsTubes;
      default:
        return WasteType.general;
    }
  }

  static String get commaSeparatedTypes => WasteType.values.map((value) {
    return value.name;
  }).toList().join(',');

  final String label;
}

class WasteFilterList extends StatefulWidget {
  const WasteFilterList({super.key, required this.wasteTypeSelections});
  final List<WasteType> wasteTypeSelections;

  @override
  State<WasteFilterList> createState() => _WasteFilterListState();
}

class _WasteFilterListState extends State<WasteFilterList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: WasteType.values.length,
      itemBuilder: (context, index) {
        final wasteType = WasteType.values[index];
        return CheckboxListTile(
          title: Text(wasteType.label),
          secondary: Icon(CharlieUtil.getWasteIcon(wasteType)),
          onChanged: (isChecked) {
            setState(() {
              if (isChecked != null && isChecked) {
                widget.wasteTypeSelections.add(wasteType);
              } else {
                widget.wasteTypeSelections.remove(wasteType);
              }
            });
          },
          value: widget.wasteTypeSelections.contains(wasteType),
        );
      },
    );
  }
}
