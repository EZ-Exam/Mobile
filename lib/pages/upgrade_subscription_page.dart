import 'package:flutter/material.dart';
import 'package:ezexam_mobile/services/api_service.dart';

class UpgradeSubscriptionPage extends StatefulWidget {
  const UpgradeSubscriptionPage({super.key});

  @override
  State<UpgradeSubscriptionPage> createState() => _UpgradeSubscriptionPageState();
}

class _UpgradeSubscriptionPageState extends State<UpgradeSubscriptionPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _subscriptionTypes = [];
  Map<String, dynamic>? _currentSubscription;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionData();
  }

  Future<void> _loadSubscriptionData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final types = await _apiService.getSubscriptionTypes();
      final current = await _apiService.getCurrentSubscription();

      setState(() {
        _subscriptionTypes = types;
        _currentSubscription = current;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUpgradeSubscription(Map<String, dynamic> subscriptionType) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check user balance (this would typically come from user profile or a dedicated balance endpoint)
      // For now, we'll assume user balance is sufficient or handled by backend.
      // In a real app, you'd fetch user balance and compare with subscriptionType['subscriptionPrice']

      final payload = {
        'subscriptionTypeId': subscriptionType['id'],
        'description': 'Subscribed to ${subscriptionType['subscriptionName']} plan',
      };

      final response = await _apiService.subscribe(payload);

      if (response['message'] != null && response['message'].contains('Insufficient balance')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Số dư không đủ để đăng ký gói. Vui lòng nạp thêm tiền.'),
              backgroundColor: Colors.red,
            ),
          );
          // Optionally navigate to deposit page
          Navigator.pushNamed(context, '/deposit-funds');
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký gói ${subscriptionType['subscriptionName']} thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadSubscriptionData(); // Refresh data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng ký gói: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleCancelSubscription() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.cancelSubscription();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hủy đăng ký thành công! Bạn đã được chuyển về gói Free.'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadSubscriptionData(); // Refresh data
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi hủy đăng ký: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isCurrentPlan(Map<String, dynamic> subscriptionType) {
    if (_currentSubscription == null) {
      return subscriptionType['subscriptionName'].toLowerCase() == 'free';
    }
    return _currentSubscription!['subscriptionTypeId'] == subscriptionType['id'];
  }

  bool _isPackageDisabled(Map<String, dynamic> subscriptionType) {
    if (_currentSubscription == null || _currentSubscription!['subscriptionName'].toLowerCase() == 'free') {
      return false;
    }
    final currentPriority = _getSubscriptionPriority(_currentSubscription!['subscriptionName']);
    final packagePriority = _getSubscriptionPriority(subscriptionType['subscriptionName']);
    return packagePriority < currentPriority;
  }

  int _getSubscriptionPriority(String subscriptionName) {
    final name = subscriptionName.toLowerCase();
    switch (name) {
      case 'free': return 1;
      case 'basic': return 2;
      case 'premium': return 3;
      case 'pro': return 4;
      case 'unlimited': return 5;
      default: return 0;
    }
  }

  IconData _getSubscriptionIcon(String subscriptionName) {
    final name = subscriptionName.toLowerCase();
    switch (name) {
      case 'free': return Icons.person;
      case 'basic': return Icons.star;
      case 'premium': return Icons.workspace_premium;
      case 'pro': return Icons.auto_awesome;
      case 'unlimited': return Icons.all_inclusive;
      default: return Icons.star;
    }
  }

  Color _getSubscriptionColor(String subscriptionName) {
    final name = subscriptionName.toLowerCase();
    switch (name) {
      case 'free': return Colors.grey;
      case 'basic': return Colors.green;
      case 'premium': return Colors.blue;
      case 'pro': return Colors.purple;
      case 'unlimited': return Colors.indigo;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Nâng cấp gói'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Lỗi: $_error',
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSubscriptionData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isDesktop ? 24 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isDesktop ? 32 : 24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF8B5CF6),
                              Color(0xFFEC4899),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(isDesktop ? 16 : 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                                  ),
                                  child: Icon(
                                    Icons.trending_up,
                                    color: Colors.white,
                                    size: isDesktop ? 32 : 24,
                                  ),
                                ),
                                SizedBox(width: isDesktop ? 16 : 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nâng cấp gói',
                                        style: TextStyle(
                                          fontSize: isDesktop ? 28 : 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Chọn gói phù hợp với bạn',
                                        style: TextStyle(
                                          fontSize: isDesktop ? 16 : 14,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isDesktop ? 24 : 20),
                      // Subscription Packages
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 4 : 2,
                          crossAxisSpacing: isDesktop ? 16 : 12,
                          mainAxisSpacing: isDesktop ? 16 : 12,
                          childAspectRatio: isDesktop ? 0.7 : 0.6,
                        ),
                        itemCount: _subscriptionTypes.length,
                        itemBuilder: (context, index) {
                          final subType = _subscriptionTypes[index];
                          final isCurrent = _isCurrentPlan(subType);
                          final isDisabled = _isPackageDisabled(subType);
                          final icon = _getSubscriptionIcon(subType['subscriptionName']);
                          final color = _getSubscriptionColor(subType['subscriptionName']);

                          return Card(
                            elevation: isCurrent ? 8 : 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                              side: BorderSide(
                                color: isCurrent ? color : Colors.grey.shade300,
                                width: isCurrent ? 2 : 1,
                              ),
                            ),
                            child: Opacity(
                              opacity: isDisabled ? 0.6 : 1.0,
                              child: Stack(
                                children: [
                                  if (isCurrent)
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(isDesktop ? 16 : 12),
                                            topRight: Radius.circular(isDesktop ? 16 : 12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Gói hiện tại',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: EdgeInsets.all(isDesktop ? 16 : 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(icon, size: isDesktop ? 48 : 36, color: color),
                                        SizedBox(height: isDesktop ? 12 : 8),
                                        Text(
                                          subType['subscriptionName'],
                                          style: TextStyle(
                                            fontSize: isDesktop ? 20 : 18,
                                            fontWeight: FontWeight.bold,
                                            color: color,
                                          ),
                                        ),
                                        SizedBox(height: isDesktop ? 8 : 6),
                                        Text(
                                          subType['subscriptionPrice'] == 0
                                              ? 'Miễn phí'
                                              : '${subType['subscriptionPrice'].toLocaleString('vi-VN')} VNĐ/tháng',
                                          style: TextStyle(
                                            fontSize: isDesktop ? 18 : 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        SizedBox(height: isDesktop ? 12 : 8),
                                        Expanded(
                                          child: Text(
                                            subType['description'],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: isDesktop ? 14 : 12,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(height: isDesktop ? 16 : 12),
                                        ElevatedButton(
                                          onPressed: isCurrent || isDisabled || _isLoading
                                              ? null
                                              : () => _handleUpgradeSubscription(subType),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: color,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                                vertical: isDesktop ? 12 : 8, horizontal: isDesktop ? 24 : 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                                            ),
                                          ),
                                          child: _isLoading && !isCurrent && !isDisabled
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                )
                                              : Text(
                                                  isCurrent
                                                      ? 'Gói hiện tại'
                                                      : isDisabled
                                                          ? 'Không thể hạ cấp'
                                                          : 'Nâng cấp',
                                                  style: TextStyle(
                                                    fontSize: isDesktop ? 16 : 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: isDesktop ? 24 : 20),
                      // Cancel Subscription Section
                      if (_currentSubscription != null && _currentSubscription!['subscriptionName'].toLowerCase() != 'free')
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isDesktop ? 24 : 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel, size: isDesktop ? 48 : 36, color: Colors.red),
                              SizedBox(height: isDesktop ? 12 : 8),
                              Text(
                                'Hủy gói đăng ký hiện tại',
                                style: TextStyle(
                                  fontSize: isDesktop ? 20 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade800,
                                ),
                              ),
                              SizedBox(height: isDesktop ? 8 : 6),
                              Text(
                                'Bạn có chắc chắn muốn hủy gói đăng ký hiện tại? Bạn sẽ mất quyền truy cập vào các tính năng cao cấp và được chuyển về gói Free.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isDesktop ? 14 : 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: isDesktop ? 16 : 12),
                              ElevatedButton(
                                onPressed: _isLoading ? null : _handleCancelSubscription,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      vertical: isDesktop ? 12 : 8, horizontal: isDesktop ? 24 : 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        'Hủy gói đăng ký',
                                        style: TextStyle(
                                          fontSize: isDesktop ? 16 : 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 24),
                    ],
                  ),
                ),
      ),
    );
  }
}
