import 'package:flutter/material.dart';
import 'package:ezexam_mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactionHistory();
  }

  Future<void> _loadTransactionHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      final history = await _apiService.getTransactionHistory(userId);

      setState(() {
        _transactions = history;
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

  String _formatCurrency(num amount) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');
    return format.format(amount);
  }

  String _formatDate(String isoDate) {
    final dateTime = DateTime.parse(isoDate);
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  Color _getStatusColor(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('success') || lowerStatus.contains('completed')) {
      return Colors.green;
    } else if (lowerStatus.contains('pending')) {
      return Colors.orange;
    } else if (lowerStatus.contains('failed') || lowerStatus.contains('cancelled')) {
      return Colors.red;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Lịch sử giao dịch'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
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
                        onPressed: _loadTransactionHistory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: isDesktop ? 80 : 60, color: Colors.grey[400]),
                          SizedBox(height: isDesktop ? 24 : 16),
                          Text(
                            'Không có giao dịch nào',
                            style: TextStyle(
                              fontSize: isDesktop ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: isDesktop ? 8 : 6),
                          Text(
                            'Lịch sử giao dịch của bạn sẽ hiển thị ở đây.',
                            style: TextStyle(
                              fontSize: isDesktop ? 14 : 12,
                              color: Colors.grey[500],
                            ),
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
                                  Color(0xFF3B82F6),
                                  Color(0xFF8B5CF6),
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
                                        Icons.history,
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
                                            'Lịch sử giao dịch',
                                            style: TextStyle(
                                              fontSize: isDesktop ? 28 : 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            'Xem lại các giao dịch của bạn',
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
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = _transactions[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: isDesktop ? 16 : 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(isDesktop ? 20 : 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            transaction['subscriptionName'] ?? 'N/A',
                                            style: TextStyle(
                                              fontSize: isDesktop ? 18 : 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade800,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(transaction['paymentStatus']).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              transaction['paymentStatus'] ?? 'N/A',
                                              style: TextStyle(
                                                color: _getStatusColor(transaction['paymentStatus']),
                                                fontWeight: FontWeight.bold,
                                                fontSize: isDesktop ? 12 : 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: isDesktop ? 12 : 8),
                                      _buildInfoRow(
                                        'Số tiền',
                                        _formatCurrency(transaction['amount'] ?? 0),
                                        Icons.money,
                                        isDesktop,
                                      ),
                                      _buildInfoRow(
                                        'Ngày bắt đầu',
                                        _formatDate(transaction['startDate'] ?? ''),
                                        Icons.calendar_today,
                                        isDesktop,
                                      ),
                                      _buildInfoRow(
                                        'Ngày kết thúc',
                                        _formatDate(transaction['endDate'] ?? ''),
                                        Icons.calendar_today_outlined,
                                        isDesktop,
                                      ),
                                      _buildInfoRow(
                                        'Ngày tạo',
                                        _formatDate(transaction['createdAt'] ?? ''),
                                        Icons.access_time,
                                        isDesktop,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 24),
                        ],
                      ),
                    ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 6 : 4),
      child: Row(
        children: [
          Icon(icon, size: isDesktop ? 18 : 16, color: Colors.grey[600]),
          SizedBox(width: isDesktop ? 12 : 8),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: isDesktop ? 8 : 6),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: isDesktop ? 14 : 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
