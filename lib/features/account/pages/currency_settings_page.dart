import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phptravels/providers/currency_provider.dart';

class CurrencySettingsSheet extends StatefulWidget {
  const CurrencySettingsSheet({super.key});

  @override
  State<CurrencySettingsSheet> createState() => _CurrencySettingsSheetState();
}

class _CurrencySettingsSheetState extends State<CurrencySettingsSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrencyProvider>(
      builder: (context, currencyProvider, child) {
        final filteredCurrencies =
            currencyProvider.supportedCurrencies.where((currency) {
          if (_searchQuery.isEmpty) return true;
          final query = _searchQuery.toLowerCase();
          return currency.code.toLowerCase().contains(query) ||
              currency.name.toLowerCase().contains(query);
        }).toList();

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    // Close X button
                    IconButton(
                      icon: const Icon(Icons.close, size: 28),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    // Search field
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Search Currency',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Currency list
              Expanded(
                child: ListView.builder(
                  itemCount: filteredCurrencies.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final currency = filteredCurrencies[index];
                    final isSelected =
                        currencyProvider.currencyCode == currency.code;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          currencyProvider.setCurrency(currency.code);
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              // Currency text: CODE - Full Name (Symbol)
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: currency.code,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.black,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            ' - ${currency.name} (${currency.symbol})',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.black,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Right side: checkmark or code badge
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  size: 22,
                                  color: Colors.blue,
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    currency.code,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
