import 'package:flutter/material.dart';
import 'package:ezexam_mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DepositFundsPage extends StatefulWidget {
  const DepositFundsPage({super.key});

  @override
  State<DepositFundsPage> createState() => _DepositFundsPageState();
}

class _DepositFundsPageState extends State<DepositFundsPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  int _currentBalance = 0; // This should ideally come from user profile

  final List<int> _predefinedAmounts = [2000, 5000, 10000, 50000, 100000, 500000];

  @override
  void initState() {
    super.initState();
    _loadUserBalance();
  }

  Future<void> _loadUserBalance() async {
    // In a real app, you'd fetch the user's current balance here
    // For now, we'll use a placeholder or fetch from user profile if available
    try {
      final userProfile = await _apiService.getUserProfile();
      setState(() {
        _currentBalance = (userProfile['balance'] as num?)?.toInt() ?? 0;
      });
    } catch (e) {
      print('Error loading user balance: $e');
      // Handle error, maybe show a default balance or an error message
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  void _handlePredefinedAmount(int amount) {
    setState(() {
      _amountController.text = _formatCurrency(amount);
    });
  }

  Future<void> _handleDeposit() async {
    final String rawAmount = _amountController.text.replaceAll('.', '');
    final int? amount = int.tryParse(rawAmount);

    if (amount == null || amount < 2000 || amount > 10000000) {
      setState(() {
        _error = 'Số tiền nạp phải từ 2.000 VNĐ đến 10.000.000 VNĐ';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId'); // Assuming userId is stored in SharedPreferences

      if (userId == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      final payload = {
        'userId': int.parse(userId),
        'subscriptionTypeId': 1, // Assuming a default or free subscription type for deposit
        'itemName': "Deposit",
        'quantity': 1,
        'amount': amount,
        'description': "Deposit for EZEXAM",
      };

      final response = await _apiService.createPayment(payload);

      if (response['checkoutUrl'] != null) {
        final String checkoutUrl = response['checkoutUrl'];
        if (await canLaunchUrl(Uri.parse(checkoutUrl))) {
          await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Could not launch $checkoutUrl');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nạp tiền thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          _amountController.clear();
          _loadUserBalance(); // Refresh balance after successful deposit
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi nạp tiền: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        title: const Text('Nạp tiền'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: SingleChildScrollView(
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
                    Color(0xFF10B981),
                    Color(0xFF3B82F6),
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
                          Icons.account_balance_wallet,
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
                              'Nạp tiền',
                              style: TextStyle(
                                fontSize: isDesktop ? 28 : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Thêm tiền vào tài khoản của bạn',
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
            // Deposit Form
            Container(
              padding: EdgeInsets.all(isDesktop ? 24 : 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Số tiền nạp (VNĐ)',
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 16 : 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Nhập số tiền muốn nạp',
                      prefixIcon: const Icon(Icons.money, color: Color(0xFF10B981)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                        borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      final cleanValue = value.replaceAll('.', '');
                      final int? parsedValue = int.tryParse(cleanValue);
                      if (parsedValue != null) {
                        _amountController.value = TextEditingValue(
                          text: _formatCurrency(parsedValue),
                          selection: TextSelection.collapsed(offset: _formatCurrency(parsedValue).length),
                        );
                      }
                    },
                  ),
                  SizedBox(height: isDesktop ? 16 : 12),
                  Text(
                    'Chọn nhanh số tiền',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 12 : 8),
                  Wrap(
                    spacing: isDesktop ? 12 : 8,
                    runSpacing: isDesktop ? 12 : 8,
                    children: _predefinedAmounts.map((amount) {
                      final isSelected = int.tryParse(_amountController.text.replaceAll('.', '')) == amount;
                      return GestureDetector(
                        onTap: () => _handlePredefinedAmount(amount),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 16 : 12,
                            vertical: isDesktop ? 8 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF10B981) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF10B981) : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            '${_formatCurrency(amount)} VNĐ',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: isDesktop ? 14 : 12,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: isDesktop ? 24 : 20),
                  // Balance Display
                  Container(
                    padding: EdgeInsets.all(isDesktop ? 20 : 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Số dư hiện tại',
                              style: TextStyle(
                                fontSize: isDesktop ? 14 : 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              '${_formatCurrency(_currentBalance)} VNĐ',
                              style: TextStyle(
                                fontSize: isDesktop ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Sau khi nạp',
                              style: TextStyle(
                                fontSize: isDesktop ? 14 : 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              '${_formatCurrency(_currentBalance + (int.tryParse(_amountController.text.replaceAll('.', '')) ?? 0))} VNĐ',
                              style: TextStyle(
                                fontSize: isDesktop ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isDesktop ? 24 : 20),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleDeposit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
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
                            'Nạp tiền ngay',
                            style: TextStyle(
                              fontSize: isDesktop ? 18 : 16,
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
