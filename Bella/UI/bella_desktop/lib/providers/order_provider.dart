import 'package:bella_desktop/model/order.dart';
import 'package:bella_desktop/providers/base_provider.dart';

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super("Order");

  @override
  Order fromJson(dynamic json) {
    return Order.fromJson(json);
  }
}

