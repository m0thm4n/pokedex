import 'package:advanced_search/advanced_search.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:requests/requests.dart';
import 'package:html/parser.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  var _html;
  var pokemon;
  var pokemonImg;
  var titles;
  var pokemonName;
  List<String> pokemonNames = [];
  List<String> names = [];
  Map<String, dynamic> tableDataFormatted = {};
  List<String> text = [];
  List<String> headers = [];
  Map<String, dynamic> mappedData = {};
  List<String> data = [];
  Map<String, dynamic> formattedOutput = {};
  List<String> pokemonLocations = [];
  List<String> listOfGames = [];
  List<String> listOfAreas = [];
  List<Widget> listOfWidgets = [];
  List<Map<String, dynamic>> listOfEvolution = [{}];

  @override
  void initState() {
    // TODO: implement initState
    _getPokemon().then((value) => setState(() => names = value));
    super.initState();
  }

  TextEditingController textController = TextEditingController();

  Future<List<String>> _getPokemon() async {
    const String baseUrl = 'https://pokemondb.net/pokedex/national';
    var r = await Requests.get(baseUrl);
    r.raiseForStatus();
    String body = r.content();

    var doc = parse(body);
    var aTags = doc.querySelectorAll('a');

    for (var i = 0; i < aTags.length; i++) {
      if (aTags[i].className == "ent-name") {
        pokemonNames.add(aTags[i].text);
      }
    }

    return pokemonNames;
  }

  Future<Map<String, dynamic>> _makeRequest(String pokemon) async {
    // https://pokemondb.net/pokedex/tyranitar
    const String baseUrl = 'https://pokemondb.net/pokedex/';
    var r = await Requests.get('$baseUrl$pokemon');
    r.raiseForStatus();
    String body = r.content();

    var doc = parse(body);
    var aTags = doc.querySelectorAll('a');
    var h2Tags = doc.querySelectorAll('h2');
    var tables = doc.querySelectorAll('table.vitals-table');
    var pokemonGames = doc.querySelectorAll('table.vitals-table');
    var evolution = doc.querySelectorAll('div.infocard-list-evo');

    for (var i = 0; i < aTags.length; i++) {
      pokemonImg = aTags
          .where((element) => element.attributes['href']!
              .contains('https://img.pokemondb.net/artwork/large/'))
          .toList();
    }

    var it = h2Tags.iterator;
    while (it.moveNext()) {
      if (text.contains(it.current.text)) {
        // Do nothing
        continue;
      } else {
        text.add(it.current.text);
      }
    }

    var tableIT = tables.iterator;
    while (tableIT.moveNext()) {
      doc = parse(tableIT.current.outerHtml);

      var tableHeaders = doc.querySelectorAll('th');
      var tableData = doc.querySelectorAll('td');

      var thIT = tableHeaders.iterator;
      while (thIT.moveNext()) {
        if (thIT.current.text.contains('National')) {
          var text = thIT.current.text.replaceAll('National №', 'National');
          headers.add(text);
        } else if (thIT.current.text.contains('Local')) {
          var text = thIT.current.text.replaceAll('Local №', 'Local');
          headers.add(text);
        } else {
          headers.add(thIT.current.text);
        }
      }

      var tdIT = tableData.iterator;
      while (tdIT.moveNext()) {
        data.add(tdIT.current.text.replaceAll('\n', ''));
      }

      for (var i = 0; i < tableHeaders.length; i++) {
        tableDataFormatted.addAll({headers[i]: data[i]});
      }
    }

    for (var i = 0; i < text.length; i++) {
      mappedData.addAll({text[i]: tableDataFormatted});
    }

    // Locations Logic
    var gameData = pokemonGames[5].outerHtml;
    var gameDataDoc = parse(gameData);
    var pokemonGameData = gameDataDoc.getElementsByTagName("th");
    var gameLocations = gameDataDoc.getElementsByTagName("td");
    for (var i = 0; i < gameLocations.length; i++) {
      // Add pokemon locations to the list
      pokemonLocations
          .add("${pokemonGameData[i].text}: ${gameLocations[i].text}");
    }

    for (var i = 0; i < evolution.length; i++) {
      var html = evolution[i].outerHtml;
      // print(html);
      var parsedHtml = parse(html);
      var listOfChildren = parsedHtml.children;

      var pokemonImg;
      var pokemonInfo;

      for (var i = 0; i < listOfChildren.length; i++) {
        var img = listOfChildren[i].getElementsByTagName('img');
        var pokemon = listOfChildren[i].getElementsByTagName('span');
        for (var i = 0; i < img.length; i++) {
          if (img[i]
              .attributes['src']!
              .contains('https://img.pokemondb.net/sprites/')) {
            pokemonImg = img[i].attributes['src'];
            pokemonInfo = pokemon[i].text;

            listOfEvolution.add({"img": pokemonImg, "info": pokemonInfo});
          }
        }
      }
    }

    formattedOutput.addAll({
      'image': pokemonImg[0].attributes['href'],
      'titles': text,
      'data': mappedData,
      'evolution': listOfEvolution,
      'locations': pokemonLocations,
    });

    return formattedOutput;
  }

  Widget getPokemonWidget() {
    for (var i = 0; i < pokemonLocations.length; i++) {
      listOfWidgets.add(Text(pokemonLocations[i]));
      listOfWidgets.add(const Padding(padding: EdgeInsets.all(5)));
    }

    return Column(children: listOfWidgets);
  }

  Widget getEggs() {
    return Column(
      children: <Widget>[
        Text(
          'Egg Groups: ${_html['data']['Base stats']['Egg Groups']}',
        ),
        const Padding(
          padding: EdgeInsets.all(5),
        ),
        Text(
          'Gender: ${_html['data']['Base stats']['Gender']}',
        ),
        const Padding(
          padding: EdgeInsets.all(5),
        ),
        Text(
          'Egg Cycles: ${_html['data']['Base stats']['Egg cycles']}',
        ),
        const Padding(
          padding: EdgeInsets.all(5),
        ),
      ],
    );
  }

  int getPokemonLength() {
    return pokemonLocations.length;
  }

  @override
  Widget build(BuildContext context) {
    return _html == null
        ? AdvancedSearch(
            // This is basically an Input Text Field

            searchItems: names,
            maxElementsToDisplay: 5,
            onItemTap: (index, text) {
              // user just found what he needs, now it's your turn to handle that
            },
            onSearchClear: () {
              // may be display the full list? or Nothing? it's your call
            },
            onSubmitted: (value, value2) {
              setState(() {
                pokemon = value;
              });

              _makeRequest(pokemon)
                  .then((value) => setState(() => _html = value));
            },
            onEditingProgress: (value, value2) {
              // user is trying to, searchItems: [] lookup something, may be you want to help him?
            },
          )
        : SizedBox(
            height: MediaQuery.of(context).size.height - 130,
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topCenter,
                      width: double.infinity,
                      child: Image.network(
                        '${_html['image']}',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      width: double.infinity,
                      child: Card(
                        elevation: 10,
                        margin: const EdgeInsets.all(5),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            children: <Widget>[
                              Text(
                                '${_html['titles'][0]}\n',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    'National No: ${_html['data']['Base stats']['National']}',
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Text(
                                    'Type: ${_html['data']['Base stats']['Type']}',
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Text(
                                    'Species: ${_html['data']['Base stats']['Species']}',
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Text(
                                    'Height: ${_html['data']['Base stats']['Height']}',
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Text(
                                    'Weight: ${_html['data']['Base stats']['Weight']}',
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Text(
                                    'Abilities: ${_html['data']['Base stats']['Abilities']}',
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      width: double.infinity,
                      child: Card(
                        margin: const EdgeInsets.all(5),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            children: <Widget>[
                              Text(
                                '${_html['titles'][1]}\n',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Column(
                                children: <Widget>[
                                  Text(
                                    'EV yield: ${_html['data']['Base stats']['EV yield']}',
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Text(
                                    'Catch rate: ${_html['data']['Base stats']['Catch rate']}',
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Text(
                                    'Base Friendship: ${_html['data']['Base stats']['Base Friendship']}',
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Text(
                                    'Base Exp.: ${_html['data']['Base stats']['Base Exp.']}',
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Text(
                                    'Growth Rate: ${_html['data']['Base stats']['Growth Rate']}',
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      width: double.infinity,
                      child: Card(
                        margin: const EdgeInsets.all(5),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            children: <Widget>[
                              Text(
                                '${_html['titles'][2]}\n',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              getEggs(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      width: double.infinity,
                      child: Card(
                        margin: const EdgeInsets.all(5),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            children: <Widget>[
                              Text(
                                '${_html['titles'][3]}\n',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      width: double.infinity,
                      child: Card(
                        margin: const EdgeInsets.all(5),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            children: <Widget>[
                              Text(
                                '${_html['titles'][5]}\n',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Column(
                                children: <Widget>[
                                  Image.network(_html['evolution'][0]['img']),
                                  const Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Text(
                                    '${_html['evolution'][0]['info']}',
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Image.network(_html['evolution'][1]['img']),
                                  const Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Text(
                                    '${_html['evolution'][1]['info']}',
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Image.network(_html['evolution'][2]['img']),
                                  const Padding(
                                    padding: EdgeInsets.all(5),
                                  ),
                                  Text(
                                    '${_html['evolution'][2]['info']}'
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      width: double.infinity,
                      child: Card(
                        margin: const EdgeInsets.all(5),
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            children: <Widget>[
                              Text(
                                '${_html['titles'][10]}\n',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              // Text('${_html['locations'][3]}'),
                              getPokemonWidget(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
  }
}
