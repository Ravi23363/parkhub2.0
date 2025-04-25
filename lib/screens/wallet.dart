import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18, top: 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _contentHeader(),
            const SizedBox(height: 38),
            Text(
              "Account Overview",
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: const Color(0xff3A4276),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            _contentOverView(),
            const SizedBox(height: 34),
            _sectionHeader("Send Money", "assets/bar_code.png"),
            const SizedBox(height: 16),
            _contentSendMoney(),
            const SizedBox(height: 34),
            _sectionHeader("Services", "assets/adjust.png"),
            const SizedBox(height: 16),
            _contentServices(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String iconPath) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: const Color(0xff3A4276),
            fontWeight: FontWeight.w800,
          ),
        ),
        Image.asset(iconPath, width: 16),
      ],
    );
  }

  Widget _contentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Image.asset("assets/logo.png", width: 34),
            const SizedBox(width: 12),
            Text(
              "eWalle",
              style: GoogleFonts.poppins(
                fontSize: 22,
                color: const Color(0xff3A4276),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Image.asset("assets/menu.png", width: 16),
      ],
    );
  }

  Widget _contentOverView() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xffF1F3F6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "20,600",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: const Color(0xff171822),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Current Balance",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: const Color(0xff3A4276).withOpacity(.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffFFAC30),
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(12),
              elevation: 0,
            ),
            child: const Text(
              "+",
              style: TextStyle(color: Color(0xff1B1D28), fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentSendMoney() {
    final List<Map<String, String>> people = [
      {"name": "Mike", "img": "avatar_1.png"},
      {"name": "Joshpeh", "img": "avatar_2.png"},
      {"name": "Ashley", "img": "avatar_3.png"},
    ];

    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.all(18),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFFAC30),
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                elevation: 0,
              ),
              child: const Text(
                "+",
                style: TextStyle(color: Color(0xff1B1D28), fontSize: 22),
              ),
            ),
          ),
          ...people.map((person) {
            return Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(16),
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xffF1F3F6),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xffD8D9E4)),
                    ),
                    child: Image.asset("assets/${person['img']}", width: 36),
                  ),
                  Text(
                    person["name"]!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xff3A4276),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _contentServices(BuildContext context) {
    final List<ModelServices> listServices = [
      ModelServices(title: "Send\nMoney", img: "send.png"),
      ModelServices(title: "Receive\nMoney", img: "receive.png"),
      ModelServices(title: "Mobile\nPrepaid", img: "mobile.png"),
      ModelServices(title: "Electricity\nBill", img: "bill.png"),
      ModelServices(title: "Cashback\nOffer", img: "cashback.png"),
      ModelServices(title: "Movie\nTickets", img: "movie.png"),
      ModelServices(title: "Flight\nTickets", img: "flight.png"),
      ModelServices(title: "More\nOptions", img: "menu.png"),
    ];

    return SizedBox(
      height: 260,
      width: double.infinity,
      child: GridView.count(
        crossAxisCount: 4,
        childAspectRatio:
            MediaQuery.of(context).size.width /
            (MediaQuery.of(context).size.height / 1.5),
        children:
            listServices.map((service) {
              return GestureDetector(
                // ignore: avoid_print
                onTap: () => print(service.title),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xffF1F3F6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset("assets/${service.img}"),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      service.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xff3A4276),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}

class ModelServices {
  final String title;
  final String img;

  ModelServices({required this.title, required this.img});
}
