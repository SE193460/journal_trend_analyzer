import 'package:flutter/material.dart';

import '../models/publication.dart';
import '../screens/detail_screen.dart';

class PublicationCard extends StatelessWidget {

final Publication publication;

const PublicationCard({

super.key,
required this.publication

});

@override
Widget build(BuildContext context){

return Card(

child: ListTile(

title: Text(
publication.title
),

subtitle: Column(

crossAxisAlignment:
CrossAxisAlignment.start,

children: [

Text(
"Year:${publication.year}"
),

Text(
"Citation:${publication.citationCount}"
),

Text(
"Journal:${publication.journal}"
)

],

),

onTap:(){

Navigator.push(

context,

MaterialPageRoute(

builder:(_)=>

DetailScreen(

publication:
publication

)

)

);

},

),

);

}

}