import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/publication_provider.dart';

class DashboardScreen
extends StatelessWidget{

const DashboardScreen(
{super.key});

@override
Widget build(BuildContext context){

var provider=
Provider.of<PublicationProvider>(context);

int total=
provider.publications.length;

double avgCitation=0;

if(total>0){

avgCitation=

provider.publications
.map((e)=>e.citationCount)
.reduce((a,b)=>a+b)

/total;

}

return Scaffold(

appBar: AppBar(

title: Text(
"Dashboard"
)

),

body: Center(

child: Column(

children:[

Text(
"Total:$total"
),

Text(
"Average Citation:${avgCitation.toStringAsFixed(2)}"
)

]

)

)

)

;

}

}