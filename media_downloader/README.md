# MediaDownloader

`MediaDownloader` is designed to facilitate the downloading, storing, and retrieving of media content such as image, audio, and video files. Flutter does not have a built-in feature to accommodate this, and 3rd party libraries appear to be flaky or glitchy.

### Adding this dependency

Add this dependency to your `pubspec.yaml`:

```yaml
media_downloader:
  git:
    url: https://github.com/MyOxygen/MyOxygen-Flutter-Libraries.git
    path: media_downloader
    ref: MediaDownloader-v0.0.2 # Use the latest MediaDownloader tag!!
```

### MediaDownloader's APIs - `FileDownloader`

- `FileDownloader`
  - Constructor for the `FileDownloader` class.
  - Parameters:
    - `fileSystem` - A class to handle the OS's file system. This can be set to simply `FileSystem()`.
    - `client` - A `Client` from the `http` library. This is used to fetch the media content.
  - Returns: new instance of the class `FileDownloader`.
- `download`
  - Downloads a file from a URL. If the file already exists, no call will be made, and the saved file is returned.
  - Parameters:
    - `url` - The URL of the file to download.
    - `fileName` - The name to give to the file about to download.
  - Returns: `Future<File>`, where `File` is either the existing file or the newly downloaded file.

### MediaDownloader's APIs - `BaseFileLoader<T>`

- `BaseFileLoader`
  - Constructor for the `BaseFileLoader<T>` class.
  - Parameters:
    - `fileDownloader` - The class used to download a file.
  - Returns: new instance of the class `BaseFileLoader<T>`.
- `dataForContent` [Abstract]
  - Defines the filename and the ID for the cache.
  - Parameters:
    - `content` - Object containing information like the filename and media URL.
  - Returns: `ContentFileData`, which contains the filename and the URl of the media.
- `delete`
  - Deletes a file in cache with the specific filename.
  - Parameters:
    - `content` - Object expected to delete.
  - Returns: `Future<void>`.
- `deleteWhere`
  - Deletes one or more files in cache matching the specific `where` condition.
  - Parameters:
    - `test` - The condition to be met for finding a file to delete.
  - Returns: `Future<void>`.
- `download`
  - Downloads a file to cache.
  - Parameters:
    - `content` - Object expected to download.
  - Returns: `Future<File>`, where `File` is either the existing file or the newly downloaded file.
- `getFile`
  - Retrieves a file from cache.
  - Parameters:
    - `content` - Object containing information like the filename and media URL.
  - Returns: `Future<Optional<File>>`, where `File` is the existing file. If the existing file does not exist, `Optional` will be empty.
- `getFileExtension`
  - Retrieves the file extension from the URL provided.
  - Parameters:
    - `dataUrl` - The URL of the media about to download.
  - Returns: `String`.


