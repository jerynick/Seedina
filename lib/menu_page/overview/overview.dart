// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:seedina/menu_page/overview/editplant.dart";
import "package:seedina/provider/rtdb_handler.dart";
import "package:seedina/utils/rewidgets/global/mynav.dart";
import "package:seedina/utils/rewidgets/contentbox/for_monitoring/infocolumn.dart";
import "package:seedina/utils/rewidgets/contentbox/for_monitoring/monitoringbox.dart";
import "package:seedina/utils/style/gcolor.dart";

// Define the OverviewScreen class as a StatefulWidget
class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

// Define the state for OverviewScreen
class _OverviewScreenState extends State<OverviewScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user from AuthService
    final User? user = FirebaseAuth.instance.currentUser;

    // Get the display name of the user or default to 'Farms'
    final String displayName = user?.displayName ?? 'Farms';

    // Get various plant monitoring data from the HandlingProvider
    double ecAir = context.watch<HandlingProvider>().ecAir;
    int tdsAir = context.watch<HandlingProvider>().tdsAir;
    double tinggiAir = context.watch<HandlingProvider>().tinggiAir;
    double waktuSiram = context.watch<HandlingProvider>().idealWaktuSiram;
    double idealSuhu = context.watch<HandlingProvider>().idealSuhu;
    double idealTds = context.watch<HandlingProvider>().idealNutrisi;
    double idealEC = context.watch<HandlingProvider>().idealEC;
    
    String title = context.watch<HandlingProvider>().namaTanaman;
    String latin = context.watch<HandlingProvider>().namaLatin;
    String thumbnail = context.watch<HandlingProvider>().gambar;

    return Scaffold(
      backgroundColor: GColors.myHijau,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 200,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height - 128,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(top: 120),
                  child: Column(
                    children: [
                      Container(
                        //height: 214,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: GColors.shadowColor,
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  offset: Offset(0, 4))
                            ]),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.black,
                                    radius: 24,
                                    backgroundImage:
                                        AssetImage('assets/myicon/profile.png'),
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          'Hai, $displayName',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                      Text(
                                        title,
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: 12,),
                              Text(
                                'Monitoring Sistem Aeroponik',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: 12,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  MonitoringBox(title: 'EC Air', value: ecAir.toStringAsFixed(1), textTitleSize: 12, textValueSize: 36, unit: 'mS/cm'), // Display EC value
                                  MonitoringBox(title: 'Nutrisi Air', value: '$tdsAir', textTitleSize: 12,textValueSize: 32, unit: 'ppm'), // Display TDS value
                                  MonitoringBox(title: 'Tinggi Air', value: '$tinggiAir', textTitleSize: 12,textValueSize: 32, unit: 'cm') // Display water level
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Informasi Tanaman Anda',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700, color: GColors.myBiru),
                          ),
                          SizedBox(
                            width: 98,
                            height: 32,
                            child: ElevatedButton(
                                onPressed: (){GNav.slideNavStateless(context, EditPlants());}, // Navigate to EditPlants screen
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.white,
                                  foregroundColor: GColors.myBiru,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: GColors.myBiru, width: 2)
                                  )
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 20,),
                                    SizedBox(width: 4,),
                                    Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),) // Edit button
                                  ],
                                )
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      GestureDetector(
                        onDoubleTap: (){GNav.slideNavStateless(context, EditPlants());}, // Navigate to EditPlants screen on double tap
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: GColors.shadowColor,
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                      offset: Offset(0, 2))
                                ]),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: Image.asset(
                                          '$thumbnail'
                                        ),
                                      ),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title, // Display plant title
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          Text(
                                            latin, // Display plant latin name
                                            style: TextStyle(
                                                fontSize: 8,
                                                fontStyle: FontStyle.italic),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  Divider(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            InfoColumn(
                                              title: 'Waktu Siram',
                                              fontSize: 16,
                                              space: 8,
                                              value: '$waktuSiram Menit' // Display watering time
                                            ),
                                            //VerticalDivider(color: Colors.grey, thickness: 1, width: 20,),
                                            InfoColumn(
                                              title: 'Suhu Ideal',
                                              fontSize: 16,
                                              space: 8,
                                              value: '$idealSuhu °C ' // Display ideal temperature
                                            ),
                                          ],
                                        ),
                                        Divider(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            InfoColumn(
                                              title: 'EC Ideal',
                                              fontSize: 20,
                                              space: 8,
                                              value: '$idealEC' // Display ideal pH
                                            ),
                                            //VerticalDivider(color: Colors.grey, thickness: 1, width: 20,),
                                            InfoColumn(
                                              title: 'Nutrisi Ideal',
                                              fontSize: 16,
                                              space: 8,
                                              value: '$idealTds ppm' // Display ideal nutrients
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                ],
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
