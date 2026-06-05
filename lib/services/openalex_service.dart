import 'package:dio/dio.dart';

import '../models/publication.dart';

class OpenAlexService{

final Dio dio=Dio(

BaseOptions(

connectTimeout:
Duration(seconds:5),

receiveTimeout:
Duration(seconds:5)

)

);

Future<List<Publication>>
searchPublication(
String keyword
)

async{

try{

final response=

await dio.get(

'https://api.openalex.org/works?search=$keyword'

);

List results=
response.data['results'];

return results

.map((e)=>

Publication.fromJson(e)

)

.toList();

}
catch(e){

throw Exception(
"API Failed"
);

}

}

}