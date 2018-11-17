// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import './category.dart';

final _backgroundColor = Colors.green[100];

/// Category Route (screen).
///
/// This is the 'home' screen of the Unit Converter. It shows a header and
/// a list of [Categories].
///
/// While it is named CategoryRoute, a more apt name would be CategoryScreen,
/// because it is responsible for the UI at the route's destination.
class CategoryRoute extends StatelessWidget {
  const CategoryRoute();

  static const _categoryNames = <String>[
    'Length',
    'Area',
    'Volume',
    'Mass',
    'Time',
    'Digital Storage',
    'Energy',
    'Currency',
  ];

  static const _baseColors = <Color>[
    Colors.teal,
    Colors.orange,
    Colors.pinkAccent,
    Colors.blueAccent,
    Colors.yellow,
    Colors.greenAccent,
    Colors.purpleAccent,
    Colors.red,
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: Create a list of the eight Categories, using the names and colors
    // from above. Use a placeholder icon, such as `Icons.cake` for each
    // Category. We'll add custom icons later.

    // TODO: Create a list view of the Categories
    final listView = Container(
      child: ListView.builder(
        itemBuilder: (_, int i) => Category(
              color: _baseColors[i],
              iconLocation: Icons.cake,
              name: _categoryNames[i],
            ),
        itemCount: _categoryNames.length,
      ),
    );

    final appBar = AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      title: Center(
          child: Text(
        "Unit converter",
        style: TextStyle(fontSize: 30.0, color: Colors.black),
      )),
    );

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: appBar,
      body: listView,
    );
  }
}
