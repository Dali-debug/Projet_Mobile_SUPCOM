import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../providers/app_state.dart';

class NurseryStatisticsScreen extends StatefulWidget {
  const NurseryStatisticsScreen({super.key});

  @override
  State<NurseryStatisticsScreen> createState() =>
      _NurseryStatisticsScreenState();
}

class _NurseryStatisticsScreenState extends State<NurseryStatisticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appState = Provider.of<AppState>(context, listen: false);

      if (appState.nurseries.isEmpty) {
        setState(() {
          _errorMessage = 'Aucune crèche trouvée';
          _isLoading = false;
        });
        return;
      }

      final nurseryId = appState.nurseries.first.id;

      // Load statistics from API
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/nurseries/$nurseryId/statistics'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _statistics = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Erreur lors du chargement des statistiques');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
        _isLoading = false;
      });
      print('Error loading statistics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Statistiques',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6366F1)),
            onPressed: _loadStatistics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadStatistics,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Réessayer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStatistics,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enrollments Section
                        _buildSectionTitle('Inscriptions'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total',
                                '${_statistics['totalEnrollments'] ?? 0}',
                                Icons.people,
                                const Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Actifs',
                                '${_statistics['activeEnrollments'] ?? 0}',
                                Icons.check_circle,
                                const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'En attente',
                                '${_statistics['pendingEnrollments'] ?? 0}',
                                Icons.pending,
                                const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Financial Section
                        _buildSectionTitle('Finances'),
                        const SizedBox(height: 12),
                        _buildFinancialCard(
                          'Revenu total',
                          '${_statistics['totalRevenue']?.toStringAsFixed(2) ?? '0.00'} DT',
                          Icons.account_balance_wallet,
                          const Color(0xFF10B981),
                        ),
                        const SizedBox(height: 12),
                        _buildFinancialCard(
                          'Revenu mensuel',
                          '${_statistics['monthlyRevenue']?.toStringAsFixed(2) ?? '0.00'} DT',
                          Icons.calendar_today,
                          const Color(0xFF6366F1),
                        ),
                        const SizedBox(height: 24),

                        // Rating Section
                        _buildSectionTitle('Évaluations'),
                        const SizedBox(height: 12),
                        _buildRatingCard(),
                        const SizedBox(height: 24),

                        // Capacity Section
                        _buildSectionTitle('Capacité'),
                        const SizedBox(height: 12),
                        _buildCapacityCard(),
                        const SizedBox(height: 24),

                        // Age Distribution
                        _buildSectionTitle('Répartition par âge'),
                        const SizedBox(height: 12),
                        _buildAgeDistribution(),
                        const SizedBox(height: 24),

                        // Payment Status
                        _buildSectionTitle('État des paiements'),
                        const SizedBox(height: 12),
                        _buildPaymentStatus(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
    final ratingValue = _statistics['averageRating'];
    final rating = ratingValue is num
        ? ratingValue.toDouble()
        : double.tryParse(ratingValue?.toString() ?? '0') ?? 0.0;
    final reviews = _statistics['totalReviews'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFBBF24).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Color(0xFFFBBF24),
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$rating / 5.0',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Basé sur $reviews avis',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating.floor()
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: const Color(0xFFFBBF24),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityCard() {
    final used = _statistics['capacityUsed'] ?? 0;
    final total = _statistics['totalCapacity'] ?? 100;
    final percentage = (used / total * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Taux d\'occupation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: used / total,
              minHeight: 12,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF6366F1),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$used / $total places occupées',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeDistribution() {
    final ageGroups =
        _statistics['childrenByAgeGroup'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: ageGroups.entries.map((entry) {
          final total = ageGroups.values.fold(0, (a, b) => a + (b as int));
          final percentage = (entry.value / total * 100).toInt();

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      '${entry.value} enfants ($percentage%)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.value / total,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentStatus() {
    final paymentStats =
        _statistics['paymentStats'] as Map<String, dynamic>? ?? {};
    final paid = paymentStats['paid'] ?? 0;
    final pending = paymentStats['pending'] ?? 0;
    final overdue = paymentStats['overdue'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPaymentStatusItem(
              'Payés',
              paid.toString(),
              const Color(0xFF10B981),
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: const Color(0xFFE2E8F0),
          ),
          Expanded(
            child: _buildPaymentStatusItem(
              'En attente',
              pending.toString(),
              const Color(0xFFF59E0B),
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: const Color(0xFFE2E8F0),
          ),
          Expanded(
            child: _buildPaymentStatusItem(
              'En retard',
              overdue.toString(),
              const Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
