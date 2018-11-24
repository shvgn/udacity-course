// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'unit.dart';

const _padding = EdgeInsets.all(16.0);

/// [ConverterRoute] where users can input amounts to convert in one [Unit]
/// and retrieve the conversion in another [Unit] for a specific [Category].
///
/// While it is named ConverterRoute, a more apt name would be ConverterScreen,
/// because it is responsible for the UI at the route's destination.
class ConverterRoute extends StatefulWidget {
  /// This [Category]'s name.
  final String name;

  /// Color for this [Category].
  final Color color;

  /// Units for this [Category].
  final List<Unit> units;

  /// This [ConverterRoute] requires the name, color, and units to not be null.
  const ConverterRoute({
    @required this.name,
    @required this.color,
    @required this.units,
  })  : assert(name != null),
        assert(color != null),
        assert(units != null);

  @override
  _ConverterRouteState createState() => _ConverterRouteState();
}

class _ConverterRouteState extends State<ConverterRoute> {
  Unit _fromUnit;
  Unit _toUnit;
  String _result;
  String _input;
  bool _validationError = false;

  TextEditingController _inputController;

  RegExp matchCommas = RegExp(r',');
  RegExp matchSpaces = RegExp('\s+');

  @override
  initState() {
    super.initState();
    setState(() {
      _inputController = TextEditingController(text: '1');
    });
    _recalc('1', widget.units[0], widget.units[1]);
  }

  String _recognize(String inputValue) {
    var trimmed = inputValue.trim();
    if (trimmed == '') {
      return '0';
    }
    return trimmed.replaceAll(matchSpaces, '').replaceFirst(matchCommas, '.');
  }

  bool _hasError(String inputValue) => null == double.tryParse(inputValue);

  void _recalc(String inputValue, Unit from, Unit to) {
    _input = _recognize(inputValue);
    print('recognized $_input');

    setState(() {
      _validationError = _hasError(_input);
      _fromUnit = from;
      _toUnit = to;
      _result = _validationError ? _result : _convert(_input, from, to);
    });
  }

  String _convert(String value, Unit from, Unit to) {
    final factor = _toUnit.conversion / _fromUnit.conversion;
    final inputNum = double.tryParse(value.trim()) ?? 0.0;
    return _format(factor * inputNum);
  }

  /// Clean up conversion; trim trailing zeros, e.g. 5.500 -> 5.5, 10.0 -> 10
  String _format(double conversion) {
    var outputNum = conversion.toStringAsPrecision(7);
    if (outputNum.contains('.') && outputNum.endsWith('0')) {
      var i = outputNum.length - 1;
      while (outputNum[i] == '0') {
        i -= 1;
      }
      outputNum = outputNum.substring(0, i + 1);
    }
    if (outputNum.endsWith('.')) {
      return outputNum.substring(0, outputNum.length - 1);
    }
    return outputNum;
  }

  @override
  Widget build(BuildContext context) {
    final unitItems = widget.units
        .map(
          (Unit unit) => DropdownMenuItem<Unit>(
                value: unit,
                child: Padding(
                  padding: EdgeInsets.only(left: _padding.left / 2),
                  child: Text(
                    unit.name,
//                    style: Theme.of(context).textTheme.body2,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
        )
        .toList();

    final fromUnitDropDown = DropdownButtonHideUnderline(
      child: DropdownButton<Unit>(
        value: _fromUnit,
        items: unitItems,
        onChanged: (Unit from) => _recalc(_input, from, _toUnit),
      ),
    );

    final toUnitDropDown = DropdownButtonHideUnderline(
      child: DropdownButton<Unit>(
        value: _toUnit,
        items: unitItems,
        onChanged: (Unit to) => _recalc(_input, _fromUnit, to),
      ),
    );

    final wrapInBorder = (Widget w, EdgeInsets padding) => Container(
          decoration: ShapeDecoration(
            shape: Border.all(
              width: 1,
              color: Theme.of(context).primaryColor,
            ),
          ),
          child: Padding(
            padding: padding,
            child: w,
          ),
        );

    final dropDownPadding = EdgeInsets.only(
      top: _padding.top / 2,
    );

    final inputTextField = TextField(
      controller: _inputController,
      autofocus: true,
      autocorrect: false,
      keyboardType: TextInputType.number,
      style: Theme.of(context).textTheme.display1,
      decoration: InputDecoration(
        labelText: 'Input',
        labelStyle: Theme.of(context).textTheme.display1,
        errorText: _validationError ? 'Invalid number entered' : null,
        // while focused, borders will be wider
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      onChanged: (value) => _recalc(value, _fromUnit, _toUnit),
    );

    final inputGroup = Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          inputTextField,
          Padding(
            padding: dropDownPadding,
            child: wrapInBorder(fromUnitDropDown, _padding / 2),
          ),
        ],
      ),
    );

    final outputGroup = Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InputDecorator(
            child: Text(
              _result,
              style: Theme.of(context).textTheme.display1,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.0,
                  )),
              labelText: 'Output',
              labelStyle: Theme.of(context).textTheme.display1,
            ),
          ),
          Padding(
            padding: dropDownPadding,
            child: wrapInBorder(toUnitDropDown, _padding / 2),
          )
        ],
      ),
    );

    final arrowsIcon = RotatedBox(
        quarterTurns: 1,
        child: Icon(
          Icons.compare_arrows,
          size: 40,
        ));

    return Column(
      children: <Widget>[
        inputGroup,
        arrowsIcon,
        outputGroup,
      ],
    );
  }
}
