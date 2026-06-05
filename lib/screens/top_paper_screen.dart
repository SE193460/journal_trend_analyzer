import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/publication_provider.dart';

class TopPaperScreen
extends StatelessWidget{

const TopPaperScreen(
{super.key});

@override
Widget build(BuildContext context){

var provider=
Provider.of<PublicationProvider>(context);

var papers=
[...provider.publications];

papers.sort(

(a,b)=>

b.citationCount
.compareTo(
a.citationCount
)

);

return Scaffold(

appBar: AppBar(
title: Text(
"Top Papers"
)
),

body: ListView.builder(

itemCount: papers.length,

itemBuilder:(context,index){

return ListTile(

leading:
Text(
"${index+1}"
),

title:
Text(
papers[index].title
),

subtitle:
Text(
"Citation:${papers[index].citationCount}"
)

);

}

)

);

}

}