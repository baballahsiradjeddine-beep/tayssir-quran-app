import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/debug/app_logger.dart';
import 'package:tayssir/features/splash/splash_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfContentScreen extends HookConsumerWidget {
  const PdfContentScreen({super.key, required this.pdfUrl});

  final String pdfUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filePath = useState<String?>(null);
    final isLoading = useState<bool>(true);
    final isReady = useState<bool>(false);

    Future<String> downloadPdf(String url) async {
      if (kIsWeb) return url; // Should not reach here for file logic on web
      final dir = await getApplicationDocumentsDirectory();
      final name = url.split('/').last;
      final filePath = '${dir.path}/$name.pdf';
      final file = File(filePath);

      if (!await file.exists()) {
        await Dio().download(url, filePath);
      }

      return filePath;
    }

    Future<void> handleDownload() async {
      try {
        if (kIsWeb) {
          final uri = Uri.parse(pdfUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
          isLoading.value = false;
          return;
        }

        await Future.delayed(const Duration(seconds: 2));
        AppLogger.logInfo('Downloading PDF...');
        final path = await downloadPdf(pdfUrl);
        filePath.value = path;
        isLoading.value = false;
      } catch (e) {
        AppLogger.logError('Error downloading PDF: $e');
        isLoading.value = false;
      }
    }

    useEffect(() {
      handleDownload();
      return null;
    }, []);

    return AppScaffold(
        paddingX: 0,
        paddingY: 0,
        body: isLoading.value
            ? SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    10.verticalSpace,
                    const TayssirDataLoader(
                      textSize: 14,
                      iconSize: 30,
                    ),
                  ],
                ),
              )
            : (kIsWeb || filePath.value == null)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 60.sp,
                          color: Colors.white24,
                        ),
                        20.verticalSpace,
                        Text(
                          kIsWeb ? 'جاري فتح الملف في علامة تبويب جديدة...' : 'لا يوجد ملف حالياً',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white70,
                            fontFamily: 'SomarSans',
                          ),
                        ),
                        if (kIsWeb) ...[
                          20.verticalSpace,
                          ElevatedButton(
                            onPressed: () => launchUrl(Uri.parse(pdfUrl), mode: LaunchMode.externalApplication),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            child: Text(
                              'اضغط هنا لفتح الملف مباشرًة',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'SomarSans',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : PDFView(
                    filePath: filePath.value!,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: false,
                    pageFling: true,
                    backgroundColor: Colors.white.withOpacity(0.2),

                    onRender: (pages) {
                      isReady.value = true;
                      AppLogger.logInfo('PDF Rendered: $pages');
                    },
                    onError: (error) {
                      AppLogger.logError('PDF Error: $error');
                    },
                    onPageError: (page, error) {
                      AppLogger.logError('PDF Page Error: $page: $error');
                    },
                    onViewCreated: (PDFViewController pdfViewController) {
                      AppLogger.logInfo('PDF View Created: $pdfViewController');
                    },
                  ));
  }
}
