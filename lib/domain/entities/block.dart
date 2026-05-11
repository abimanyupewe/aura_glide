import 'package:equatable/equatable.dart';

class Block extends Equatable {
  final String id;
  final int type;
  final int row;
  final int col;
  final bool isMatched;

  const Block({
    required this.id,
    required this.type,
    required this.row,
    required this.col,
    this.isMatched = false,
  });

  Block copyWith({
    int? row,
    int? col,
    bool? isMatched,
  }) {
    return Block(
      id: id,
      type: type,
      row: row ?? this.row,
      col: col ?? this.col,
      isMatched: isMatched ?? this.isMatched,
    );
  }

  @override
  List<Object?> get props => [id, type, row, col, isMatched];
}