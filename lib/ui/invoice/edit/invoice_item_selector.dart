import 'package:invoiceninja/redux/app/app_state.dart';
import 'package:flutter/material.dart';
import 'package:invoiceninja/data/models/models.dart';
import 'package:invoiceninja/utils/localization.dart';


class InvoiceItemSelector extends StatefulWidget {
  InvoiceItemSelector(this.state);

  final AppState state;

  @override
  _InvoiceItemSelectorState createState() => new _InvoiceItemSelectorState();
}

class _InvoiceItemSelectorState extends State<InvoiceItemSelector> {
  String _filter;
  List<int> _selectedIds = [];

  final _textController = TextEditingController();
  //EntityType _selectedEntityType = EntityType.product;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalization.of(context);

    _headerRow() {
      return Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Icon(Icons.search),
            /*
                  child: DropdownButton(
                    value: 'Products',
                    onChanged: (value) {
                      //
                    },
                    items: <String>['Products', 'Tasks', 'Expenses']
                        .map((String value) {
                      return new DropdownMenuItem<String>(
                        value: value,
                        child: new Text(value),
                      );
                    }).toList(),
                  ),
                  */
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              onChanged: (value) {
                setState(() {
                  _filter = value;
                });
              },
              autofocus: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: localization.filter,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  if (_textController.text.length > 0) {
                    setState(() {
                      _filter = _textController.text = '';
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              _selectedIds.length > 0
                  ? IconButton(
                icon: Icon(Icons.check),
                onPressed: () => Navigator.pop(context),
              )
                  : Container(),
            ],
          )
        ],
      );
    }

    _entityList() {
      var localization = AppLocalization.of(context);
      var state = widget.state.selectedCompanyState.productState;

      var matches = state.list
          .where((entityId) => state.map[entityId].matchesSearch(_filter))
          .toList();

      return ListView.builder(
        shrinkWrap: true,
        itemCount: matches.length,
        itemBuilder: (BuildContext context, int index) {
          int entityId = matches[index];
          var entity = state.map[entityId];
          var subtitle = null;
          var matchField = entity.matchesSearchField(_filter);
          if (matchField != null) {
            var field = localization.lookup(matchField);
            var value = entity.matchesSearchValue(_filter);
            subtitle = '$field: $value';
          }
          return ListTile(
            dense: true,
            leading: Checkbox(
              value: _selectedIds.contains(entityId),
              onChanged: (bool value) {
                setState(() {
                  if (value) {
                    _selectedIds.add(entityId);
                  } else {
                    _selectedIds.remove(entityId);
                  }
                });
              },
            ),
            title: Text(entity.listDisplayName),
            subtitle: subtitle != null ? Text(subtitle) : null,
            onTap: () {
              if (_selectedIds.length > 0) {
                setState(() {
                  if (_selectedIds.contains(entityId)) {
                    _selectedIds.remove(entityId);
                  } else {
                    _selectedIds.add(entityId);
                  }
                });
              } else {
                Navigator.pop(context);
              }
            },
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Material(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              _headerRow(),
              _entityList(),
            ]),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}