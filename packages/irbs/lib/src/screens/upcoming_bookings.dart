import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:irbs/src/models/booking_model.dart';
import 'package:irbs/src/services/api.dart';
import 'package:irbs/src/store/common_store.dart';
import 'package:irbs/src/widgets/drop_down.dart';
import 'package:irbs/src/widgets/home/current_bookings_widget.dart';
import 'package:irbs/src/widgets/home/empty_sate.dart';
import 'package:irbs/src/widgets/shimmer/current_booking_shimmer.dart';
import 'package:provider/provider.dart';
import '../globals/colors.dart';
import '../globals/styles.dart';

class UpcomingBookingsPage extends StatefulWidget {
  const UpcomingBookingsPage({Key? key}) : super(key: key);

  @override
  State<UpcomingBookingsPage> createState() => _UpcomingBookingsPageState();
}

class _UpcomingBookingsPageState extends State<UpcomingBookingsPage> {
  @override
  Widget build(BuildContext context) {
    var store = context.read<CommonStore>();
    return Scaffold(
      backgroundColor: Themes.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Upcoming Booking',
          style: appBarStyle,
        ),
        backgroundColor: Themes.tileColor,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: SingleChildScrollView(
          child: Observer(builder: (context) {
            return store.delete > 0? FutureBuilder(
              future: APIService()
                  .getUpcomingBokings(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const UpcomingBookingShimmer(number: 8);
                } else if (snapshot.hasError) {
                  return const Text('Error');
                } else {
                  List<BookingModel> currentBooking = snapshot.data!;
                  if (currentBooking.isEmpty) {
                    return const EmptyState(text: 'No bookings');
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: currentBooking.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            BookingModel? ans = currentBooking[index];
                            return CurrentBookingsWidget(
                              model: ans,
                            );
                          }),
                    ],
                  );
                }
              },
            ) : Container();
          }),
        ),
      ),
    );
  }
}