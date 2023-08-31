class Books2 {
  final int bookid;
  final String title;
  final String picurl;
  final String createddatetime;
  // final AnimationController translationController;

  Books2({
    required this.bookid,
    required this.title,
    required this.picurl,
    required this.createddatetime,
    // required TickerProvider vsync,
  });

  factory Books2.fromJson(Map json) {
    var pic = json['picurl'] ?? '';
    var created = json['createddatetime'] ?? '';

    return Books2(
      bookid: json['id'] ?? 0,
      title: json['title'] ?? '',
      picurl: pic,
      createddatetime: created,
    );
  }

  Map toJson() {
    return {
      'bookid': bookid,
      'title': title,
      'picurl': picurl,
      'createddatetime': createddatetime,
    };
  }
}
