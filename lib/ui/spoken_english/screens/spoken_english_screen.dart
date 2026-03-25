import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/spoken_english_controller.dart';

class SpokenEnglishScreen extends StatelessWidget {
  const SpokenEnglishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SpokenEnglishController());

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Deep Dark Background
      appBar: AppBar(
        title: Text(
          "Spoken English Pro",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // --- Wallet/Coin Section in AppBar ---
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E2E2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFF6B00).withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_rounded, color: Color(0xFFFF6B00), size: 18),
                const SizedBox(width: 6),
                Obx(() => Text(
                  "${controller.myCoins.value}",
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                )),
              ],
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)));
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- 1. Progress & Certificate Card ---
            SliverToBoxAdapter(
              child: _buildProgressAndCertificateCard(controller),
            ),

            // --- 2. Category Filters ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _buildDarkCategoryFilters(controller),
              ),
            ),

            // --- 3. Section Title ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "Modules",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // --- 4. Clean Video List ---
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final video = controller.filteredVideos[index];
                    return _buildDarkVideoTile(controller, video);
                  },
                  childCount: controller.filteredVideos.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      }),
    );
  }

  // --- 1. Progress & Certificate Card ---
  Widget _buildProgressAndCertificateCard(SpokenEnglishController controller) {
    bool isComplete = controller.courseProgress.value >= 1.0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Slightly lighter than background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E2E2E)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B00).withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Course Progress",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "${(controller.courseProgress.value * 100).toInt()}%",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFFFF6B00)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: controller.courseProgress.value,
              backgroundColor: const Color(0xFF2E2E2E),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 20),

          // --- Certificate Button ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => controller.claimCertificate(),
              icon: Icon(
                  isComplete ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
                  color: isComplete ? Colors.white : Colors.grey[400]
              ),
              label: Text(
                isComplete ? "Claim Your Certificate" : "Complete course to get Certificate",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: isComplete ? Colors.white : Colors.grey[400],
                    fontSize: 13
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isComplete ? const Color(0xFFFF6B00) : const Color(0xFF2E2E2E),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: isComplete ? 5 : 0,
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- 2. Dark Category Filters ---
  Widget _buildDarkCategoryFilters(SpokenEnglishController controller) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final cat = controller.categories[index];
          final isSelected = controller.selectedCategory.value == cat;

          return GestureDetector(
            onTap: () => controller.changeCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF6B00) : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? const Color(0xFFFF6B00) : const Color(0xFF2E2E2E)),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.grey[400],
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 3. Dark Video Tile (Pro Style) ---
  Widget _buildDarkVideoTile(SpokenEnglishController controller, dynamic video) {
    return GestureDetector(
      onTap: () => controller.playVideo(video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2E2E2E)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Thumbnail
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      height: 90,
                      width: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: const Color(0xFF2E2E2E)),
                    ),
                  ),
                  Container(
                    height: 90,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black.withOpacity(video.isLocked ? 0.6 : 0.3),
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: video.isLocked ? const Color(0xFF1A1A1A).withOpacity(0.8) : const Color(0xFFFF6B00).withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          video.isLocked ? Icons.lock_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        video.duration,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      video.description,
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          video.level,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF6B00), // Orange Highlight
                          ),
                        ),
                        if (video.progress > 0 && !video.isLocked)
                          Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                "${(video.progress * 100).toInt()}%",
                                style: GoogleFonts.poppins(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}