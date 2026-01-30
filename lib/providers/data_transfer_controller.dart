import 'package:auth/db/auth_entries_ext.dart';
import 'package:auth/providers/auth_repository_provider.dart';
import 'package:auth/providers/data_transfer_state.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'data_transfer_controller.g.dart';

/// 处理数据传输操作（如备份和恢复）的控制器。
@riverpod
class DataTransferController extends _$DataTransferController {
  @override
  void build() {}

  /// 从剪贴板恢复认证数据。
  /// [confirmed] 如果为 true，则跳过覆盖确认直接导入（如果逻辑支持）。
  /// 注意：当前实现中，repository 的 importBatch 会覆盖数据，这里简化为只返回结果。
  /// 如果需要实现“先询问再覆盖”，repository 需要提供 dry-run 或 check 接口。
  Future<DataTransferResult> restore({bool confirmed = false}) async {
    final ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    final String? text = clipboardData?.text;

    if (text == null || text.trim().isEmpty) {
      return DataTransferNoData();
    }

    // 在实际复杂场景中，这里应该先分析 text 是否包含已存在的 key，返回 ConfirmationRequired
    // 但鉴于 repository.importBatch 目前是直接处理（update or insert），
    // 且之前的 UI 逻辑是先弹窗警告再执行，我们可以让 UI 层在调用前负责弹窗，
    // 或者在这里返回一个 warning 状态。
    // 为了保持之前逻辑的一致性（点击 -> 弹窗警告 -> 确认 -> 导入），
    // 我们将这个流程控制权交给 UI。UI 应该先询问用户，然后再调用此方法。
    // 如果 UI 已经询问过了，则这里直接执行。
    
    // 但是，为了完全解耦，Controller 应该提供“导入”原子操作。
    // 之前的逻辑是：点击 -> (警告: 可能会覆盖) -> 确定 -> 执行。
    // 这意味着警告是无条件的（只要点击就警告），而不是基于数据内容的。
    // 所以，UI 层负责“警告”是合理的。Controller 只负责“执行”。

    try {
      final result = await ref.read(authRepositoryProvider).importBatch(text);
      if (result.successCount > 0) {
        return DataTransferSuccess(result.successCount);
      } else {
        return DataTransferFailure('No valid entries found');
      }
    } catch (e) {
      return DataTransferFailure(e.toString());
    }
  }

  /// 将所有认证配置作为 OTP URI 列表备份到剪贴板。
  Future<DataTransferResult> backup() async {
    final records = await ref.read(authRepositoryProvider).getAllConfigs();

    if (records.isEmpty) {
      return DataTransferNoData();
    }

    final String optUrls = records.map((e) => e.toOtpUri()).join('\n');
    await Clipboard.setData(ClipboardData(text: optUrls));

    return DataTransferSuccess(records.length);
  }
}
