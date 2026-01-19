import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/my_app_state.dart';


class FavoritesPage extends StatelessWidget{


  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    var theme = Theme.of(context);

    if(favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,   // 向左对齐
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),

        Expanded(
          child: GridView(   // GridView 可滚动无限高，需要使用 Expanded 包括
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            children: [
              for (var pair in favorites)
                ListTile(
                  leading: IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      semanticLabel: 'Delete',
                    ),
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      appState.removeFavorite(pair);
                    },
                  ),
                  title: Text("${pair.first} ${pair.second}"),
                ),
            ],
          ),
        ),
      ],
    );
    // return Scaffold(
    //   body: ListView(
    //     children: [
    //       for(var item in favorites)
    //         ListTile(
    //           title: Text( "${item.first} ${item.second}"),
    //         ),
    //     ],
    //   ),
    // );
  }
}
