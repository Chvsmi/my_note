class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime date;
  final String? imagePath;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: DateTime.parse(map['date']),
      imagePath: map['imagePath'],
    );
  }
}
