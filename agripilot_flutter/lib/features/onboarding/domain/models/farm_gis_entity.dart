import 'package:latlong2/latlong.dart';
import '../../../../core/utils/gis_calculator.dart';

class FarmGisEntity {
  final String id;
  final String name;
  final String surveyNumber;
  final String village;
  final String mandal;
  final String district;
  final String state;
  final String country;
  final String pincode;

  final double latitude;
  final double longitude;
  final double elevationMeters;
  final String geoHash;
  final String timezone;

  final double areaSqMeters;
  final double perimeterMeters;
  final List<LatLng> boundaryPolygon;

  final String cropType;
  final String landmark;
  final String notes;

  final bool isDefault;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FarmGisEntity({
    required this.id,
    required this.name,
    this.surveyNumber = '',
    required this.village,
    this.mandal = 'Mandal',
    required this.district,
    required this.state,
    required this.country,
    this.pincode = '',
    required this.latitude,
    required this.longitude,
    this.elevationMeters = 0.0,
    this.geoHash = '',
    this.timezone = 'Asia/Kolkata',
    this.areaSqMeters = 0.0,
    this.perimeterMeters = 0.0,
    this.boundaryPolygon = const [],
    required this.cropType,
    this.landmark = '',
    this.notes = '',
    this.isDefault = false,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  double get areaAcres {
    if (areaSqMeters > 0) return GisCalculator.sqMetersToAcres(areaSqMeters);
    if (boundaryPolygon.length >= 3) {
      return GisCalculator.sqMetersToAcres(GisCalculator.calculatePolygonAreaSqMeters(boundaryPolygon));
    }
    return 2.5; // Default reference plot size if single pin point
  }

  double get areaHectares {
    return GisCalculator.sqMetersToHectares(areaSqMeters > 0
        ? areaSqMeters
        : (boundaryPolygon.length >= 3 ? GisCalculator.calculatePolygonAreaSqMeters(boundaryPolygon) : 10117.0));
  }

  bool get isWithinIndia {
    final c = country.trim().toLowerCase();
    return c == 'india' || c == 'in' || (latitude >= 6.0 && latitude <= 37.5 && longitude >= 68.0 && longitude <= 97.5);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'survey_number': surveyNumber,
      'village': village,
      'mandal': mandal,
      'district': district,
      'state': state,
      'country': country,
      'pincode': pincode,
      'latitude': latitude,
      'longitude': longitude,
      'elevation_meters': elevationMeters,
      'geo_hash': geoHash,
      'timezone': timezone,
      'area_sq_meters': areaSqMeters,
      'perimeter_meters': perimeterMeters,
      'boundary_polygon': boundaryPolygon.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'crop_type': cropType,
      'landmark': landmark,
      'notes': notes,
      'is_default': isDefault,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory FarmGisEntity.fromJson(Map<String, dynamic> json) {
    List<LatLng> polygon = [];
    if (json['boundary_polygon'] != null && json['boundary_polygon'] is List) {
      polygon = (json['boundary_polygon'] as List).map((p) {
        return LatLng(
          double.tryParse(p['lat'].toString()) ?? 0.0,
          double.tryParse(p['lng'].toString()) ?? 0.0,
        );
      }).toList();
    }

    return FarmGisEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Farm Field',
      surveyNumber: json['survey_number'] ?? '',
      village: json['village'] ?? 'Village',
      mandal: json['mandal'] ?? 'Mandal',
      district: json['district'] ?? 'District',
      state: json['state'] ?? 'State',
      country: json['country'] ?? 'India',
      pincode: json['pincode'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 16.3067,
      longitude: double.tryParse(json['longitude'].toString()) ?? 80.4365,
      elevationMeters: double.tryParse(json['elevation_meters'].toString()) ?? 0.0,
      geoHash: json['geo_hash'] ?? '',
      timezone: json['timezone'] ?? 'Asia/Kolkata',
      areaSqMeters: double.tryParse(json['area_sq_meters'].toString()) ?? 0.0,
      perimeterMeters: double.tryParse(json['perimeter_meters'].toString()) ?? 0.0,
      boundaryPolygon: polygon,
      cropType: json['crop_type'] ?? 'Paddy',
      landmark: json['landmark'] ?? '',
      notes: json['notes'] ?? '',
      isDefault: json['is_default'] ?? false,
      isArchived: json['is_archived'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  FarmGisEntity copyWith({
    String? id,
    String? name,
    String? surveyNumber,
    String? village,
    String? mandal,
    String? district,
    String? state,
    String? country,
    String? pincode,
    double? latitude,
    double? longitude,
    double? elevationMeters,
    String? geoHash,
    String? timezone,
    double? areaSqMeters,
    double? perimeterMeters,
    List<LatLng>? boundaryPolygon,
    String? cropType,
    String? landmark,
    String? notes,
    bool? isDefault,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FarmGisEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      surveyNumber: surveyNumber ?? this.surveyNumber,
      village: village ?? this.village,
      mandal: mandal ?? this.mandal,
      district: district ?? this.district,
      state: state ?? this.state,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      elevationMeters: elevationMeters ?? this.elevationMeters,
      geoHash: geoHash ?? this.geoHash,
      timezone: timezone ?? this.timezone,
      areaSqMeters: areaSqMeters ?? this.areaSqMeters,
      perimeterMeters: perimeterMeters ?? this.perimeterMeters,
      boundaryPolygon: boundaryPolygon ?? this.boundaryPolygon,
      cropType: cropType ?? this.cropType,
      landmark: landmark ?? this.landmark,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
