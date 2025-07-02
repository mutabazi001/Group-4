import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const InventoryApp()); // Added const for better performance
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key}); // Added const constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory Manager',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFEAF7F1), // Light mint green, added const
        appBarTheme: const AppBarTheme( // Consistent AppBar styling
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      // The initialRoute and routes setup are good.
      // Make sure the '/' route (root) is handled or not explicitly set if using initialRoute.
      // If InventoryHomePage should be the default when logged in, consider a wrapper.
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/inventory': (context) => InventoryHomePage(), // No const here as it's stateful
      },
    );
  }
}

//--- Login Page ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String errorMessage = "";

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Renamed to follow Dart naming conventions (camelCase)
  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        // It's generally safer to check if the widget is still mounted before navigating
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/inventory");
        }
      }
    } on FirebaseAuthException catch (e) { // Catch specific FirebaseAuthException
      setState(() {
        errorMessage = "Login failed: ${e.message ?? 'An unknown error occurred.'}";
      });
    } catch (e) { // Catch any other general exceptions
      setState(() {
        errorMessage = "Login failed: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")), // Added const
      body: Padding(
        padding: const EdgeInsets.all(16), // Added const
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"), // Added const
              keyboardType: TextInputType.emailAddress, // Added email keyboard type
            ),
            const SizedBox(height: 12), // Added const
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"), // Corrected "password " to "Password" and added const
              obscureText: true,
            ),
            const SizedBox(height: 20), // Increased SizedBox height for better spacing
            ElevatedButton(onPressed: _login, child: const Text("Log in")), // Added const and used corrected method name
            const SizedBox(height: 12), // Added const
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)), // Added const
            const SizedBox(height: 20), // Added const
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/signup");
              },
              child: const Text("Don't have an account? Sign up here"), // Added const
            ),
          ],
        ),
      ),
    );
  }
}

//--- Signup Page ---
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String errorMessage = "";

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Renamed to follow Dart naming conventions (camelCase)
  void _signup() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      final user = await _authService.signUp(email, password);
      if (user != null) {
        // It's generally safer to check if the widget is still mounted before navigating
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/inventory");
        }
      }
    } on FirebaseAuthException catch (e) { // Catch specific FirebaseAuthException
      setState(() {
        errorMessage = "Signup failed: ${e.message ?? 'An unknown error occurred.'}";
      });
    } catch (e) { // Catch any other general exceptions
      setState(() {
        errorMessage = "Signup failed: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signup")), // Added const
      body: Padding(
        padding: const EdgeInsets.all(16), // Added const
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"), // Added const
              keyboardType: TextInputType.emailAddress, // Added email keyboard type
            ),
            const SizedBox(height: 12), // Added const
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"), // Corrected "password " to "Password" and added const
              obscureText: true,
            ),
            const SizedBox(height: 20), // Increased SizedBox height for better spacing
            ElevatedButton(onPressed: _signup, child: const Text("Sign Up")), // Added const and used corrected method name
            const SizedBox(height: 12), // Added const
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)), // Added const
            const SizedBox(height: 20), // Added const
            TextButton(
              onPressed: () {
                // This TextButton navigates to '/signup' which is the current page.
                // It should likely navigate back to login or to the inventory if already signed up.
                // For this example, I'll change it to navigate to login.
                Navigator.pushReplacementNamed(context, "/login");
              },
              child: const Text("Already have an account? Log in here"), // Changed text
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryItem {
  String name;
  int quantity;

  InventoryItem(this.name, this.quantity);
}

//--- Inventory Home Page ---
class InventoryHomePage extends StatefulWidget {
  // Added const constructor
  const InventoryHomePage({super.key});

  @override
  _InventoryHomePageState createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final List<InventoryItem> _items = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _addItem() {
    String name = _nameController.text.trim();
    int? qty = int.tryParse(_qtyController.text.trim());

    if (name.isNotEmpty && qty != null && qty > 0) {
      setState(() {
        _items.add(InventoryItem(name, qty));
      });
      _nameController.clear();
      _qtyController.clear();
    } else {
      // Provide user feedback for invalid input
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid item name and a quantity greater than 0.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editItem(int index) {
    InventoryItem item = _items[index];
    TextEditingController editNameController = TextEditingController(
      text: item.name,
    );
    TextEditingController editQtyController = TextEditingController(
      text: item.quantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog( // Changed builder parameter to context
        title: const Text('Edit Item'), // Added const
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editNameController,
              decoration: const InputDecoration(labelText: 'Item Name'), // Added const
            ),
            TextField(
              controller: editQtyController,
              decoration: const InputDecoration(labelText: 'Quantity'), // Added const
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'), // Added const
          ),
          ElevatedButton(
            onPressed: () {
              String newName = editNameController.text.trim();
              int? newQty = int.tryParse(editQtyController.text.trim());

              if (newName.isNotEmpty && newQty != null && newQty > 0) {
                setState(() {
                  _items[index].name = newName;
                  _items[index].quantity = newQty;
                });
                Navigator.pop(context);
              } else {
                // Provide user feedback for invalid input in edit dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid item name and a quantity greater than 0.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Save'), // Added const
          ),
        ],
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Manager'), // Added const
        // backgroundColor is set in theme data, can be overridden here if needed.
        // backgroundColor: Colors.teal[700],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12), // Added const
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration( // Added const
                      labelText: 'Item Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Added const
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _qtyController,
                    decoration: const InputDecoration( // Added const
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10), // Added const
                ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  child: const Text('Add'), // Added const
                ),
              ],
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text("No inventory items yet.")) // Added const
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (_, index) {
                      final item = _items[index];
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric( // Added const
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text("Quantity: ${item.quantity}"),
                          onTap: () => _editItem(index),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red), // Added const
                            onPressed: () => _removeItem(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
     ),
);
}
}