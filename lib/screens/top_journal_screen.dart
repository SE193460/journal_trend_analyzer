import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/publication_provider.dart';

class TopJournalScreen
extends StatelessWidget{

const TopJournalScreen(
{super.key});

@override
Widget build(BuildContext context){

var provider=
Provider.of<PublicationProvider>(context);

Map<String,int> journals={};

for(var p in provider.publications){

journals[p.journal]=
(journals[p.journal]??0)+1;

}

return Scaffold(

appBar: AppBar(
title: Text(
"Top Journal"
)
),

body: ListView(

children:
journals.entries.map(

(e){

return ListTile(

title:
Text(e.key),

trailing:
Text(
"${e.value}"
)

);

}

).toList()

)

);

}

}