import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:irbs/src/screens/all_requests.dart';
import 'package:irbs/src/services/api.dart';
import 'package:irbs/src/store/common_store.dart';
import 'package:irbs/src/widgets/home/empty_sate.dart';
import 'package:irbs/src/widgets/home/request_tile.dart';
import 'package:irbs/src/globals/styles.dart';
import 'package:irbs/src/globals/colors.dart';
import 'package:irbs/src/widgets/shimmer/pending_requests_shimmer.dart';
import 'package:provider/provider.dart';

class PendingRequestCarousel extends StatelessWidget {
  const PendingRequestCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    var cs = context.read<CommonStore>();
    double screenWidth = MediaQuery.of(context).size.width;
    return Observer(
      builder: (context) {
        return cs.pending > 0 ? FutureBuilder(
          future: APIService().getOwnedRoomBookings(),
          builder: (context, snapshot){
            if(!snapshot.hasData){
              return const PendingRequestShimmer();
            }else if(snapshot.hasError){
              return const Center(child: Text('Error'),);
            }
            else{
              if(snapshot.data!.isEmpty)return const EmptyListPlaceholder(text: 'No new requests');
              return Column(
                children: [
                  SizedBox(
                    height: 167 * screenWidth / 360,
                    child: ListView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        CarouselSlider(
                          items: snapshot.data!.map((booking) => RequestTile(
                            bookingData: booking, 
                            commonStore: cs,
                          )).toList(),
                          options: CarouselOptions(
                            height: (167 * screenWidth) / 360,
                            padEnds: true,
                            enlargeCenterPage: false,
                            autoPlay: false,
                            enableInfiniteScroll: false,
                            viewportFraction: 0.9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Container(
                        height: 40,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            color: snapshot.data!.isEmpty 
                              ? Themes.disabledButtonBackground 
                              : Themes.kCommonBoxBackground,
                            borderRadius: BorderRadius.circular(4)),
                        child: const Center(
                          child: Text(
                            'View all Requests',
                            style: kRequestedRoomStyle,
                          ),
                        ),
                      ),
                    ),
                    onTap: (){
                      if(snapshot.data!.isEmpty)return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context)=> PendingRequestsScreen(
                            requestedBookings: snapshot.data ?? [],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          },
        ) : Container();
      }
    );
  }
}
