import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/publication_provider.dart';

class TrendScreen extends StatelessWidget {

const TrendScreen({super.key});

@override
Widget build(BuildContext context){

var provider=
Provider.of<PublicationProvider>(context);

Map<int,int> yearCount={};

for(var p in provider.publications){

yearCount[p.year]=
(yearCount[p.year]??0)+1;

}

return Scaffold(

appBar: AppBar(
title: Text(
"Trend Analysis"
)
),

body: ListView(

children:

yearCount.entries.map(

(e){

return ListTile(

title: Text(
"${e.key}"
),

trailing: Text(
"${e.value} papers"
)

);

}

).toList()

)

);

}

}