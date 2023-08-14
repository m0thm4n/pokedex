import 'package:flutter/material.dart';

import 'package:requests/requests.dart';
import 'package:html/parser.dart' show parse;

class News extends StatefulWidget {
  const News({Key? key}) : super(key: key);

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  var raids;

  @override
  void initState() {
    super.initState();
    setState(() {
      raids = loadCards();
    });
  }

  Future<List<Map<String, String>>> loadCards() async {
    List<Map<String, String>> raids = [{}];
    List<String> moreDetails = [];

    var r = await Requests.get(
        'https://www.serebii.net/scarletviolet/teraraidbattleevents.shtml');
    r.raiseForStatus();
    String body = r.content();

    var doc = parse(body);

    var title = doc.querySelectorAll('td.fooleft');
    var description = doc.querySelectorAll('td.foocontent');

    for (var i = 0; i < title.length; i++) {
      raids.add({'title': title[i].text, 'description': description[i].text});
    }

    return raids;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: raids,
        builder: (context, AsyncSnapshot<List<Map<String, String>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Column(
                children: <Widget>[
                  Text(
                    snapshot.error!.toString(),
                  ),
                ],
              );
            }
            // return Center(child: Text("Loading Data..."),);

            return SizedBox(
              height: MediaQuery.of(context).size.height - 60,
              child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    if (snapshot.data?[index]['title'] != null &&
                        snapshot.data![index]['title'] !=
                            snapshot.data![index]['description']) {
                      return Card(
                          elevation: 5,
                          color: Theme.of(context).colorScheme.onBackground,
                          child: Column(
                            children: <Widget>[
                              Center(
                                child: Text(
                                  '${snapshot.data![index]['title']}',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(5),
                              ),
                              Center(
                                child: Text(
                                  '${snapshot.data![index]['description']}',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(5),
                              ),
                            ],
                          ));
                    }

                    return const SizedBox.shrink();
                  }),
            );
          } else if (snapshot.hasData) {
            var data = snapshot.data;
            return Center(
              child: Text("Data loaded... $data"),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
