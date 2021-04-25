class VideoListSnippetTag {
  final String _title;
  final String _desc;

  VideoListSnippetTag(this._title, this._desc);

  factory VideoListSnippetTag.fromJson(dynamic json) {
    return VideoListSnippetTag(
        json['title'] as String, json['description'] as String);
  }

  String get title => _title;

  @override
  String toString() {
    return '{${this._title}, ${this._desc}}';
  }
}

class VideoListTag {
  final String _id;
  final VideoListSnippetTag _snippet;

  VideoListTag(this._id, this._snippet);

  factory VideoListTag.fromJson(dynamic json) {
    return VideoListTag(
        json['id'] as String, VideoListSnippetTag.fromJson(json['snippet']));
  }

  String get id => _id;
  VideoListSnippetTag get snippet => _snippet;

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': snippet.title};
  }

  Map toJson() => {
        'id': id,
        'title': snippet.title,
      };

  @override
  String toString() {
    return '{${this._id}, ${this._snippet}}';
  }
}

class VideoItemTag {
  final String _id;
  final VideoItemSnippetTag _snippet;
  final VideoItemStatusTag _status;

  VideoItemTag(this._id, this._snippet, this._status);

  factory VideoItemTag.fromJson(dynamic json) {
    return VideoItemTag(
        json['id'] as String,
        VideoItemSnippetTag.fromJson(json['snippet']),
        VideoItemStatusTag.fromJson(json['status']));
  }

  Map toJson() => {
        'id': _id,
        'title': _snippet._title,
        'videoId': _snippet._videoId._videoId,
        'status': _status._privacyStatus,
        'position': _snippet._position,
      };

  @override
  String toString() {
    return '{${this._id}, ${this._snippet}}';
  }
}

class VideoItemSnippetTag {
  final String _title;
  final int _position;
  final VideoItemResourceTag _videoId;

  VideoItemSnippetTag(this._title, this._position, this._videoId);

  factory VideoItemSnippetTag.fromJson(dynamic json) {
    return VideoItemSnippetTag(json['title'] as String, json['position'] as int,
        VideoItemResourceTag.fromJson(json['resourceId']));
  }

  @override
  String toString() {
    return '{${this._title}, ${this._position}, ${this._videoId}}';
  }
}

class VideoItemResourceTag {
  final String _videoId;

  VideoItemResourceTag(this._videoId);

  factory VideoItemResourceTag.fromJson(dynamic json) {
    return VideoItemResourceTag(json['videoId'] as String);
  }

  @override
  String toString() {
    return '{${this._videoId}}';
  }
}

class VideoItemStatusTag {
  final String _privacyStatus;

  VideoItemStatusTag(this._privacyStatus);

  factory VideoItemStatusTag.fromJson(dynamic json) {
    return VideoItemStatusTag(json['privacyStatus'] as String);
  }

  @override
  String toString() {
    return '{${this._privacyStatus}}';
  }
}

class VideoItemListTag {
  final String _nextPageToken;
  final String _prevPageToken;
  final List<VideoItemTag> _items;
  final int _totalResults;

  VideoItemListTag(this._nextPageToken, this._prevPageToken, this._items,
      this._totalResults);

  Map toJson() => {
        'nextPageToken': _nextPageToken,
        'prevPageToken': _prevPageToken,
        'items': _items,
        'totalResults': _totalResults,
      };
}

class UploadVideoStatusTag {
  final String privacyStatus = "unlisted";
  final bool selfDeclaredMadeForKids = true;
  final bool embeddable = true;
  final bool madeForKids = true;

  Map toJson() => {
        'privacyStatus': privacyStatus,
        'embeddable': embeddable,
        'madeForKids': madeForKids,
        'selfDeclaredMadeForKids': selfDeclaredMadeForKids,
      };
}

class UploadVideoSnippetTag {
  final String categoryId = "22";
  final String title;
  final String className;

  UploadVideoSnippetTag(this.title, this.className);

  Map toJson() => {
        'categoryId': categoryId,
        'description':
            'Educational video for class $className of Khela Ghar Montessory School.',
        'title': title
      };
}

class UploadVideoUpdateTag {
  final String id;
  final UploadVideoSnippetTag snippet;
  final UploadVideoStatusTag status;

  UploadVideoUpdateTag(this.id, [this.snippet, this.status]);

  Map toJson() {
    Map snippet = this.snippet != null ? this.snippet.toJson() : null;
    Map status = this.status != null ? this.status.toJson() : null;
    return {'id': id, 'snippet': snippet, 'status': status};
  }
}

class UpdateVideoPlaylistResourceTag {
  final String kind = 'youtube#video';
  final String videoId;

  UpdateVideoPlaylistResourceTag(this.videoId);

  Map toJson() => {'kind': kind, 'videoId': videoId};
}

class UpdateVideoPlaylistSnippetTag {
  final String playlistId;
  final int position = 0;
  final UpdateVideoPlaylistResourceTag resourceId;

  UpdateVideoPlaylistSnippetTag(this.playlistId, [this.resourceId]);

  Map toJson() {
    Map resourceId = this.resourceId != null ? this.resourceId.toJson() : null;
    return {
      'playlistId': playlistId,
      'position': position,
      'resourceId': resourceId
    };
  }
}

class UpdateVideoPlaylistTag {
  final UpdateVideoPlaylistSnippetTag snippet;

  UpdateVideoPlaylistTag([this.snippet]);

  Map toJson() {
    Map snippet = this.snippet != null ? this.snippet.toJson() : null;
    return {'snippet': snippet};
  }
}

//class UserChannelUploadedVideoPlaylistId {
//  final String UploadedVideoPlaylistId;

//  UserChannelUploadedVideoPlaylistId(this);
//}

//class PlaylistDetail {
//  final String etag;
//  final List<VideoListTag> playlistTag;

//  PlaylistDetail(this.etag, this.playlistTag);

//  @override
//  String toString() {
//    return '{${this.etag}, ${this.playlistId}}';
//  }
//}
