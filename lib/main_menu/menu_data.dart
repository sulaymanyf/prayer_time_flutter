import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:date_format/date_format.dart';
import "package:flutter/services.dart" show rootBundle;
import 'package:flutter_app/paryer_time/paryer_times.dart';
import 'package:flutter_app/timeline/timeline.dart';
import 'package:flutter_app/timeline/timeline_entry.dart';
import 'package:flutter_app/paryer_time/calculation_method.dart';
import 'package:flutter_app/paryer_time/calculation_parameters.dart';
import 'package:flutter_app/paryer_time/coordinates.dart';
import 'package:flutter_app/paryer_time/data/date_components.dart';
import 'package:flutter_app/paryer_time/enum_class/calculation_method_names.dart';
import 'package:flutter_app/paryer_time/enum_class/madhab.dart';

/// Data container for the Section loaded in [MenuData.loadFromBundle()].
class MenuSectionData {
  String label;
  String name;
  String time;
  Color textColor;
  Color backgroundColor;
  String assetId;
  List<MenuItemData> items = List<MenuItemData>();
}

/// Data container for all the sub-elements of the [MenuSection].
class MenuItemData {
  String name;
  String time;
  String label;
  double start;
  double end;
  bool pad = false;
  double padTop = 0.0;
  double padBottom = 0.0;

  MenuItemData();
  /// When initializing this object from a [TimelineEntry], fill in the
  /// fields according to the [entry] provided. The entry in fact specifies
  /// a [label], a [start] and [end] times.
  /// Padding is built depending on the type of the [entry] provided.
  MenuItemData.fromEntry(TimelineEntry entry) {
    label = entry.label;

    /// Pad the edges of the screen.
    pad = true;
    TimelineAsset asset = entry.asset;
    /// Extra padding for the top base don the asset size.
    padTop = asset == null ? 0.0 : asset.height * Timeline.AssetScreenScale;
    if (asset is TimelineAnimatedAsset) {
      padTop += asset.gap;
    }

    if (entry.type == TimelineEntryType.Era) {
      start = entry.start;
      end = entry.end;
    } else {
      /// No need to pad here as we are centering on a single item.
      double rangeBefore = double.maxFinite;
      for (TimelineEntry prev = entry.previous;
          prev != null;
          prev = prev.previous) {
        double diff = entry.start - prev.start;
        if (diff > 0.0) {
          rangeBefore = diff;
          break;
        }
      }

      double rangeAfter = double.maxFinite;
      for (TimelineEntry next = entry.next; next != null; next = next.next) {
        double diff = next.start - entry.start;
        if (diff > 0.0) {
          rangeAfter = diff;
          break;
        }
      }
      double range = min(rangeBefore, rangeAfter) / 2.0;
      start = entry.start;
      end = entry.end + range;
    }
  }
}

/// This class has the sole purpose of loading the resources from storage and 
/// de-serializing the JSON file appropriately. 
/// 
/// `menu.json` contains an array of objects, each with:
/// * label - the title for the section
/// * background - the color on the section background
/// * color - the accent color for the menu section
/// * asset - the background Flare/Nima asset id that will play the section background
/// * items - an array of elements providing each the start and end times for that link
/// as well as the label to display in the [MenuSection].
class MenuData {
  List<MenuSectionData> sections = [];
  Future<bool> loadFromBundle(String filename) async {
    List<MenuSectionData> menu = List<MenuSectionData>();
    String data = await rootBundle.loadString(filename);
    List jsonEntries = json.decode(data) as List;
    final Coordinates coordinates = new Coordinates(24.46 ,118.1);
    var time = DateTime.now().toUtc();
    final DateComponents dateComponents =
    DateComponents(time.year, time.month, time.day);
    final CalculationParameters parameters =
    CalculationMethod.getCalculationMethodParams(
        CalculationMethodNames.NORTH_AMERICA);
    parameters.madhab = Madhab.HANAFI;
    var dateTime = DateTime.now();
    PrayerTimes prayerTimes = PrayerTimes(coordinates, dateComponents, parameters);
    for (dynamic entry in jsonEntries) {
      Map map = entry as Map;

      if (map != null) {
        MenuSectionData menuSection = MenuSectionData();
        menu.add(menuSection);
        if (map.containsKey("label")) {
          menuSection.label = map["label"] as String;
        }
        if (map.containsKey("name")) {
          menuSection.name = map["name"];
          var map2 = map["name"];
          switch (map2){
            case 'fajr':
              menuSection.time = formatDate(prayerTimes.fajr,[HH, ':', nn,]);
              break;
            case 'sunrise':
              menuSection.time = formatDate(prayerTimes.sunrise,[HH, ':', nn,]);
              break;
            case 'dhuhr':
              menuSection.time = formatDate(prayerTimes.dhuhr,[HH, ':', nn,]);
              break;
            case 'asr':
              menuSection.time = formatDate(prayerTimes.asr,[HH, ':', nn,]);
              break;
            case 'maghrib':
              menuSection.time = formatDate(prayerTimes.maghrib,[HH, ':', nn,]);
              break;
            case 'isha':
              menuSection.time = formatDate(prayerTimes.isha,[HH, ':', nn,]);
              break;
          }
        }
        if (map.containsKey("background")) {
          menuSection.backgroundColor = Color(int.parse(
                  (map["background"] as String).substring(1, 7),
                  radix: 16) +
              0xFF000000);
        }
        if (map.containsKey("color")) {
          menuSection.textColor = Color(
              int.parse((map["color"] as String).substring(1, 7), radix: 16) +
                  0xFF000000);
        }
        if (map.containsKey("asset")) {
          menuSection.assetId = map["asset"] as String;
        }
        if (map.containsKey("items")) {
          List items = map["items"] as List;
          for (dynamic item in items) {
            Map itemMap = item as Map;
            if (itemMap == null) {
              continue;
            }
            MenuItemData itemData = MenuItemData();
            if (itemMap.containsKey("label")) {
              itemData.label = itemMap["label"] as String;
            }
            if (itemMap.containsKey("start")) {
              dynamic start = itemMap["start"];
              itemData.start = start is int ? start.toDouble() : start;
            }
            if (itemMap.containsKey("end")) {
              dynamic end = itemMap["end"];
              itemData.end = end is int ? end.toDouble() : end;
            }
            menuSection.items.add(itemData);
          }
        }
      }
    }
    sections = menu;
    return true;
  }
}
