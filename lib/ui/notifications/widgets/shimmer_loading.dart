import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FacebookPostShimmer extends StatelessWidget {
  const FacebookPostShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5, // ৫টি ডামি পোস্ট দেখাবে
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ১. হেডার (ছবি + নাম)
                Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 120, height: 12, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(width: 80, height: 10, color: Colors.white),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // ২. পোস্ট টেক্সট (৩ লাইন)
                Container(width: double.infinity, height: 10, color: Colors.white),
                const SizedBox(height: 6),
                Container(width: double.infinity, height: 10, color: Colors.white),
                const SizedBox(height: 6),
                Container(width: 200, height: 10, color: Colors.white),
                const SizedBox(height: 15),

                // ৩. পোস্ট ইমেজ (বড় বক্স)
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}