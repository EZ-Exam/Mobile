
enum SubscriptionLevel {
  FREE,
  BASIC,
  PREMIUM,
  PRO,
  UNLIMITED
}

enum RoleId {
  USER,
  ADMIN,
  MODERATOR
}

class SubscriptionUtils {
  static SubscriptionLevel getSubscriptionLevel(Map<String, dynamic>? user) {
    if (user == null || user['subscriptionName'] == null) {
      return SubscriptionLevel.FREE;
    }

    final subscriptionName = user['subscriptionName'].toString().toUpperCase();
    switch (subscriptionName) {
      case 'BASIC':
        return SubscriptionLevel.BASIC;
      case 'PREMIUM':
        return SubscriptionLevel.PREMIUM;
      case 'PRO':
        return SubscriptionLevel.PRO;
      case 'UNLIMITED':
        return SubscriptionLevel.UNLIMITED;
      default:
        return SubscriptionLevel.FREE;
    }
  }

  static bool isFreeUser(Map<String, dynamic>? user) {
    return getSubscriptionLevel(user) == SubscriptionLevel.FREE;
  }

  static bool hasBasicOrHigher(Map<String, dynamic>? user) {
    final level = getSubscriptionLevel(user);
    return level != SubscriptionLevel.FREE;
  }

  static bool hasPremiumOrHigher(Map<String, dynamic>? user) {
    final level = getSubscriptionLevel(user);
    return level == SubscriptionLevel.PREMIUM ||
           level == SubscriptionLevel.PRO ||
           level == SubscriptionLevel.UNLIMITED;
  }

  static RoleId? getRoleId(Map<String, dynamic>? user) {
    if (user == null || user['roleId'] == null) {
      return null;
    }

    final roleId = user['roleId'].toString();
    switch (roleId) {
      case '1':
        return RoleId.USER;
      case '2':
        return RoleId.ADMIN;
      case '3':
        return RoleId.MODERATOR;
      default:
        return null;
    }
  }

  static bool isModerator(Map<String, dynamic>? user) {
    return getRoleId(user) == RoleId.MODERATOR;
  }

  static bool isAdmin(Map<String, dynamic>? user) {
    return getRoleId(user) == RoleId.ADMIN;
  }

  static bool canCreateQuestionAndLesson(Map<String, dynamic>? user) {
    return isModerator(user) || isAdmin(user);
  }

  static bool canCreateMockTest(Map<String, dynamic>? user) {
    return hasPremiumOrHigher(user);
  }

  static bool canViewAnswersAndExplanations(Map<String, dynamic>? user) {
    return hasBasicOrHigher(user);
  }

  static bool canViewAnalyticsAndDetails(Map<String, dynamic>? user) {
    return hasBasicOrHigher(user);
  }

  static bool canCommentInQuestionBank(Map<String, dynamic>? user) {
    return hasBasicOrHigher(user);
  }

  static String getUpgradeMessage(SubscriptionLevel requiredLevel) {
    switch (requiredLevel) {
      case SubscriptionLevel.BASIC:
        return 'Bạn cần nâng cấp lên gói BASIC để sử dụng tính năng này.';
      case SubscriptionLevel.PREMIUM:
        return 'Bạn cần nâng cấp lên gói PREMIUM để sử dụng tính năng này.';
      case SubscriptionLevel.PRO:
        return 'Bạn cần nâng cấp lên gói PRO để sử dụng tính năng này.';
      default:
        return 'Bạn cần nâng cấp subscription để sử dụng tính năng này.';
    }
  }

  static String getDisplaySubscriptionLevel(Map<String, dynamic>? user) {
    if (user == null || user['subscriptionName'] == null) {
      return 'FREE';
    }
    return user['subscriptionName'].toString().toUpperCase();
  }
}
