
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constant/Constant.dart';
import '../window_config/window_buttons.dart';
import '../window_config/windows_adapter.dart';

class SearchPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    GlobalKey inputKey = GlobalKey();

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: DragToMoveArea(
            child: AppBar(actions: const [WindowButtons()]),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              width: 430,
              child: Image(
                image: AssetImage(Constant.logoImagePath),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 450,
                  child: TextField(
                    key: inputKey,
                    // controller: searchController.controller,
                    // key: inputKey,
                    decoration: const InputDecoration(
                      hintText: '请输入B站视频链接',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     shape: const RoundedRectangleBorder(
                //       borderRadius: BorderRadius.zero,
                //     ),
                //     padding: const EdgeInsets.symmetric(
                //         horizontal: 30, vertical: 20),
                //   ),
                  // onPressed: print("hello"),
                  // searchController.isLoading.isFalse
                  //     ? () {
                  //   searchController.handleSearch(
                  //       searchController.controller.text,
                  //       context,
                  //       inputKey);
                  // }
                  //     : null,
                //   child: const Text('搜索'),
                // )
              ],
            )
          ],
        ),
      ),
    );
  }

}