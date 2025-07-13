// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reddit_post.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RedditPostAdapter extends TypeAdapter<RedditPost> {
  @override
  final int typeId = 8;

  @override
  RedditPost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RedditPost(
      id: fields[0] as String?,
      title: fields[1] as String?,
      subreddit: fields[12] as String,
      author: fields[3] as String?,
      thumbnail: fields[14] as String,
      content: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RedditPost obj) {
    writer
      ..writeByte(15)
      ..writeByte(12)
      ..write(obj.subreddit)
      ..writeByte(14)
      ..write(obj.thumbnail)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.author)
      ..writeByte(4)
      ..write(obj.petType)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.upvotes)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.editedAt)
      ..writeByte(9)
      ..write(obj.postType)
      ..writeByte(10)
      ..write(obj.redditUrl)
      ..writeByte(11)
      ..write(obj.comments)
      ..writeByte(13)
      ..write(obj.isSaved);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RedditPostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
