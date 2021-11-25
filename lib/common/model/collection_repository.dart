import 'package:ah/common/model/collection_cache.dart';
import 'package:ah/common/model/data/error.dart';
import 'package:ah/common/model/data/models.dart';
import 'package:ah/common/model/network/api.dart';
import 'package:ah/common/utils/either_option_extensions.dart';
import 'package:either_option/either_option.dart';

class CollectionRepository {
  CollectionRepository(this.remote, this.cache);

  RijksDataApi remote;
  CollectionCache cache;

  Future<Either<RemoteError, List<ArtObject>>> getCollection() async {
    final result = await remote.getCollection();
    result.doOnRight((collection) async => cache.storeArtObjects(collection));
    return result;
  }

  ///returns short model if available, then tries to load full model and if unable returns error
  Stream<Either<RemoteError, ArtObject>> getArtObject(String artObjectId) async* {
    final cachedArtObject = cache.getArtObjectByNumber(artObjectId);
    if (cachedArtObject != null) {
      yield Right(cachedArtObject);
    }

    yield await remote.getArtObject(artObjectId);
  }
}
