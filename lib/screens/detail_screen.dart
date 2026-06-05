import 'package:flutter/material.dart';

import '../models/publication.dart';

class DetailScreen extends StatelessWidget {

final Publication publication;

const DetailScreen({

super.key,
required this.publication

});

@override
Widget build(BuildContext context){

return Scaffold(

appBar: AppBar(

title: Text("Detail")

),

body: Padding(

padding: EdgeInsets.all(20),

child: Column(

crossAxisAlignment:
CrossAxisAlignment.start,

children:[

Text(

publication.title,

style: TextStyle(
fontSize:22,
fontWeight: FontWeight.bold
),

),

SizedBox(height:20),

Text(
"Year:${publication.year}"
),

Text(
"Citations:${publication.citationCount}"
),

Text(
"Journal:${publication.journal}"
),

Text(
"DOI:${publication.doi}"
)

],

)

)

);

}

}