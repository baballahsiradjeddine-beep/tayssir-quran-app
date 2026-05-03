import 'package:dio/dio.dart';
import 'package:tayssir/providers/dio/dio.dart';

class RemoteGeoDataSource {
  final DioClient client;

  RemoteGeoDataSource({required this.client});

  Future<Response> getWilayas() async {
    final response = await client.getStaticContent('/wilayas');
    return response;
  }

  Future<Response> getCommunesByWilaya(int wilayaId) async {
    final response =
        await client.getStaticContent('/wilayas/$wilayaId/communes');
    return response;
  }

  Future<Response> getCountries() async {
    final response = await client.get('/v1/countries');
    return response;
  }

  Future<Response> getRegionsByCountry(int countryId) async {
    final response = await client.get('/v1/countries/$countryId/regions');
    return response;
  }
}
