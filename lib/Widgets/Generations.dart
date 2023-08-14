import 'package:flutter/material.dart';
import 'package:requests/requests.dart';
import 'package:html/parser.dart' show parse;

class Generations extends StatefulWidget {
  const Generations({Key? key}) : super(key: key);

  @override
  State<Generations> createState() => _GenerationsState();
}

class _GenerationsState extends State<Generations> {
  List<String> pokemonNames = [];
  List<String> names = [];
  List<String> pokemonImages = [];
  List<String> numOfPokemon = [];
  List<String> typesOfPokemon = [];

  @override
  void initState() {
    // TODO: implement initState
    _getPokemon().then((value) {
      setState(() {
        pokemonNames = value["pokemonNames"];
        pokemonImages = value["pokemonImages"];
        numOfPokemon = value["numOfPokemon"];
        typesOfPokemon = value["typesOfPokemon"];
      });
    }); // setState(() => pokemon = value)
    super.initState();
  }

  TextEditingController textController = TextEditingController();

  Future<Map<String, dynamic>> _getPokemon() async {
    const String baseUrl = 'https://pokemondb.net/pokedex/national';
    var r = await Requests.get(baseUrl);
    r.raiseForStatus();
    String body = r.content();

    var doc = parse(body);
    var aTags = doc.querySelectorAll('a');
    // var imgs = doc.querySelectorAll('span');
    var imgs = doc.querySelectorAll('img');
    var infoAboutPokemon = doc.querySelectorAll('small');

    for (var i = 0; i < infoAboutPokemon.length; i++) {
      numOfPokemon.add(infoAboutPokemon[i].text);
      typesOfPokemon.add(infoAboutPokemon[i + 1].text);
      i++;
    }

    for (var i = 0; i < imgs.length; i++) {
      if (imgs[i].attributes['src'] != null) {
        if (imgs[i].attributes['src']!.contains("https://img.pokemondb.net/sprites/home/normal/")) {
          pokemonImages.add(imgs[i].attributes['src'].toString());
        }
      }
    }

    for (var i = 0; i < aTags.length; i++) {
      if (aTags[i].className == "ent-name") {
        pokemonNames.add(aTags[i].text);
      }
    }

    Map<String, dynamic> pokemonData = {
      "numOfPokemon": numOfPokemon,
      "typesOfPokemon": typesOfPokemon,
      "pokemonImages": pokemonImages,
      "pokemonNames": pokemonNames
    };

    return pokemonData;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 60,
      child: ListView.builder(
        itemCount: pokemonNames.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: <Widget>[
                Image.network(pokemonImages[index]),
                Text(pokemonNames[index]),
                Text(typesOfPokemon[index]),
              ],
            ),
          );
        },
      ),
    );
  }
}
