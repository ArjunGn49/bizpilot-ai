import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bizpilotai/core/theme/app_colors.dart';
import 'package:bizpilotai/features/profile/presentation/widgets/experience_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Gradient Hero)
            _buildHeroHeader(context),

            // Main Body Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Basic Info Section
                  _buildSectionHeader('Basic Info'),
                  const SizedBox(height: 16),
                  _buildSubLabel('Interest'),
                  const SizedBox(height: 8),
                  _buildChipWrap(['Yoga', 'Meditation', 'Permaculture', 'Tree Plantation', 'Ayurveda']),
                  const SizedBox(height: 20),
                  _buildSubLabel('Professions'),
                  const SizedBox(height: 8),
                  _buildChipWrap(['Yoga Teacher', 'Environmental Activist', 'Wellness Coach']),
                  const SizedBox(height: 32),

                  // 3. Contact Section
                  _buildSectionHeader('Contact'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildContactField('Email', 'sri@oneness.org')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildContactField('Phone Number', '+91 98765 43210')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildContactField('Address', '108 Oneness Ashram, Foothills of Himalayas'),
                  const SizedBox(height: 16),
                  _buildContactField('Location', 'Rishikesh, Uttarakhand, India'),
                  const SizedBox(height: 16),
                  // Rotated Icon Contact Fields (45 Degrees)
                  _iconContactField(Icons.star_rounded, 'Best Practices', 'Sustainable Living', angle: 45),
                  const SizedBox(height: 16),
                  _iconContactField(Icons.group_rounded, 'Communities', 'Yoga Community', angle: 45),
                  const SizedBox(height: 32),

                  // 4. Experience Section
                  _buildSectionHeader('Experience'),
                  const SizedBox(height: 20),
                  const ExperienceTile(
                    logoUrl: 'https://picsum.photos/id/1018/100/100',
                    title: 'Founder & Lead Instructor',
                    company: 'Himalayan Yoga Foundation',
                    dateRange: 'Jan 2018 - Present',
                    location: 'Rishikesh, India',
                    bulletPoints: [
                      'Conducted over 500+ classical Hatha Yoga retreats worldwide.',
                      'Trained 2,000+ certified yoga teachers across 40 countries.'
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Divider(color: AppColors.dividerGrey, height: 1),
                  ),
                  const ExperienceTile(
                    logoUrl: 'https://picsum.photos/id/1015/100/100',
                    title: 'Director of Conservation',
                    company: 'Green Earth Initiative',
                    dateRange: 'Mar 2015 - Dec 2017',
                    location: 'New Delhi, India',
                    bulletPoints: [
                      'Spearheaded native tree plantation drives across rural regions.',
                      'Advocated sustainable organic farming practices.'
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 5. Education Section
                  _buildSectionHeader('Education'),
                  const SizedBox(height: 20),
                  const ExperienceTile(
                    logoUrl: 'https://picsum.photos/id/1068/100/100',
                    title: 'Master of Science in Environmental Studies',
                    company: 'University of Delhi',
                    dateRange: '2011 - 2013',
                    location: 'Delhi, India',
                    bulletPoints: [
                      'Specialized in Ecosystem Restoration & Forest Conservation.',
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Divider(color: AppColors.dividerGrey, height: 1),
                  ),
                  const ExperienceTile(
                    logoUrl: 'https://picsum.photos/id/1025/100/100',
                    title: 'Advanced Yoga Acharya Diploma',
                    company: 'Sivananda Yoga Vedanta Academy',
                    dateRange: '2009 - 2010',
                    location: 'Uttarkashi, India',
                    bulletPoints: [
                      'Rigorous study of Vedantic Philosophy and Pranayama.',
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Header Hero Banner ---
  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              // Top Action Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pill-shaped Back Button
                  InkWell(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: AppColors.navy),
                          SizedBox(width: 6),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Circular White Action Button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_outward_rounded, size: 20, color: AppColors.navy),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Avatar with Decorative Concentric Circle
              Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative Concentric Circle (1px white border, 7% opacity)
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white.withOpacity(0.07), width: 1),
                    ),
                  ),
                  // Avatar with 4px Padding White Border
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.lightGrey,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                          errorWidget: (context, url, error) => const Icon(Icons.person, size: 50, color: AppColors.navy),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name + Verified Check Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sri M',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.verified_rounded, size: 22, color: Colors.blue.shade300),
                ],
              ),
              const SizedBox(height: 4),

              // Subtitle
              Text(
                'Yoga Master | Environmentalist',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 12),

              // Bio Text Centered
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Dedicated to promoting holistic health through classical Hatha Yoga & environmental conservation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.white.withOpacity(0.90),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Translucent Social Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSocialItem(Icons.chat_bubble_outline_rounded, 'WhatsApp'),
                    _buildSocialItem(Icons.facebook_rounded, 'Facebook'),
                    _buildSocialItem(Icons.video_library_rounded, 'TikTok'),
                    _buildSocialItem(Icons.language_rounded, 'Website'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- Social Action Item ---
  Widget _buildSocialItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  // --- Section Header ---
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: AppColors.dividerGrey, thickness: 1, height: 1),
      ],
    );
  }

  // --- Sub-Label ---
  Widget _buildSubLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.navy,
      ),
    );
  }

  // --- Chip Wrap Builder ---
  Widget _buildChipWrap(List<String> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            item,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- Contact Field ---
  Widget _buildContactField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.greyText),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.titleDark,
          ),
        ),
      ],
    );
  }

  // --- NEW Section with ROTATED Icon (45 Degrees) ---
  Widget _iconContactField(IconData iconData, String label, String value, {required double angle}) {
    return Row(
      children: [
        // Rotated Icon
        Transform.rotate(
          angle: angle * math.pi / 180,
          child: Icon(
            iconData,
            size: 20,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.greyText),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.titleDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
