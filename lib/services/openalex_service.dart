import 'package:dio/dio.dart';

import '../models/publication.dart';

class OpenAlexService{

  final Dio dio=Dio(
    BaseOptions(
      connectTimeout: Duration(seconds:5),
      receiveTimeout: Duration(seconds:5)
    )
  );

  Future<List<Publication>> searchPublication(String keyword) async{
    try{
      final response= await dio.get('https://api.openalex.org/works?search=$keyword&per-page=200');
      List results= response.data['results'];
      return results.map((e)=> Publication.fromJson(e)).toList();
    }catch(e){
      throw Exception("API Failed");
    }
  }

  Future<List<PublicationTrendPoint>> fetchPublicationTrend(String keyword) async{
    try{
      final response= await dio.get('https://api.openalex.org/works?search=$keyword&group_by=publication_year');
      List results= response.data['group_by'];
      return results.map((e)=> PublicationTrendPoint.fromJson(e)).toList();
    }catch(e){
      throw Exception("Trend API Failed");
    }
  }

}