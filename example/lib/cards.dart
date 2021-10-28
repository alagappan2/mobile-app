import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef RemovedItemBuilder<T> = Widget Function(
    T item, BuildContext context, Animation<double> animation);

/// Keeps a Dart [List] in sync with an [AnimatedList].
///
/// The [insert] and [removeAt] methods apply to both the internal list and
/// the animated list that belongs to [listKey].
///
/// This class only exposes as much of the Dart List API as is needed by the
/// sample app. More list methods are easily added, however methods that
/// mutate the list must make the same changes to the animated list in terms
/// of [AnimatedListState.insertItem] and [AnimatedList.removeItem].
class ListModel<E> {
  ListModel({
    required this.listKey,
    required this.removedItemBuilder,
    Iterable<E>? initialItems,
  }) : _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<AnimatedListState> listKey;
  final RemovedItemBuilder<E> removedItemBuilder;
  final List<E> _items;
  final Map<int, String> textMap = new Map();

  AnimatedListState? get _animatedList => listKey.currentState;

  void insert(int index, E item, String text) {
    _items.insert(index, item);
    textMap.putIfAbsent(index, () => text);
    _animatedList!.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      textMap.remove(index);
      _animatedList!.removeItem(
        index,
            (BuildContext context, Animation<double> animation) {
          return removedItemBuilder(removedItem, context, animation);
        },
      );
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);

  String getText(E item) {
    for (MapEntry e in textMap.entries) {
      if (e.key == item) {
        return e.value;
      }
    }
    return "";
  }
}
/// Displays its integer item as 'item N' on a Card whose color is based on
/// the item's value.
///
/// The text is displayed in bright green if [selected] is
/// true. This widget's height is based on the [animation] parameter, it
/// varies from 0 to 128 as the animation varies from 0.0 to 1.0.
class CardItem extends StatelessWidget {
  const CardItem({
    Key? key,
    this.onTap,
    this.selected = false,
    required this.animation,
    required this.item,
    required this.text,
  })  : assert(item >= 0),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback? onTap;
  final int item;
  final bool selected;
  final String text;

  String getMap(int input) {
    var numMap = Map();
    numMap[1] = "1";
    numMap[2] = "2";
    numMap[3] = "3";
    numMap[4] = "4";

    //var now = DateTime.now();
    final dateTime = DateTime.now();
    for (MapEntry e in numMap.entries) {
      if (e.key == item) {
        return "${dateTime.hour}:${dateTime.minute} Car Parked in 1st floor, "+ e.value + " Parking slots";
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.bodyText1!;
    if (selected) {
      textStyle = textStyle.copyWith(color: Colors.lightGreenAccent[400]);
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            height: 80.0,
            child: Card(
              color: Colors.lightBlue,//Colors.primaries[item % Colors.primaries.length],
              child: Center(
                child: Text(getMap(item),
                    style: textStyle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}