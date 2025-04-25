import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:parkhub/screens/profile_screen.dart';
import 'package:parkhub/screens/booking_screen.dart';
import 'package:parkhub/screens/viewdetails_screen.dart';
import 'package:parkhub/services/geolocator_service.dart';
import 'package:google_maps_helper/google_maps_helper.dart';
import 'package:parkhub/screens/chatbot_screen.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  HomepageScreenState createState() => HomepageScreenState();
}

class HomepageScreenState extends State<HomepageScreen> {
  late GoogleMapController mapController;
  final GeolocatorService _geoService = GeolocatorService();
  GmhAddressData? _destinationAddress;
  Marker? _destinationMarker;
  String _userName = 'User';
  LatLng _initialLocation = LatLng(2.9995, 101.7056);
  Marker? _userMarker;
  String _mapStyle = '';
  bool _isDarkMode = false;
  final FocusNode _destinationFocusNode = FocusNode();
  Set<Polyline> _polylines = {};
  String _distanceText = '';
  String _durationText = '';
  Set<Marker> _parkingMarkers = {};
  Map<String, String> modeDurations = {
    "Driving": "",
    "Biking": "",
    "Transit": "",
  };

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _setCurrentLocation();
    _loadMapStyle(_isDarkMode);
  }

  //Firebase

  void _fetchUserName() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userName = user?.displayName ?? 'User';
    });
  }

  //Profile

  Future<void> _loadMapStyle(bool darkMode) async {
    String style = await DefaultAssetBundle.of(context).loadString(
      darkMode
          ? 'assets/images/map_style_dark.json'
          : 'assets/images/map_style_light.json',
    );
    setState(() {
      _mapStyle = style;
    });
    // ignore: deprecated_member_use
    mapController.setMapStyle(_mapStyle);
  }

  Future<void> _loadNearbyParkingSpots(LatLng userLocation) async {
    final apiKey =
        'apikey'; // Replace with your real key
    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=parking+in+Selangor+Malaysia&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['results'] != null) {
        final List<dynamic> places = data['results'];

        final BitmapDescriptor customIcon =
            await BitmapDescriptor.fromAssetImage(
              const ImageConfiguration(size: Size(48, 48)),
              'assets/images/parking_icon2.png',
            );

        final Set<Marker> markers =
            places
                .map((place) {
                  final location = place['geometry']?['location'];
                  if (location == null) return null;

                  final lat = location['lat'];
                  final lng = location['lng'];
                  final name = place['name'];
                  final placeId = place['place_id'];
                  final parkingLatLng = LatLng(lat, lng);

                  return Marker(
                    markerId: MarkerId('${placeId}_$name'),
                    position: parkingLatLng,
                    infoWindow: InfoWindow(title: name),
                    icon: customIcon,
                    onTap: () {
                      _getRoutePolyline(userLocation, parkingLatLng);
                    },
                  );
                })
                .whereType<Marker>()
                .toSet(); // remove nulls

        setState(() {
          _parkingMarkers = markers;
        });

        if (markers.isEmpty) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No nearby parking spots found.')),
          );
        }
      }
    } else {
      debugPrint('API Error: ${response.body}');
    }
  }

  //Set Current Location
  Future<void> _setCurrentLocation() async {
    try {
      Position position = await _geoService.determinePosition();
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _initialLocation = currentLatLng;
        _userMarker = Marker(
          markerId: const MarkerId('user_location'),
          position: currentLatLng,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        );
      });
      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng, 16.8),
      );
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  //Polyline
  Future<void> _getRoutePolyline(LatLng start, LatLng end) async {
    const String apiKey = 'apikey';
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if ((data['routes'] as List).isNotEmpty) {
        final route = data['routes'][0];
        final points = route['overview_polyline']['points'];
        final polylinePoints = PolylinePoints().decodePolyline(points);
        final polylineCoordinates =
            polylinePoints.map((e) => LatLng(e.latitude, e.longitude)).toList();

        final Polyline routePolyline = Polyline(
          polylineId: const PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.blueAccent,
          width: 5,
        );

        final legs = route['legs'][0];
        final distance = legs['distance']['text'];
        final duration = legs['duration']['text'];

        setState(() {
          _polylines = {routePolyline};
          _distanceText = distance;
          _durationText = duration;
        });

        /// Center camera on mid-point of route
        final midLat = (start.latitude + end.latitude) / 2;
        final midLng = (start.longitude + end.longitude) / 2;

        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(midLat, midLng),
            14.0, // Adjust zoom level if needed
          ),
        );
      }
    } else {
      debugPrint("Failed to fetch route: ${response.reasonPhrase}");
    }
  }

  //Searchbox
  Widget _buildSearchBox({
    required String label,
    required GmhAddressData? selectedValue,
    required void Function(GmhAddressData?) onSelected,
    required FocusNode focusNode,
    VoidCallback? onVoicePressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 5,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 10),
              Expanded(
                child: Focus(
                  focusNode: focusNode,
                  child: GmhSearchField(
                    selectedValue: selectedValue,
                    onSelected: onSelected,
                    searchParams: const GmhSearchParams(
                      apiKey: 'AIzaSyA2spmVRxTetmqyb-HQOewSmUBgpFbBTMo',
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.mic, color: Colors.grey),
                onPressed:
                    onVoicePressed ??
                    () {
                      // Add your voice search logic here
                      debugPrint('Voice icon tapped');
                    },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    Color iconColor,
    Color? bgColor,
    Color? textColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor ?? Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialLocation,
                zoom: 16.8,
              ),
              zoomGesturesEnabled: true,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: {
                if (_userMarker != null) _userMarker!,
                if (_destinationMarker != null) _destinationMarker!,
                ..._parkingMarkers, // spread the set
              },
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                // Ignore deprecated usage of setMapStyle
                if (_mapStyle.isNotEmpty) {
                  // ignore: deprecated_member_use
                  mapController.setMapStyle(_mapStyle);
                }

                final location = _userMarker?.position ?? _initialLocation;
                _loadNearbyParkingSpots(location);
              },
              onTap: (LatLng pos) async {
                final data = await GmhService().getAddress(
                  lat: pos.latitude,
                  lng: pos.longitude,
                  apiKey: 'apikey',
                );

                if (data != null) {
                  setState(() {
                    if (_destinationFocusNode.hasFocus) {
                      _destinationAddress = data;
                      _destinationMarker = Marker(
                        markerId: const MarkerId('destination_location'),
                        position: pos,
                        infoWindow: InfoWindow(title: data.address),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                        draggable: true,
                      );
                      _destinationFocusNode.unfocus();
                    }
                  });

                  if (_userMarker != null) {
                    _getRoutePolyline(_userMarker!.position, pos);
                  }

                  mapController.animateCamera(
                    CameraUpdate.newLatLngZoom(pos, 16.5),
                  );
                } else {
                  // Handle case when the address data is null (e.g., show error message)
                }
              },
            ),
          ),

          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(
                          'assets/images/kirthiraj.jpg',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          "Find your parking spots",
                          style: TextStyle(
                            color:
                                _isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                      tooltip:
                          _isDarkMode
                              ? 'Switch to Light Mode'
                              : 'Switch to Dark Mode',
                      onPressed: () {
                        setState(() {
                          _isDarkMode = !_isDarkMode;
                        });
                        _loadMapStyle(_isDarkMode);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: _buildSearchBox(
                    label: "Parking Location",
                    selectedValue: _destinationAddress,
                    focusNode: _destinationFocusNode,
                    onSelected: (data) {
                      if (data != null) {
                        final destLatLng = LatLng(data.lat, data.lng);
                        setState(() {
                          _destinationAddress = data;
                          _destinationMarker = Marker(
                            markerId: const MarkerId('destination_location'),
                            position: destLatLng,
                            infoWindow: InfoWindow(title: data.address),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRed,
                            ),
                            draggable: true,
                          );
                        });

                        if (_userMarker != null) {
                          _getRoutePolyline(_userMarker!.position, destLatLng);
                        }

                        mapController.animateCamera(
                          CameraUpdate.newLatLngZoom(destLatLng, 16.5),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_distanceText.isNotEmpty && _durationText.isNotEmpty)
            DraggableScrollableSheet(
              initialChildSize: 0.28,
              minChildSize: 0.2,
              maxChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      /// 📸 Enhanced Place Info Section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: Duration(
                                    milliseconds: 300,
                                  ),
                                  pageBuilder:
                                      (_, __, ___) => Scaffold(
                                        backgroundColor: Colors.black,
                                        body: Center(
                                          child: Hero(
                                            tag: 'place_image',
                                            child: Image.asset(
                                              'assets/images/ioiparking1.jpeg',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: 'place_image',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/images/ioiparkingP1.jpeg',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'IOI City Mall Parking',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.info_outline, size: 20),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => ViewDetailScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  'Lebuh IRC, IOI Resort City, 62502 Putrajaya, Malaysia',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    _buildInfoChip(
                                      Icons.star,
                                      '4.5 (1.2k)',
                                      Colors.orange,
                                      Colors.orange[50],
                                      Colors.orange[800],
                                    ),
                                    _buildInfoChip(
                                      Icons.ev_station,
                                      'EV Charging',
                                      Colors.green,
                                      Colors.green[50],
                                      Colors.green[800],
                                    ),
                                    _buildInfoChip(
                                      Icons.local_parking,
                                      '25 Spots',
                                      Colors.blue,
                                      Colors.blue[50],
                                      Colors.blue[800],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16),

                      /// ⏱ ETA and Distance
                      SizedBox(height: 16),

                      /// ⏱ ETA and Distance
                      Text(
                        "Estimated Arrival",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 3),
                      Text(
                        "$_durationText ($_distanceText)",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 16),

                      /// 📋 Details Button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewDetailScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(Icons.info),
                        label: Text("Details"),
                      ),

                      SizedBox(height: 16),

                      /// 🧭 Start Navigation
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_userMarker != null &&
                              _destinationMarker != null) {
                            final origin = _userMarker!.position;
                            final dest = _destinationMarker!.position;

                            mapController.animateCamera(
                              CameraUpdate.newLatLngBounds(
                                LatLngBounds(
                                  southwest: LatLng(
                                    origin.latitude < dest.latitude
                                        ? origin.latitude
                                        : dest.latitude,
                                    origin.longitude < dest.longitude
                                        ? origin.longitude
                                        : dest.longitude,
                                  ),
                                  northeast: LatLng(
                                    origin.latitude > dest.latitude
                                        ? origin.latitude
                                        : dest.latitude,
                                    origin.longitude > dest.longitude
                                        ? origin.longitude
                                        : dest.longitude,
                                  ),
                                ),
                                50,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(Icons.navigation),
                        label: Text("Start Navigation"),
                      ),

                      SizedBox(height: 8),

                      /// ❌ Cancel Navigation
                      OutlinedButton.icon(
                        onPressed: () async {
                          setState(() {
                            _polylines.clear();
                            _distanceText = "";
                            _durationText = "";
                            _destinationMarker = null;
                          });

                          try {
                            Position position =
                                await _geoService.determinePosition();
                            LatLng currentLatLng = LatLng(
                              position.latitude,
                              position.longitude,
                            );

                            setState(() {
                              _userMarker = Marker(
                                markerId: MarkerId('user_location'),
                                position: currentLatLng,
                                infoWindow: InfoWindow(title: 'Your Location'),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueAzure,
                                ),
                              );
                            });

                            mapController.animateCamera(
                              CameraUpdate.newLatLngZoom(currentLatLng, 16.8),
                            );
                          } catch (e) {
                            debugPrint("Error resetting location: $e");
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blueAccent,
                          side: BorderSide(color: Colors.blueAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(Icons.close),
                        label: Text("Cancel Route"),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookingScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatBotScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "Nearby",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "Booking"),
          BottomNavigationBarItem(icon: Icon(Icons.android), label: "ChatBot"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
