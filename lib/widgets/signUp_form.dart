import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:student_systemv1/Services/firebase_auth_service.dart';

// -----------------------------------------------------------------
// 1. GETX CONTROLLER (Manages State and Logic)
// -----------------------------------------------------------------
class SignUpController extends GetxController {
  // Reactive States: Use .obs to make these variables observable (Rx)
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  // Text Controllers are defined here
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Logic functions
  bool passwordConfirmed() {
    return passwordController.text.trim() ==
        confirmPasswordController.text.trim();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Use Get.offNamed('/login')
  void openLoginScreen() {
    // Navigate using the GetX route name for the login form.
    Get.offNamed('/login');
  }

  // CORE FIX: Navigate directly to the login screen after successful signup
  Future<void> signUp() async {
    isLoading.value = true; // Start loading

    if (!passwordConfirmed()) {
      Get.snackbar(
        "Error",
        "Passwords do not match.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      isLoading.value = false;
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      if (userCredential.user != null) {
        // Log the user out immediately to stop the AuthWrapper redirect to /home.
        await FirebaseAuth.instance.signOut();

        // Introduce a small delay to ensure Firebase state propagation.
        await Future.delayed(const Duration(milliseconds: 50));

        // --- FIX: Reset loading state right before navigation ---
        isLoading.value = false;

        // Navigate to Login Screen ('/login')
        Get.offAllNamed('/login');

        Get.snackbar(
          "Success",
          "Account created! Please log in.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        throw Exception("Failed to create user account.");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = e.message ?? 'An unexpected error occurred.';

      // Handle common errors
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The email address is not valid.';
      }

      // Show error feedback using GetX Snackbar
      Get.snackbar(
        "Sign Up Failed",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      // Ensure loading state is reset on error
      isLoading.value = false;
    } catch (e) {
      // Handle non-Firebase errors
      Get.snackbar(
        "Error",
        "An unexpected error occurred: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      // Ensure loading state is reset on error
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

// -----------------------------------------------------------------
// 2. SIGN UP FORM (Stateless UI)
// -----------------------------------------------------------------
class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize and find the controller
    final controller = Get.put(SignUpController());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Title
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 35.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Full name
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Full Name",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.fullNameController,
                    decoration: InputDecoration(
                      hintText: "Rawan Gamal Abdullah",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email
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

                  // Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Password",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Obx rebuilds only this widget when controller.isPasswordVisible changes
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
                  const SizedBox(height: 20),

                  // Confirm Password
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Confirm Password",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => TextField(
                      controller: controller.confirmPasswordController,
                      obscureText: !controller.isConfirmPasswordVisible.value,
                      decoration: InputDecoration(
                        hintText: "••••••••",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isConfirmPasswordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: controller.toggleConfirmPasswordVisibility,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Sign Up button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    // Obx rebuilds the button when controller.isLoading changes
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.signUp,
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
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Switch to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: controller.openLoginScreen,
                        child: const Text(
                          "Login",
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

// class SignUpForm extends StatefulWidget {
//   const SignUpForm({super.key});

//   @override
//   State<SignUpForm> createState() => _SignUpFormState();
// }

// class _SignUpFormState extends State<SignUpForm> {
//   bool _obscurePassword = true;
//   bool _obscurePassword2 = true;
//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _loading = false;

//   Future signUp() async {
//     if (passwordConfirmed()) {
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text.trim(),
//       );
//       Navigator.of(context).pushNamed("/");
//     }
//   }

//   bool passwordConfirmed() {
//     if (_passwordController.text.trim() ==
//         _confirmPasswordController.text.trim()) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   void OpenLoginScreen() {
//     Navigator.of(context).pushReplacementNamed("/");
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _fullNameController.dispose();
//   }

//   @override
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
//                   //Title
//                   Text(
//                     "Sign Up",
//                     style: TextStyle(
//                       color: Color(0xFF0D47A1),
//                       fontSize: 35.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),

//                   // Full name
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       "Full Name",
//                       style: TextStyle(fontSize: 15, color: Colors.grey[700]),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: _fullNameController,
//                     decoration: InputDecoration(
//                       hintText: "Rawan Gamal Abdullah",
//                       prefixIcon: const Icon(Icons.person_outline),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Email
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

//                   // Password
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
//                   const SizedBox(height: 20),

//                   // Confirm Password
//                   Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       "Confirm Password",
//                       style: TextStyle(fontSize: 15, color: Colors.grey[700]),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: _confirmPasswordController,
//                     obscureText: _obscurePassword2,
//                     decoration: InputDecoration(
//                       hintText: "••••••••",
//                       prefixIcon: const Icon(Icons.lock_outline),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword2
//                               ? Icons.visibility_off
//                               : Icons.visibility,
//                         ),
//                         onPressed: () {
//                           setState(() {
//                             _obscurePassword2 = !_obscurePassword2;
//                           });
//                         },
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 40),

//                   // Sign Up button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton(
//                       onPressed: signUp,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF0D47A1),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: const Text(
//                         "Sign Up",
//                         style: TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Switch to Login
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("Already have an account? "),
//                       GestureDetector(
//                         onTap: OpenLoginScreen,
//                         child: const Text(
//                           "Login",
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
