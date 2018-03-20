
// Imports the Google Cloud client library
const Storage = require('@google-cloud/storage');

// Creates a client
const storage = new Storage();

/**
 * TODO(developer): Uncomment the following lines before running the sample.
 */
const bucketName = 'ag_connected_sfdc_event_logs';
const filename = '2018-03-16_15-1_Search.csv';

// Gets the metadata for the file
storage
  .bucket(bucketName)
  .file(filename)
  .getMetadata()
  .then(results => {
    const metadata = results[0];

    console.log(`File: ${metadata.name}`);
    console.log(`Bucket: ${metadata.bucket}`);
    console.log(`Storage class: ${metadata.storageClass}`);
    console.log(`Self link: ${metadata.selfLink}`);
    console.log(`ID: ${metadata.id}`);
    console.log(`Size: ${metadata.size}`);
    console.log(`Updated: ${metadata.updated}`);
    console.log(`Generation: ${metadata.generation}`);
    console.log(`Metageneration: ${metadata.metageneration}`);
    console.log(`Etag: ${metadata.etag}`);
    console.log(`Owner: ${metadata.owner}`);
    console.log(`Component count: ${metadata.component_count}`);
    console.log(`Crc32c: ${metadata.crc32c}`);
    console.log(`md5Hash: ${metadata.md5Hash}`);
    console.log(`Cache-control: ${metadata.cacheControl}`);
    console.log(`Content-type: ${metadata.contentType}`);
    console.log(`Content-disposition: ${metadata.contentDisposition}`);
    console.log(`Content-encoding: ${metadata.contentEncoding}`);
    console.log(`Content-language: ${metadata.contentLanguage}`);
    console.log(`Metadata: ${metadata.metadata}`);
    console.log(`Media link: ${metadata.mediaLink}`);
  })
  .catch(err => {
    console.error('ERROR:', err);
  });