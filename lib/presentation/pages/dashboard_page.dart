import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passou_aqui_mobile/presentation/providers/dashboard_provider.dart';
import 'package:passou_aqui_mobile/presentation/widgets/info_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    await Provider.of<DashboardProvider>(context, listen: false)
        .loadDashboardData();
  }

  String _getTarjaLabel(String tarjaCode) {
    switch (tarjaCode) {
      case 'ST':
        return 'Sem Tarja';
      case 'TA':
        return 'Tarja Amarela';
      case 'TV':
        return 'Tarja Vermelha';
      case 'TP':
        return 'Tarja Preta';
      default:
        return tarjaCode;
    }
  }

  Color _getTarjaColor(String tarjaCode) {
    switch (tarjaCode) {
      case 'ST':
        return Colors.green;
      case 'TA':
        return Colors.amber;
      case 'TV':
        return Colors.red;
      case 'TP':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isMediumScreen = MediaQuery.of(context).size.width < 900;
    final provider = Provider.of<DashboardProvider>(context);
    final data = provider.dashboardData;

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro ao carregar dados: ${provider.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (data == null) {
      return const Scaffold(
        body: Center(child: Text('Nenhum dado disponível')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estatísticas gerais
              Text(
                'Estatísticas Gerais',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isSmallScreen ? 1 : (isMediumScreen ? 2 : 3),
                mainAxisSpacing: isSmallScreen ? 12 : 16,
                crossAxisSpacing: isSmallScreen ? 12 : 16,
                childAspectRatio: isSmallScreen ? 1.5 : 1.8,
                children: [
                  InfoCard(
                    icon: Icons.medication,
                    title: 'Total de Medicamentos',
                    value: data['total_drugs'].toString(),
                    color: theme.colorScheme.primary,
                  ),
                  InfoCard(
                    icon: Icons.check_circle,
                    title: 'Medicamentos Ativos',
                    value: data['active_drugs'].toString(),
                    color: Colors.green,
                  ),
                  InfoCard(
                    icon: Icons.cancel,
                    title: 'Medicamentos Inativos',
                    value: data['inactive_drugs'].toString(),
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Distribuição por tarja
              Text(
                'Distribuição por Tarja',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ...(data['tarja_distribution'] as Map<String, dynamic>)
                          .entries
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getTarjaColor(entry.key),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _getTarjaLabel(entry.key),
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ),
                                  Text(
                                    entry.value.toString(),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Medicamentos próximos do vencimento
              if (data['expiring_soon'].isNotEmpty) ...[
                Text(
                  'Medicamentos Próximos do Vencimento',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data['expiring_soon'].length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = data['expiring_soon'][index];
                      final expirationDate =
                          DateTime.parse(item['expiration_date']);
                      final daysUntilExpiration =
                          expirationDate.difference(DateTime.now()).inDays;

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getTarjaColor(item['drug__tarja'])
                                .withAlpha(26),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.medication,
                            color: _getTarjaColor(item['drug__tarja']),
                          ),
                        ),
                        title: Text(
                          item['drug__nome'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Local: ${item['location__name']}'),
                            Text('Quantidade: ${item['quantity']}'),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: daysUntilExpiration <= 7
                                ? Colors.red
                                : daysUntilExpiration <= 15
                                    ? Colors.orange
                                    : Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Vence em $daysUntilExpiration dias',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
