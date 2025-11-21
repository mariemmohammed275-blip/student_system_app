import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/services/auth_service.dart';
import '../models/student.dart';

// -----------------------------------------------------------------
// 1. GETX CONTROLLER (Manages State and Logic)
// -----------------------------------------------------------------
class LoginController extends GetxController {
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final rememberMe = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Email and password cannot be empty.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isLoading.value = true;

      Student? student = await authService.login(
        email: email,
        password: password,
      );

      if (student != null) {
        Get.offAllNamed('/home');
        Get.snackbar(
          "Success",
          "Logged in successfully!",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          "Login Failed",
          "Invalid email or password.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An unexpected error occurred: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void openSignUpScreen() => Get.offNamed('/signup');
  void forgetPasswordScreen() => Get.toNamed('/forgot');

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

// -----------------------------------------------------------------
// 2. LOGIN FORM (Stateless UI)
// -----------------------------------------------------------------
class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Login",
                    style: TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Email",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "example@email.com",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Password",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => TextField(
                      controller: controller.passwordController,
                      obscureText: !controller.isPasswordVisible.value,
                      decoration: InputDecoration(
                        hintText: "••••••••",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Remember me + Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Obx(
                            () => Checkbox(
                              value: controller.rememberMe.value,
                              onChanged: controller.toggleRememberMe,
                            ),
                          ),
                          const Text("Remember me"),
                        ],
                      ),
                      TextButton(
                        onPressed: controller.forgetPasswordScreen,
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Color(0xFF0D47A1)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Switch to Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don’t have an account? "),
                      GestureDetector(
                        onTap: controller.openSignUpScreen,
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color(0xFF0D47A1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:student_systemv1/Screens/home_screen.dart';
// import 'package:student_systemv1/Services/firebase_auth_service.dart';

// class LoginForm extends StatefulWidget {
//   const LoginForm({super.key});

//   @override
//   State<LoginForm> createState() => _LoginFormState();
// }

// class _LoginFormState extends State<LoginForm> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _rememberMe = false;

//   void _login() async {
//     //FirebaseAuth.instance.setLanguageCode("en");
//     await FirebaseAuth.instance.signInWithEmailAndPassword(
//       email: _emailController.text.trim(),
//       password: _passwordController.text.trim(),
//     );
//     Navigator.of(context).pushReplacementNamed("HomeScreen");
//   }

//   void openSignUpScreen() {
//     Navigator.of(context).pushReplacementNamed("SignUpScreen");
//   }

//   void forgetPasswordScreen() {
//     Navigator.of(context).pushReplacementNamed("ForgotPasswordForm");
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//   }

//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(25.0),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   //title
//                   Text(
//                     "Login",
//                     style: TextStyle(
//                       color: Color(0xFF0D47A1),
//                       fontSize: 35.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   // Email Field
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       "Email",
//                       style: TextStyle(fontSize: 15, color: Colors.grey[700]),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: _emailController,
//                     decoration: InputDecoration(
//                       hintText: "example@email.com",
//                       prefixIcon: const Icon(Icons.email_outlined),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Password Field
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       "Password",
//                       style: TextStyle(fontSize: 15, color: Colors.grey[700]),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: _passwordController,
//                     obscureText: _obscurePassword,
//                     decoration: InputDecoration(
//                       hintText: "••••••••",
//                       prefixIcon: const Icon(Icons.lock_outline),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword
//                               ? Icons.visibility_off
//                               : Icons.visibility,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _obscurePassword = !_obscurePassword;
//                           });
//                         },
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   // Remember me + Forgot password
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Checkbox(
//                             value: _rememberMe,
//                             onChanged: (val) => setState(() {
//                               _rememberMe = val ?? false;
//                             }),
//                           ),
//                           const Text("Remember me"),
//                         ],
//                       ),
//                       TextButton(
//                         onPressed: forgetPasswordScreen,
//                         child: const Text(
//                           "Forgot Password?",
//                           style: TextStyle(color: Color(0xFF0D47A1)),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 15),

//                   // Login button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: _login,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF0D47A1),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text(
//                         "Login",
//                         style: TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Switch to Sign Up
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("Don’t have an account? "),
//                       GestureDetector(
//                         onTap: openSignUpScreen,
//                         child: const Text(
//                           "Sign Up",
//                           style: TextStyle(
//                             color: Color(0xFF0D47A1),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
