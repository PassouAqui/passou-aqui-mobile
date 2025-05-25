import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:passou_aqui_mobile/domain/entities/drug.dart';
import 'package:passou_aqui_mobile/presentation/providers/drug_provider.dart';
import 'package:intl/intl.dart';

class DrugForm extends StatefulWidget {
  final Drug? drug;
  final bool isEditing;

  const DrugForm({
    super.key,
    this.drug,
    this.isEditing = false,
  });

  @override
  State<DrugForm> createState() => _DrugFormState();
}

class _DrugFormState extends State<DrugForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _tagUidController;
  late final TextEditingController _loteController;
  late DateTime _validade;
  late Tarja _tarja;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.drug?.nome);
    _descricaoController = TextEditingController(text: widget.drug?.descricao);
    _tagUidController = TextEditingController(text: widget.drug?.tagUid);
    _loteController = TextEditingController(text: widget.drug?.lote);
    _validade = widget.drug?.validade ?? DateTime.now();
    _tarja = widget.drug?.tarja ?? Tarja.semTarja;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _tagUidController.dispose();
    _loteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _validade,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && picked != _validade) {
      setState(() {
        _validade = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final drug = Drug(
      id: widget.drug?.id,
      nome: _nomeController.text,
      descricao: _descricaoController.text,
      tagUid: _tagUidController.text,
      lote: _loteController.text,
      validade: _validade,
      tarja: _tarja,
    );

    try {
      final provider = Provider.of<DrugProvider>(context, listen: false);
      if (widget.isEditing) {
        await provider.updateDrug(drug.id, drug);
      } else {
        await provider.createDrug(drug);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar medicamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Medicamento',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o nome do medicamento';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagUidController,
              decoration: const InputDecoration(
                labelText: 'Tag RFID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira a tag RFID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _loteController,
              decoration: const InputDecoration(
                labelText: 'Lote',
                border: OutlineInputBorder(),
              ),
              enabled: !widget.isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o lote';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: widget.isEditing ? null : () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data de Validade',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(_validade),
                  style: TextStyle(
                    color: widget.isEditing ? Colors.grey : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Tarja>(
              value: _tarja,
              decoration: const InputDecoration(
                labelText: 'Tarja',
                border: OutlineInputBorder(),
              ),
              items: Tarja.values.map((Tarja tarja) {
                return DropdownMenuItem<Tarja>(
                  value: tarja,
                  child: Text(tarja.label),
                );
              }).toList(),
              onChanged: (Tarja? newValue) {
                if (newValue != null) {
                  setState(() {
                    _tarja = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: Text(
                widget.isEditing
                    ? 'Atualizar Medicamento'
                    : 'Adicionar Medicamento',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
