import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/orders_screen.dart';
import '../screens/user_product_screen.dart';
import '../providers/auth_provider.dart';

class SideDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello My Friend!'),
            automaticallyImplyLeading: false,
          ),
          Card(
            child: ListTile(
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/');
              },
              leading: Icon(Icons.payment),
              title: Text(
                'Shop',
              ),
            ),
          ),
          Card(
            child: ListTile(
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(OrdersScreen.routeName);
              },
              leading: Icon(Icons.shop),
              title: Text(
                'Orders',
              ),
            ),
          ),
          Card(
            child: ListTile(
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(UserProductScreen.routeName);
              },
              leading: Icon(Icons.edit),
              title: Text(
                'Manage Products',
              ),
            ),
          ),
          Card(
            child: ListTile(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/');

                Provider.of<AuthProvider>(context, listen: false).logout();
              },
              leading: Icon(Icons.exit_to_app),
              title: Text(
                'Logout',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
