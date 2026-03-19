import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:findify_new_demo/authentication/login.dart';
import '../user_model.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // Controllers for text fields
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  final TextEditingController mailcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  bool isLoading = false; // Added loading state

  @override
  void dispose() {
    namecontroller.dispose();
    passwordcontroller.dispose();
    mailcontroller.dispose();
    super.dispose();
  }

  registration() async {
    // 1. Check validation
    if (_formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // 2. Create user in Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: mailcontroller.text.trim(),
              password: passwordcontroller.text.trim(),
            );

        User? userDetails = userCredential.user;

        if (userDetails != null) {
          // 3. Prepare User Model
          UserModel userModel = UserModel(
            email: mailcontroller.text.trim(),
            name: namecontroller.text.trim(),
            imgUrl: userDetails.photoURL ?? "",
            description: "",
            phone: "",
            id: userDetails.uid,
          );

          // 4. FIX: Use .doc(uid).set() instead of .add() to ensure IDs match
          await FirebaseFirestore.instance
              .collection("User")
              .doc(userDetails.uid)
              .set(userModel.toJson());

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Registered Successfully")),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = "An error occurred";

        // FIX: corrected typo 'weak-pasword' to 'weak-password'
        if (e.code == 'weak-password') {
          errorMessage = "Password is too weak.";
        } else if (e.code == "email-already-in-use") {
          errorMessage = "Account already exists for this email.";
        } else {
          errorMessage = e.message ?? "Registration failed.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(errorMessage),
          ),
        );
      } catch (e) {
        debugPrint(e.toString());
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                "../images/lost_and_found.png",
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height * 0.35,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    // Name Field
                    _buildTextField(namecontroller, "Name", (value) {
                      if (value == null || value.isEmpty)
                        return 'Please Enter Name';
                      return null;
                    }),
                    const SizedBox(height: 30),
                    // Email Field
                    _buildTextField(mailcontroller, "Email", (value) {
                      if (value == null || value.isEmpty)
                        return 'Please Enter Email';
                      if (!value.contains("@"))
                        return 'Please enter a valid email';
                      return null;
                    }),
                    const SizedBox(height: 30),
                    // Password Field
                    _buildTextField(passwordcontroller, "Password", (value) {
                      if (value == null || value.isEmpty)
                        return 'Please Enter Password';
                      if (value.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    }, isObscure: true),
                    const SizedBox(height: 30),

                    // Sign Up Button
                    GestureDetector(
                      onTap: isLoading ? null : registration,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: const Color(0xffff9d14),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),
            const Text(
              "or Login with",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Image.asset("../images/google.png", width: 45, height: 45),
            const SizedBox(height: 35),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Already have an account? ",
                  style: TextStyle(color: Color(0xff8c8e98), fontSize: 18),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper Widget to keep code clean
  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    String? Function(String?)? validator, {
    bool isObscure = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: const Color(0xFFedf0f8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: isObscure,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xffb2b7bf), fontSize: 18),
        ),
      ),
    );
  }
}
