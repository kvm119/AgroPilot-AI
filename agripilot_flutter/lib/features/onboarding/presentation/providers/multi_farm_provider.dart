import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/farm_gis_entity.dart';

const String _kFarmHiveBox = 'agri_user_farms_box';
const String _kActiveFarmIdKey = 'active_farm_id';

class MultiFarmState {
  final FarmGisEntity? activeFarm;
  final List<FarmGisEntity> allFarms;
  final bool isLoading;
  final String? errorMessage;

  const MultiFarmState({
    this.activeFarm,
    this.allFarms = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  MultiFarmState copyWith({
    FarmGisEntity? activeFarm,
    List<FarmGisEntity>? allFarms,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MultiFarmState(
      activeFarm: activeFarm ?? this.activeFarm,
      allFarms: allFarms ?? this.allFarms,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class MultiFarmNotifier extends StateNotifier<MultiFarmState> {
  MultiFarmNotifier() : super(const MultiFarmState(isLoading: true)) {
    _initStorageAndLoad();
  }

  static final FarmGisEntity defaultInitialFarm = FarmGisEntity(
    id: 'default_farm_guntur',
    name: 'Main Farm Field',
    surveyNumber: 'Survey 42/A',
    village: 'Guntur Rural',
    mandal: 'Guntur Mandal',
    district: 'Guntur',
    state: 'Andhra Pradesh',
    country: 'India',
    pincode: '522002',
    latitude: 16.3067,
    longitude: 80.4365,
    elevationMeters: 33.0,
    areaSqMeters: 10117.0, // 2.5 Acres
    cropType: 'Cotton',
    landmark: 'Near Water Channel',
    isDefault: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Future<void> _initStorageAndLoad() async {
    try {
      if (!Hive.isBoxOpen(_kFarmHiveBox)) {
        await Hive.openBox(_kFarmHiveBox);
      }
      final box = Hive.box(_kFarmHiveBox);

      final List<FarmGisEntity> loadedFarms = [];
      final rawList = box.get('farms_list');

      if (rawList != null && rawList is List) {
        for (var item in rawList) {
          try {
            if (item is String) {
              loadedFarms.add(FarmGisEntity.fromJson(json.decode(item)));
            } else if (item is Map) {
              loadedFarms.add(FarmGisEntity.fromJson(Map<String, dynamic>.from(item)));
            }
          } catch (_) {}
        }
      }

      if (loadedFarms.isEmpty) {
        loadedFarms.add(defaultInitialFarm);
        await _saveFarmsToHive(box, loadedFarms);
      }

      final activeId = box.get(_kActiveFarmIdKey) ?? loadedFarms.first.id;
      final active = loadedFarms.firstWhere(
        (f) => f.id == activeId,
        orElse: () => loadedFarms.first,
      );

      state = MultiFarmState(
        activeFarm: active,
        allFarms: loadedFarms,
        isLoading: false,
      );
    } catch (e) {
      state = MultiFarmState(
        activeFarm: defaultInitialFarm,
        allFarms: [defaultInitialFarm],
        isLoading: false,
      );
    }
  }

  Future<void> _saveFarmsToHive(Box box, List<FarmGisEntity> farms) async {
    final rawList = farms.map((f) => json.encode(f.toJson())).toList();
    await box.put('farms_list', rawList);
  }

  Future<void> addFarm(FarmGisEntity newFarm) async {
    final box = Hive.box(_kFarmHiveBox);
    final updatedList = List<FarmGisEntity>.from(state.allFarms);

    final finalFarm = newFarm.id.isEmpty ? newFarm.copyWith(id: const Uuid().v4()) : newFarm;

    updatedList.add(finalFarm);
    await _saveFarmsToHive(box, updatedList);

    await switchActiveFarm(finalFarm.id);
  }

  Future<void> switchActiveFarm(String farmId) async {
    final box = Hive.box(_kFarmHiveBox);
    final target = state.allFarms.firstWhere(
      (f) => f.id == farmId,
      orElse: () => state.allFarms.first,
    );

    await box.put(_kActiveFarmIdKey, target.id);
    state = state.copyWith(activeFarm: target);
  }

  Future<void> updateFarm(FarmGisEntity updatedFarm) async {
    final box = Hive.box(_kFarmHiveBox);
    final updatedList = state.allFarms.map((f) {
      return f.id == updatedFarm.id ? updatedFarm : f;
    }).toList();

    await _saveFarmsToHive(box, updatedList);

    FarmGisEntity? newActive = state.activeFarm;
    if (state.activeFarm?.id == updatedFarm.id) {
      newActive = updatedFarm;
    }

    state = state.copyWith(allFarms: updatedList, activeFarm: newActive);
  }

  Future<void> deleteFarm(String farmId) async {
    if (state.allFarms.length <= 1) return; // Must keep at least 1 farm

    final box = Hive.box(_kFarmHiveBox);
    final updatedList = state.allFarms.where((f) => f.id != farmId).toList();
    await _saveFarmsToHive(box, updatedList);

    FarmGisEntity nextActive = state.activeFarm!;
    if (state.activeFarm?.id == farmId) {
      nextActive = updatedList.first;
      await box.put(_kActiveFarmIdKey, nextActive.id);
    }

    state = state.copyWith(allFarms: updatedList, activeFarm: nextActive);
  }
}

final multiFarmProvider = StateNotifierProvider<MultiFarmNotifier, MultiFarmState>((ref) {
  return MultiFarmNotifier();
});
