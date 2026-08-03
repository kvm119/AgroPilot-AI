class FarmerProfile {
  final String id;
  final String name;
  final String village;
  final String state;
  final double farmSizeAcres;
  final int experienceYears;
  final bool isVerified;
  final int followersCount;
  final int followingCount;
  final int postsCount;

  const FarmerProfile({
    required this.id,
    required this.name,
    required this.village,
    required this.state,
    required this.farmSizeAcres,
    required this.experienceYears,
    this.isVerified = true,
    this.followersCount = 142,
    this.followingCount = 38,
    this.postsCount = 12,
  });
}

class CommunityPost {
  final String id;
  final FarmerProfile author;
  final String topicGroup;
  final String title;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final int commentsCount;
  final DateTime timestamp;

  const CommunityPost({
    required this.id,
    required this.author,
    required this.topicGroup,
    required this.title,
    required this.content,
    this.imageUrl,
    this.likesCount = 24,
    this.commentsCount = 6,
    required this.timestamp,
  });
}
