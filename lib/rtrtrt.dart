// // due_members_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class DueMembersScreen extends StatelessWidget {
//   final controller = Get.put(DueMembersController());
//
//   String _formatDate(DateTime? date) {
//     if (date == null) return 'N/A';
//     return DateFormat('MMM dd, yyyy').format(date);
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Plan Expired Members (Only Today)",
//           style: GoogleFonts.inter(
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//             fontSize: MediaQuery.of(context).size.width > 800
//                 ? 22
//                 : MediaQuery.of(context).size.width > 400
//                 ? 18
//                 : 11,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         flexibleSpace: Container(),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: Obx(() {
//                 if (controller.isLoading.value) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 if (controller.errorMessage.isNotEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
//                         SizedBox(height: 10),
//                         Text(controller.errorMessage.value, textAlign: TextAlign.center),
//                         TextButton(
//                           onPressed: controller.fetchExpiredTodayMembers,
//                           child: Text('Try Again'),
//                         )
//                       ],
//                     ),
//                   );
//                 }
//                 if (controller.expiredMembers.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey),
//                         SizedBox(height: 10),
//                         Text("No plans expired today.", style: TextStyle(fontSize: 18)),
//                       ],
//                     ),
//                   );
//                 }
//
//                 return ListView.builder(
//                   itemCount: controller.expiredMembers.length,
//                   itemBuilder: (context, index) {
//                     final member = controller.expiredMembers[index];
//                     return InkWell(
//                       onTap: () {
//                         Get.to(() => MemberDetailScreen( memberId:member.id!,));
//                       },
//                       child: Card(
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         elevation: 1,
//                         margin: EdgeInsets.symmetric(vertical: 8),
//                         child: InkWell(
//                           borderRadius: BorderRadius.circular(12),
//                           onTap: () {
//                             Get.to(() => MemberDetailScreen( memberId:member.id!,));
//                           },
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Row(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 30,
//                                   backgroundImage: NetworkImage(
//                                     member.profileUrl ?? 'https://placehold.co/150x150 ',
//                                   ),
//                                 ),
//                                 SizedBox(width: 16),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         member.name ?? 'Unknown',
//                                         style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
//                                       ),
//                                       SizedBox(height: 4),
//                                       if (member.phone != null)
//                                         Text("Phone: ${member.phone}", style: TextStyle(color: Colors.blue)),
//                                     ],
//                                   ),
//                                 ),
//                                 // Email Icon Button
//                                 IconButton(
//                                   icon: Icon(Icons.email_rounded, color: Colors.orange),
//                                   tooltip: "Send Email",
//                                   onPressed: () {
//                                     Get.to(() => MemberDetailScreen( memberId:member.id!,));
//                                   },
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // due_members_controller.dart
// class DueMembersController extends GetxController {
//   final SupabaseClient _supabase = Supabase.instance.client;
//
//   RxList<Member> expiredMembers = <Member>[].obs;
//   RxBool isLoading = true.obs;
//   RxString errorMessage = ''.obs;
//   RxBool isEmailLoading = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchExpiredTodayMembers();
//   }
//
//   Future<void> fetchExpiredTodayMembers() async {
//     isLoading.value = true;
//     errorMessage.value = '';
//     try {
//       final now = DateTime.now();
//       final today = DateTime(now.year, now.month, now.day);
//
//       final response = await _supabase
//           .from('members')
//           .select()
//           .eq('status', true) // Optional: filter active members
//           .eq('expiry_date', today.toIso8601String().split('T')[0]); // format YYYY-MM-DD
//
//       expiredMembers.value = response.map((json) => Member.fromSupabase(json)).toList();
//     } on PostgrestException catch (e) {
//       errorMessage.value = 'Database error: ${e.message}';
//     } catch (e) {
//       errorMessage.value = 'Failed to load members: $e';
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
// }
//
//
// class Member {
//   final String? id;
//   final String? name;
//   final String? phone;
//   final String? email;
//   final String? address;
//   final String? aadhaar;
//   final String? gender;
//   final String? profileUrl;
//   final String? aadhaarFrontUrl;
//   final String? aadhaarBackUrl;
//   final String? invoiceUrl;
//   final String? plan;
//   final DateTime? startDate;
//   final DateTime? expiryDate;
//   final bool? personalTraining;
//   final bool? paymentPaid;
//   final String? paymentMode;
//   final double? totalAmount;
//   final double? amountPaid;
//   final double? balanceAmount;
//   final bool? status;
//   final DateTime? createdAt;
//
//   Member({
//     this.id,
//     this.name,
//     this.phone,
//     this.email,
//     this.address,
//     this.aadhaar,
//     this.gender,
//     this.profileUrl,
//     this.aadhaarFrontUrl,
//     this.aadhaarBackUrl,
//     this.invoiceUrl,
//     this.plan,
//     this.startDate,
//     this.expiryDate,
//     this.personalTraining,
//     this.paymentPaid,
//     this.paymentMode,
//     this.totalAmount,
//     this.amountPaid,
//     this.balanceAmount,
//     this.status,
//     this.createdAt,
//   });
//
//   factory Member.fromSupabase(Map<String, dynamic> json) {
//     return Member(
//       id: json['id']?.toString(),
//       name: json['name'] as String?,
//       phone: json['phone'] as String?,
//       email: json['email'] as String?,
//       address: json['address'] as String?,
//       aadhaar: json['aadhaar'] as String?,
//       gender: json['gender'] as String?,
//       profileUrl: json['profile_url'] as String?,
//       aadhaarFrontUrl: json['aadhaar_front_url'] as String?,
//       aadhaarBackUrl: json['aadhaar_back_url'] as String?,
//       invoiceUrl: json['invoice_url'] as String?,
//       plan: json['plan'] as String?,
//       startDate: json['start_date'] != null
//           ? DateTime.parse(json['start_date'])
//           : null,
//       expiryDate: json['expiry_date'] != null
//           ? DateTime.parse(json['expiry_date'])
//           : null,
//       personalTraining: json['personal_training'] as bool?,
//       paymentPaid: json['payment_paid'] as bool?,
//       paymentMode: json['payment_mode'] as String?,
//       totalAmount: (json['total_amount'] as num?)?.toDouble(),
//       amountPaid: (json['amount_paid'] as num?)?.toDouble(),
//       balanceAmount: (json['balance_amount'] as num?)?.toDouble(),
//       status: json['status'] as bool?,
//       createdAt: json['created_at'] != null
//           ? DateTime.parse(json['created_at'])
//           : null,
//     );
//   }
//
//   Map<String, dynamic> toSupabase() {
//     return {
//       'name': name,
//       'phone': phone,
//       'email': email,
//       'address': address,
//       'aadhaar': aadhaar,
//       'gender': gender,
//       'profile_url': profileUrl,
//       'aadhaar_front_url': aadhaarFrontUrl,
//       'aadhaar_back_url': aadhaarBackUrl,
//       'invoice_url': invoiceUrl,
//       'plan': plan,
//       'start_date': startDate?.toIso8601String(),
//       'expiry_date': expiryDate?.toIso8601String(),
//       'personal_training': personalTraining,
//       'payment_paid': paymentPaid,
//       'payment_mode': paymentMode,
//       'total_amount': totalAmount,
//       'amount_paid': amountPaid,
//       'balance_amount': balanceAmount,
//       'status': status,
//       'created_at': createdAt?.toIso8601String(),
//     };
//   }
// }
//
//
//
//
//
//
//
//
//
//
