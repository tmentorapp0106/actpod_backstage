// import 'package:actpod_studio/features/api/api.dart';
// import 'package:flutter/material.dart';
// import 'package:dio/dio.dart';

// class ApiTestPage extends StatefulWidget {
//   const ApiTestPage({Key? key}) : super(key: key);

//   @override
//   State<ApiTestPage> createState() => _ApiTestPageState();
// }

// class _ApiTestPageState extends State<ApiTestPage> {
//   String result = "尚未測試";

//   Future<void> _testApi() async {
//     try {
//       Response res = await thirdPartyCreateUserOrLogin(
//         "testUser123",
//         "test@example.com",
//         "TestUser",
//       );

//       setState(() {
//         result = "✅ 成功：${res.data}";
//       });
//     } catch (e) {
//       setState(() {
//         result = "❌ 失敗：$e";
//         print(e);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("API 測試")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             ElevatedButton(onPressed: _testApi, child: const Text("測試 API")),
//             // const SizedBox(height: 20),
//             Text(result),
//           ],
//         ),
//       ),
//     );
//   }
// }
