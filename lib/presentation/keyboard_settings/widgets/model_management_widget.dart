import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ModelManagementWidget extends StatelessWidget {
  final bool isHindiModelDownloaded;
  final bool isEnglishModelDownloaded;
  final double downloadProgress;
  final bool isDownloading;
  final String downloadingModel;
  final Function(String) onDownloadModel;
  final Function(String) onDeleteModel;

  const ModelManagementWidget({
    Key? key,
    required this.isHindiModelDownloaded,
    required this.isEnglishModelDownloaded,
    required this.downloadProgress,
    required this.isDownloading,
    required this.downloadingModel,
    required this.onDownloadModel,
    required this.onDeleteModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> modelData = [
      {
        'name': 'Hindi Model',
        'key': 'hindi',
        'size': '45 MB',
        'description': 'Offline Hindi voice recognition',
        'isDownloaded': isHindiModelDownloaded,
      },
      {
        'name': 'English Model',
        'key': 'english',
        'size': '52 MB',
        'description': 'Offline English voice recognition',
        'isDownloaded': isEnglishModelDownloaded,
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'download',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offline Models',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Total storage: ${_calculateTotalStorage()} MB',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          ...modelData.map((model) => _buildModelItem(context, model)),
          if (isDownloading) _buildDownloadProgress(context),
        ],
      ),
    );
  }

  Widget _buildModelItem(BuildContext context, Map<String, dynamic> model) {
    final bool isDownloaded = model['isDownloaded'] as bool;
    final String modelKey = model['key'] as String;
    final bool isCurrentlyDownloading =
        isDownloading && downloadingModel == modelKey;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: isDownloaded
                  ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
                  : Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDownloaded
                    ? AppTheme.lightTheme.primaryColor
                    : Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: CustomIconWidget(
              iconName: isDownloaded ? 'check_circle' : 'cloud_download',
              color: isDownloaded
                  ? AppTheme.lightTheme.primaryColor
                  : Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.5) ??
                      Colors.grey,
              size: 24,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model['name'] as String,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  model['description'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  model['size'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          if (isCurrentlyDownloading)
            SizedBox(
              width: 6.w,
              height: 6.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.lightTheme.primaryColor,
                ),
              ),
            )
          else if (isDownloaded)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  onDeleteModel(modelKey);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'delete',
                        color: Colors.red,
                        size: 18,
                      ),
                      SizedBox(width: 2.w),
                      Text('Delete Model'),
                    ],
                  ),
                ),
              ],
              child: CustomIconWidget(
                iconName: 'more_vert',
                color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.6) ??
                    Colors.grey,
                size: 20,
              ),
            )
          else
            InkWell(
              onTap: () => onDownloadModel(modelKey),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Download',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDownloadProgress(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Downloading $downloadingModel model...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                '${(downloadProgress * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: downloadProgress,
            backgroundColor:
                Theme.of(context).dividerColor.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotalStorage() {
    int total = 0;
    if (isHindiModelDownloaded) total += 45;
    if (isEnglishModelDownloaded) total += 52;
    return total.toString();
  }
}
