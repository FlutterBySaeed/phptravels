import 'package:flutter/material.dart';
import 'package:phptravels/THEMES/app_theme.dart';
import 'package:phptravels/l10n/app_localizations.dart';

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;
  bool isSelected;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    this.isSelected = false,
  });
}

class PaymentPickerBottomSheet extends StatefulWidget {
  const PaymentPickerBottomSheet({super.key});

  @override
  State<PaymentPickerBottomSheet> createState() => _PaymentPickerBottomSheetState();
}

class _PaymentPickerBottomSheetState extends State<PaymentPickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  bool _showAll = false;
  
  final List<PaymentMethod> _allPaymentMethods = [
    PaymentMethod(id: 'mastercard', name: 'MasterCard Credit', icon: Icons.credit_card, isSelected: true),
    PaymentMethod(id: 'visa', name: 'Visa Credit', icon: Icons.credit_card, isSelected: true),
    PaymentMethod(id: 'easypaisa', name: 'Easypaisa', icon: Icons.smartphone, isSelected: true),
    PaymentMethod(id: 'payfast', name: 'PayFast', icon: Icons.payment, isSelected: true),
    PaymentMethod(id: 'amex', name: 'American Express', icon: Icons.credit_card, isSelected: false),
    PaymentMethod(id: 'Bank', name: 'Bank Transfer', icon: Icons.payment, isSelected: false),
    PaymentMethod(id: 'Diners', name: 'Diners Club', icon: Icons.payment, isSelected: false),
    PaymentMethod(id: 'mastercs', name: 'MasterCard Cirrus', icon: Icons.account_balance_wallet, isSelected: false),
    PaymentMethod(id: 'MasterDebit', name: 'MasterCard Debit', icon: Icons.account_balance_wallet, isSelected: false),
    PaymentMethod(id: 'paypal', name: 'PayPal', icon: Icons.payment, isSelected: false),
    PaymentMethod(id: 'VisaBeb', name: 'Visa Debit', icon: Icons.payment, isSelected: false),
    PaymentMethod(id: 'cash', name: 'Cash Payment', icon: Icons.account_balance_wallet, isSelected: false),
    PaymentMethod(id: 'WesternUnion', name: 'Western Union', icon: Icons.account_balance_wallet, isSelected: false),
    PaymentMethod(id: 'Bitcoin', name: 'Bitcoin', icon: Icons.account_balance_wallet, isSelected: false),
    PaymentMethod(id: 'CardInstallments', name: 'Card Installments', icon: Icons.account_balance_wallet, isSelected: false),
  ];

  late List<PaymentMethod> _filteredMethods;
  static const int _initialDisplayCount = 5;

  @override
  void initState() {
    super.initState();
    _filteredMethods = _allPaymentMethods;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMethods(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMethods = _allPaymentMethods;
        _showAll = false;
      } else {
        _filteredMethods = _allPaymentMethods
            .where((method) => method.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _togglePaymentMethod(String id) {
    setState(() {
      final method = _allPaymentMethods.firstWhere((m) => m.id == id);
      method.isSelected = !method.isSelected;
    });
  }

  void _toggleShowMore() {
    setState(() {
      _showAll = !_showAll;
    });
  }

  void _applyChanges() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, l10n),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(context, l10n),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Text(
                      l10n.paymentMethodsInfo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ),
                  _buildPaymentMethodsList(context, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsList(BuildContext context, AppLocalizations l10n) {
    final itemsToShow = _showAll ? _filteredMethods.length : _initialDisplayCount.clamp(0, _filteredMethods.length);
    final visibleMethods = _filteredMethods.take(itemsToShow).toList();
    final hasMoreItems = _filteredMethods.length > _initialDisplayCount;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: visibleMethods.length + (hasMoreItems ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == visibleMethods.length) {
          return _buildShowMoreButton(context, l10n);
        }
        return _buildPaymentMethodItem(context, visibleMethods[index]);
      },
    );
  }

  Widget _buildShowMoreButton(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: _toggleShowMore,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _showAll ? l10n.showLess : l10n.showMore,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                _showAll ? Icons.expand_less : Icons.expand_more,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 40,
            child: IconButton(
              icon: Icon(Icons.arrow_back, size: 20, color: Theme.of(context).textTheme.bodyMedium?.color),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          Text(
            l10n.paymentMethods,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: Icon(Icons.check, size: 20, color: Theme.of(context).textTheme.bodyMedium?.color),
              onPressed: _applyChanges,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search, size: 18, color: Theme.of(context).hintColor),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.top,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: l10n.searchPaymentType,
                  alignLabelWithHint: false,
                  hintStyle: Theme.of(context).textTheme.bodySmall,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: _filterMethods,
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _filterMethods('');
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(Icons.close, size: 16, color: Theme.of(context).hintColor),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem(BuildContext context, PaymentMethod method) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _togglePaymentMethod(method.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: method.isSelected ? AppColors.primaryBlue : Colors.transparent,
                  border: Border.all(
                    color: method.isSelected ? AppColors.primaryBlue : Theme.of(context).dividerColor,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: method.isSelected
                    ? const Icon(Icons.check, size: 16, color: AppColors.white)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  method.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(method.icon, size: 20, color: Theme.of(context).textTheme.bodyMedium?.color),
            ],
          ),
        ),
      ),
    );
  }
}