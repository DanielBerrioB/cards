import "package:flutter/material.dart";

class CardItem extends StatelessWidget {
  const CardItem(
      {Key key,
      @required this.animation,
      this.onTap,
      @required this.element,
      @required this.index,
      this.selected: false})
      : assert(animation != null),
        assert(element != null),
        assert(selected != null),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback onTap;
  final bool selected;
  final InsideItemCard element;
  final int index;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.display1;
    if (selected)
      textStyle = textStyle.copyWith(
          color: Colors.lightGreenAccent[400], fontSize: 18.0);
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizeTransition(
        axis: Axis.vertical,
        sizeFactor: animation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            height: 110.0,
            child: Card(
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Colors.primaries[index % Colors.primaries.length],
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      bottom: 70.0,
                      left: 10.0,
                      right: 10.0,
                    ),
                    child: Text(
                      "${element.date} - ${element.hour}",
                      style: TextStyle(fontSize: 10.5),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2 + 20,
                    child: Center(
                      child: Text(
                        '${element.text}',
                        overflow: TextOverflow.fade,
                        style: selected ? textStyle : TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InsideItemCard {
  InsideItemCard(this.date, this.hour, this.text);

  final String date;
  final String hour;
  final String text;

  getDate() => this.date;

  getHour() => this.hour;

  getText() => this.text;
}
