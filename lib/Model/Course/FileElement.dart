class FileElement {
  FileElement({
    this.id,
    this.courseId,
    this.fileName,
    this.file,
    this.lock,
    this.status,
  });

  dynamic id;
  dynamic courseId;
  String? fileName;
  String? file;
  dynamic lock;
  dynamic status;

  factory FileElement.fromJson(Map<String, dynamic> json) => FileElement(
        id: json["id"],
        courseId: json["course_id"],
        fileName: json["fileName"],
        file: json["file"],
        lock: json["lock"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "course_id": courseId,
        "fileName": fileName,
        "file": file,
        "lock": lock,
        "status": status,
      };
}
