import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/auth_model.dart';
import '../../untils/app_colors.dart';

class OrganizationSelectionDialog extends StatelessWidget {
  final List<Organization> organizations;
  final bool isCancellable;
  final Function(int orgId) onSelect;
  final VoidCallback onCancel;

  const OrganizationSelectionDialog({
    super.key,
    required this.organizations,
    required this.isCancellable,
    required this.onSelect,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    Widget dialogContent = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Chọn tổ chức làm việc",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "Vui lòng chọn tổ chức dưới đây để tiếp tục:",
              style: TextStyle(fontSize: 14, color: AppColors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: organizations.length,
                itemBuilder: (context, index) {
                  final org = organizations[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        org.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        onSelect(org.id);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onCancel,
              child: const Text("Hủy bỏ", style: TextStyle(color: AppColors.red)),
            ),
          ],
        ),
      ),
    );

    if (!isCancellable) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            onCancel();
          }
        },
        child: dialogContent,
      );
    }

    return dialogContent;
  }
}
