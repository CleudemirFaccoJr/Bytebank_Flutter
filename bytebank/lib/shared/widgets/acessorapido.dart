import 'package:bytebank/app_colors.dart';
import 'package:flutter/material.dart';

class AcessoRapidoWidget extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Function(String)? onItemTap;

  AcessoRapidoWidget({
    super.key,
    List<Map<String, dynamic>>? items,
    this.onItemTap,
  })  : items = items ??
            [
              {'icon': Icons.receipt_long, 'label': 'Extrato'},
              {'icon': Icons.pix, 'label': 'Pix'},
              {'icon': Icons.credit_card, 'label': 'Cartões'},
              {'icon': Icons.trending_up, 'label': 'Investimentos'},
              {'icon': Icons.info_outline, 'label': 'Lorem'},
              {'icon': Icons.info_outline, 'label': 'Lorem'},
              {'icon': Icons.info_outline, 'label': 'Lorem'},
              {'icon': Icons.more_horiz, 'label': 'Ver mais'},
            ];
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: items.map((item) {
          return GestureDetector(
            onTap: () {
              if (onItemTap != null) {
                onItemTap!(item['label']);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.fundoAcessoRapido,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: AppColors.verdeClaro,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    item['label'] as String,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cinzaCardTexto,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
