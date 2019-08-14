import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flight_ticket/CustomShapeClipper.dart';
import 'package:flight_ticket/main.dart';
import 'package:flutter/material.dart';


final Color discountBackground = Color(0xFFFFE08D);
final Color flightBorderColor = Color(0xFFE6E6E6);
final Color chipBackgroundColor = Color(0xFFF6F6F6);

class InheritedFlightListing extends InheritedWidget{
  
  final String fromLocation, toLocation;

  InheritedFlightListing({this.fromLocation, this.toLocation, Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static InheritedFlightListing of(BuildContext context) =>
    context.inheritFromWidgetOfExactType(InheritedFlightListing);
}

class FlightListingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0.0,
        title: Text("Search Result",),
        centerTitle: true,
        leading: InkWell(
          child: Icon(Icons.arrow_back),
          onTap: () {
            Navigator.pop(context);
          },
        )
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            FlightListTopPart(),
            SizedBox(height: 20.0),
            FlightListingBottomPart(),
          ],
        ),
      ),
    );
  }
}

class FlightListTopPart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ClipPath(
          clipper: CustomShapeClipper(),
          child: Container(
            decoration: BoxDecoration(gradient: LinearGradient(
              colors: [firstColor, secondColor])
              ),
            height: 160.0,
          ),
        ),

        Column(
          children: <Widget>[
            SizedBox(height: 20.0,),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular((20.0)))),
              margin: EdgeInsets.symmetric(horizontal: 22.0),
              elevation: 10.0,
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(//untuk nama panjang, turuun ke bwh
                      flex: 5, //kotak takkan kecikkan. sama dgn saiz asal
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${InheritedFlightListing.of(context).fromLocation}', 
                            style: TextStyle(fontSize: 16.0),),
                          Divider(color: Colors.grey, height: 20.0,),
                          Text(
                            '${InheritedFlightListing.of(context).toLocation}', 
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                    Spacer(),
                    Expanded(
                      child: Icon(Icons.import_export, color: Colors.black, size: 34.0,)),
                  ]
                )
              ),
            ),
          ],
        )
      ],
    );
  }
}

class FlightListingBottomPart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0,),
            child: Text(
              "Best Deals for Next 6 Months",
              style: dropDownMenuItemStyle,
            ),
          ),
          SizedBox(height: 10.0,),
          StreamBuilder(
            stream: Firestore.instance.collection('deals').snapshots(),
            builder: (context, snapshot) {
              return !snapshot.hasData 
              ? Center(child: CircularProgressIndicator())
              : _buildDealsList(context, snapshot.data.documents);
            },
          )
        ],
      ),
    );
  }
}

Widget _buildDealsList(BuildContext context, List<DocumentSnapshot> snapshots) {
  return ListView.builder(
    
    shrinkWrap: true, //biasa dlm list widget function tak keluar. kena buat true
    itemCount: snapshots.length,
    physics: ClampingScrollPhysics(), //gunakan physic clamp bila scroll tak jadi
    itemBuilder: (context, index) {
      return FlightCard(flightDetails: FlightDetails.fromSnapshot(snapshots[index]),);
    }
    ,);
}

class FlightDetails {
  final String airlines, date, discount, rating;
  final int oldPrice, newPrice;

  FlightDetails.fromMap(Map<String, dynamic> map)
      : assert(map['airlines'] != null), // assert = dont want data to be null
        assert(map['date'] != null),
        assert(map['discount'] != null),
        assert(map['rating'] != null),
        airlines = map['airlines'],
        date = map['date'],
        discount = map['discount'],
        oldPrice = map['oldPrice'],
        newPrice = map['newPrice'],
        rating = map['rating'];

  FlightDetails.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data);
}

class FlightCard extends StatelessWidget {

  final FlightDetails flightDetails;

  FlightCard({this.flightDetails});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0),),
            border: Border.all(color: flightBorderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      'RM ${flightDetails.newPrice}', 
                      style: 
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0,),
                    ),
                    SizedBox(width: 4.0,),
                    Text(
                      '(RM ${flightDetails.oldPrice})',
                      style: 
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, decoration: TextDecoration.lineThrough, color: Colors.grey),
                        ),
                  ],
                ),
                Wrap(
                  spacing: 15.0,
                  runSpacing: -8.0,
                  children: <Widget>[
                    FlighDetailChip(Icons.calendar_today, '${flightDetails.date}'),
                    FlighDetailChip(Icons.flight_takeoff, '${flightDetails.airlines}'),
                    FlighDetailChip(Icons.star, '${flightDetails.rating}'),
                  ],
                )
              ],  
            ),
          ),
          ),
          Positioned(
            top: 10.0,
            right: 0.0,
            child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text('${flightDetails.discount}%', style: TextStyle(color: appTheme.primaryColor, fontSize: 14.0),),
            decoration: BoxDecoration(
              color: discountBackground, 
              borderRadius: BorderRadius.all(
                Radius.circular(10.0)
              )
              ),
            ),
          )
        ],
      ),
    );
  }
}

class FlighDetailChip extends StatelessWidget {

  final IconData iconData;
  final String label;

  FlighDetailChip(this.iconData, this.label);

  @override
  Widget build(BuildContext context) {
    return RawChip(
      label: Text(label),
      labelStyle: TextStyle(color: Colors.black, fontSize: 14.0),
      backgroundColor: chipBackgroundColor,
      avatar: Icon(iconData, size: 16.0,),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0),),
      ),
    );
  }
}