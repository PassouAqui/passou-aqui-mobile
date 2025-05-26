import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/info_card.dart';

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
    final provider = Provider.of<DashboardProvider>(context, listen: false);
    await provider.loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final isMediumScreen = size.width >= 600 && size.width < 1200;

    if (provider.isLoading && provider.dashboardData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final data = provider.dashboardData;
    if (data == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar dados do dashboard',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loadData,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isSmallScreen ? 1 : (isMediumScreen ? 2 : 4),
                mainAxisSpacing: isSmallScreen ? 12 : 16,
                crossAxisSpacing: isSmallScreen ? 12 : 16,
                childAspectRatio: isSmallScreen ? 1.5 : 1.8,
                children: [
                  InfoCard(
                    icon: Icons.medication,
                    title: 'Total de Medicamentos',
                    value: data['total_drugs'].toString(),
                    color: Colors.blue,
                  ),
                  InfoCard(
                    icon: Icons.location_on,
                    title: 'Total de Localizações',
                    value: data['total_locations'].toString(),
                    color: Colors.green,
                  ),
                  InfoCard(
                    icon: Icons.inventory,
                    title: 'Total de Itens',
                    value: data['total_inventory_items'].toString(),
                    color: Colors.orange,
                  ),
                  InfoCard(
                    icon: Icons.warning,
                    title: 'Estoque Baixo',
                    value: data['low_stock'].length.toString(),
                    color: Colors.red,
                    subtitle: 'itens com menos de 10 unidades',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (data['expiring_soon'].isNotEmpty) ...[
                Text(
                  'Medicamentos Próximos do Vencimento',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                      return ListTile(
                        title: Text(item['drug__nome']),
                        subtitle: Text(
                          'Local: ${item['location__name']}\n'
                          'Quantidade: ${item['quantity']}',
                        ),
                        trailing: Text(
                          'Vence em: ${_formatDate(DateTime.parse(item['expiration_date']))}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
