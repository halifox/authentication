/// 数据传输操作的结果状态
sealed class DataTransferResult {}

class DataTransferSuccess extends DataTransferResult {
  final int count;
  DataTransferSuccess(this.count);
}

class DataTransferFailure extends DataTransferResult {
  final String error;
  DataTransferFailure(this.error);
}

class DataTransferConfirmationRequired extends DataTransferResult {
  // 这里可以包含冲突的详细信息
}

class DataTransferNoData extends DataTransferResult {}
