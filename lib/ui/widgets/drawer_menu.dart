import 'package:flutter/material.dart';
import 'package:grocery_app/core/futures/wallet_future_provider.dart';
import 'package:grocery_app/core/view_models/auth_view_model/auth_view_model_provider.dart';
import 'package:grocery_app/ui/address_list_page.dart';
import 'package:grocery_app/ui/orders_page.dart';
import 'package:grocery_app/ui/profile_page.dart';
import 'package:grocery_app/ui/widgets/login_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerMenu extends StatelessWidget {
  final VoidCallback close;
  
  DrawerMenu({this.close});
  @override
  Widget build(BuildContext context) {
    var authModel = context.read(authViewModelProvider);
    ListTile listTile({@required String text, @required Widget page}) {
      return ListTile(
        title: Text(text),
        onTap: () async {
          var user = authModel.user;
          close();
          if (user == null) {
            await Future.delayed(Duration(milliseconds: 300));
            user = await LoginSheet(context).show();
          }
          if (user != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => page,
              ),
            );
          }
        },
        leading: Icon(Icons.shopping_basket_outlined),
      );
    }

    return Material(
      color: Theme.of(context).accentColor,
      child: SafeArea(
        child: Theme(
          data: ThemeData.dark(),
                  child: ListView(
            children: [
              authModel.user != null
                  ? Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Icon(
                              Icons.person_outline_outlined,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(authModel.user.displayName != ""
                              ? authModel.user.displayName ?? "User"
                              : "User"),
                          subtitle: Text(authModel.user.phoneNumber),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.account_balance_wallet_outlined),
                              SizedBox(
                                width: 8,
                              ),
                              Consumer(
                                builder: (context, watch, child) {
                                  var data = watch(walletFutureProvider);
                                  return data.when(
                                    data: (wallet) => Text(
                                      "₹" + wallet.amount.toString(),
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    loading: () => CircularProgressIndicator(),
                                    error: (error, stackTrace) => Text(
                                      '0.0',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
              Divider(),
              listTile(
                text: "My Orders",
                page: OrdersPage(),
              ),
              ListTile(
                title: Text('My Address'),
                leading: Icon(Icons.location_on_outlined),
                onTap: () {
                  close();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddressListPage(),
                    ),
                  );
                },
              ),
              listTile(
                text: "My Profile",
                page: ProfilePage(),
              ),
              ListTile(
                onTap: () {
                  close();
                  launch(
                      "mailto:shivkumarkonade@gmail.com?subject=Feedback from " +
                          authModel.user.displayName +
                          " (" +
                          authModel.user.phoneNumber +
                          ")");
                },
                title: Text('Feedback'),
                leading: Icon(Icons.feedback_outlined),
              ),
              ListTile(
                onTap: () {
                  close();
                  launch("mailto:shivkumarkonade@gmail.com?subject=" +
                      authModel.user.displayName +
                      " (" +
                      authModel.user.phoneNumber +
                      "): <Subject>");
                },
                title: Text('Contact us'),
                leading: Icon(Icons.message_outlined),
              ),
              ListTile(
                onTap: () {
                  close();
                  Share.share(
                      "https://play.google.com/store/apps/details?id=org.telegram.messenger");
                },
                title: Text('Share'),
                leading: Icon(Icons.share),
              ),
              authModel.user != null
                  ? ListTile(
                      title: Text('Logout'),
                      onTap: () async {
                        await authModel.signOut();
                        close();
                      },
                      leading: Icon(Icons.logout),
                    )
                  : ListTile(
                      title: Text('Login'),
                      onTap: () async {
                        close();
                        await Future.delayed(Duration(milliseconds: 300));
                        var user = await LoginSheet(context).show();
                        if (user!=null && user.displayName == null) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(),
                            ),
                          );
                        }
                      },
                      leading: Icon(Icons.login),
                    ),
              Divider(),
              ListTile(
                title: Text('About'),
              ),
              ListTile(
                title: Text('Privacy Policy'),
              ),
              ListTile(
                title: Text('Terms & conditions'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}