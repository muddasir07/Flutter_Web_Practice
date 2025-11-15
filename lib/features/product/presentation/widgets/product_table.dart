import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../../../core/utils/responsive.dart';
import 'product_image.dart';

class ProductTable extends StatelessWidget {
  final List<Product> products;
  final String sortBy;
  final bool sortAscending;
  final Function(String, bool) onSort;
  final Function(Product) onProductTap;
  final Function(int) onDelete;

  const ProductTable({
    super.key,
    required this.products,
    required this.sortBy,
    required this.sortAscending,
    required this.onSort,
    required this.onProductTap,
    required this.onDelete,
  });

  Widget _buildSortableHeader(String label, String field) {
    final isSorted = sortBy == field;
    return InkWell(
      onTap: () => onSort(field, isSorted ? !sortAscending : true),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (isSorted)
            Icon(
              sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 16,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
              ),
              child: Padding(
                padding: EdgeInsets.all(isDesktop ? 16.0 : 8.0),
                child: DataTable(
                headingRowHeight: isDesktop ? 56 : 48,
                dataRowMinHeight: isDesktop ? 64 : 56,
                dataRowMaxHeight: isDesktop ? 72 : 64,
                columnSpacing: isDesktop ? 24.0 : (isTablet ? 16.0 : 12.0),
                columns: [
                  if (isDesktop)
                    DataColumn(
                      label: const Text('Image', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  DataColumn(
                    label: _buildSortableHeader('ID', 'id'),
                    numeric: true,
                  ),
                  DataColumn(
                    label: _buildSortableHeader('Name', 'name'),
                  ),
                  if (isDesktop || isTablet)
                    DataColumn(
                      label: _buildSortableHeader('Category', 'category'),
                    ),
                  DataColumn(
                    label: _buildSortableHeader('Price', 'price'),
                    numeric: true,
                  ),
                  if (isDesktop)
                    DataColumn(
                      label: _buildSortableHeader('Stock', 'stock'),
                      numeric: true,
                    ),
                  const DataColumn(
                    label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const DataColumn(
                    label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
                rows: products.map((product) {
                  final cells = <DataCell>[];
                  
                  if (isDesktop) {
                    cells.add(
                      DataCell(
                        ProductImage(
                          imageUrl: product.imageUrl,
                          width: 60,
                          height: 60,
                        ),
                      ),
                    );
                  }
                  
                  cells.addAll([
                    DataCell(
                      Text(
                        product.id.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: isDesktop ? null : 12,
                        ),
                      ),
                    ),
                    DataCell(
                      InkWell(
                        onTap: () => onProductTap(product),
                        child: Text(
                          product.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: Theme.of(context).colorScheme.primary,
                            fontSize: isDesktop ? null : 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ]);

                  if (isDesktop || isTablet) {
                    cells.add(
                      DataCell(
                        Text(
                          product.category,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: isDesktop ? null : 12,
                          ),
                        ),
                      ),
                    );
                  }

                  cells.addAll([
                    DataCell(
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontSize: isDesktop ? null : 12,
                        ),
                      ),
                    ),
                  ]);

                  if (isDesktop) {
                    cells.add(
                      DataCell(
                        Text(
                          product.stock.toString(),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    );
                  }

                  cells.addAll([
                    DataCell(
                      Chip(
                        label: Text(
                          product.stockStatus,
                          style: TextStyle(
                            fontSize: isDesktop ? 12 : 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: product.isInStock
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: product.isInStock ? Colors.green : Colors.red,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 8 : 6,
                          vertical: 4,
                        ),
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: isDesktop ? 24 : 20,
                        ),
                        onPressed: () => onDelete(product.id),
                        tooltip: 'Delete product',
                      ),
                    ),
                  ]);

                  return DataRow(cells: cells);
                }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

