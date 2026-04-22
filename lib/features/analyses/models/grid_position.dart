class GridPosition {
  final int row;
  final int column;

  GridPosition({required this.row, required this.column});

  @override
  bool operator ==(Object other) =>
      other is GridPosition && other.row == row && other.column == column;

  @override
  int get hashCode => Object.hash(row, column);
}