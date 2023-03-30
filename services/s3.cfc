component {

    variables.service = 's3';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.utils = variables.api.getUtils();
        variables.settings = arguments.settings;
        variables.emptyStringHash = hash( '', 'SHA-256' ).lcase();
        return this;
    }

    /**
    * Returns a list of all buckets owned by the authenticated sender of the request
    * http://docs.aws.amazon.com/AmazonS3/latest/API/RESTServiceGET.html
    */
    public any function listBuckets() {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var apiResponse = apiCall( requestSettings );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Returns some or all (up to 1000) of the objects in a bucket. You can use the request parameters as selection criteria to return a subset of the objects in a bucket.
    * http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGET.html
    * @Bucket the name of the bucket to list objects from
    * @Delimiter A delimiter is a character you use to group keys. All keys that contain the same string between the prefix, if specified, and the first occurrence of the delimiter after the prefix are grouped under a single result element, CommonPrefixes. If you don't specify the prefix parameter, then the substring starts at the beginning of the key.
    * @EncodingType Requests Amazon S3 to encode the response and specifies the encoding method to use. (Valid value: url)
    * @Marker Specifies the key to start with when listing objects in a bucket. Amazon S3 returns object keys in alphabetical order, starting with key after the marker in order.
    * @MaxKeys Sets the maximum number of keys returned in the response body. You can add this to your request if you want to retrieve fewer than the default 1000 keys.
    * @Prefix Limits the response to keys that begin with the specified prefix. You can use prefixes to separate a bucket into different groupings of keys. (You can think of using prefix to make groups in the same way you'd use a folder in a file system.)
    */
    public any function listBucket(
        required string Bucket,
        string Delimiter = '',
        string EncodingType = '',
        string Marker = '',
        numeric MaxKeys = 0,
        string Prefix = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { };
        for (
            var key in [
                'Delimiter',
                'EncodingType',
                'Marker',
                'Prefix'
            ]
        ) {
            if ( len( arguments[ key ] ) ) queryParams[ utils.parseKey( key ) ] = arguments[ key ];
        }
        if ( arguments.MaxKeys ) queryParams[ utils.parseKey( 'MaxKeys' ) ] = arguments.MaxKeys;

        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/',
            queryParams
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
            if ( apiResponse.data.keyExists( 'Contents' ) && !isArray( apiResponse.data.Contents ) ) {
                apiResponse.data.Contents = [ apiResponse.data.Contents ];
            }
        }
        return apiResponse;
    }

    /**
    * Returns some or all (up to 1000) of the objects in a bucket. You pass returned ContinuationToken to next request to get next set of records
    * https://docs.aws.amazon.com/AmazonS3/latest/API/API_ListObjectsV2.html
    * @Bucket the name of the bucket to list objects from
    * @Delimiter A delimiter is a character you use to group keys. All keys that contain the same string between the prefix, if specified, and the first occurrence of the delimiter after the prefix are grouped under a single result element, CommonPrefixes. If you don't specify the prefix parameter, then the substring starts at the beginning of the key.
    * @EncodingType Requests Amazon S3 to encode the response and specifies the encoding method to use. (Valid value: url)
    * @Marker Specifies the key to start with when listing objects in a bucket. Amazon S3 returns object keys in alphabetical order, starting with key after the marker in order.
    * @MaxKeys Sets the maximum number of keys returned in the response body. You can add this to your request if you want to retrieve fewer than the default 1000 keys.
    * @Prefix Limits the response to keys that begin with the specified prefix. You can use prefixes to separate a bucket into different groupings of keys. (You can think of using prefix to make groups in the same way you'd use a folder in a file system.)
    * @ContinuationToken If this is passed we will get next set of records
    */

    public any function listBucketV2(
        required string Bucket,
        string Delimiter = '',
        string EncodingType = '',
        string Marker = '',
        numeric MaxKeys = 0,
        string Prefix = '',
        string ContinuationToken = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'list-type': 2 };
        for (
            var key in [
                'Delimiter',
                'EncodingType',
                'Marker',
                'Prefix',
                'ContinuationToken'
            ]
        ) {
            if ( len( arguments[ key ] ) ) queryParams[ utils.parseKey( key ) ] = arguments[ key ];
        }
        if ( arguments.MaxKeys ) queryParams[ utils.parseKey( 'MaxKeys' ) ] = arguments.MaxKeys;

        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/',
            queryParams
        );

        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
            if ( apiResponse.data.keyExists( 'Contents' ) && !isArray( apiResponse.data.Contents ) ) {
                apiResponse.data.Contents = [ apiResponse.data.Contents ];
            }
        }
        return apiResponse;
    }

    /**
    * This operation is useful to determine if a bucket exists and you have permission to access it.
    * http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketHEAD.html
    * @Bucket the name of the bucket
    */
    public any function getBucketAccess(
        required string Bucket
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var apiResponse = apiCall( requestSettings, 'HEAD' );
        return apiResponse;
    }

    /**
    * Used to retrieve various bucket settings
    * http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketOps.html
    * @Bucket the name of the bucket
    * @Setting the setting to retrieve. Valid settings are: acl | cors | lifecycle | location | logging | notification | policy | tagging | requestPayment | versioning | website
    */
    public any function getBucketSetting(
        required string Bucket,
        required string Setting
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var validSettings = [
            'acl',
            'cors',
            'lifecycle',
            'location',
            'logging',
            'notification',
            'policy',
            'tagging',
            'requestPayment',
            'versioning',
            'website'
        ];
        var returnedXmlElement = [
            'AccessControlPolicy',
            'CORSConfiguration',
            'LifecycleConfiguration',
            'LocationConstraint',
            'BucketLoggingStatus',
            'NotificationConfiguration',
            '',
            'Tagging',
            'RequestPaymentConfiguration',
            'VersioningConfiguration',
            'WebsiteConfiguration'
        ];
        var typeIndex = validSettings.findNoCase( Setting );
        if ( !typeIndex ) {
            throw( 'Invalid setting specified. Valid options are: #validSettings.toList( ', ' )#' );
        }
        var queryParams = { '#validSettings[ typeIndex ]#': '' };
        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/',
            queryParams
        );
        if ( apiResponse.statusCode == 200 ) {
            if ( Setting != 'policy' ) {
                apiResponse[ 'data' ] = utils.parseXmlElement( apiResponse.rawData, returnedXmlElement[ typeIndex ] );
            } else {
                apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );
            }
        }
        return apiResponse;
    }

    /**
    * Used to list metadata about all of the versions of objects in a bucket.
    * http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketGETVersion.html
    * @Bucket the name of the bucket
    * @Delimiter A delimiter is a character that you specify to group keys. All keys that contain the same string between the prefix and the first occurrence of the delimiter are grouped under a single result element in CommonPrefixes.
    * @EncodingType Requests Amazon S3 to encode the response and specifies the encoding method to use. (Valid value: url)
    * @KeyMarker Specifies the key in the bucket that you want to start listing from.
    * @MaxKeys Sets the maximum number of keys returned in the response body.
    * @Prefix Use this parameter to select only those keys that begin with the specified prefix. You can use prefixes to separate a bucket into different groupings of keys. (You can think of using prefix to make groups in the same way you'd use a folder in a file system.)
    * @VersionIdMarker Specifies the object version you want to start listing from.
    */
    public any function listBucketObjectVersions(
        required string Bucket,
        string Delimiter = '',
        string EncodingType = '',
        string KeyMarker = '',
        numeric MaxKeys = 0,
        string Prefix = '',
        string VersionIdMarker = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'versions': '' };
        for (
            var key in [
                'Delimiter',
                'EncodingType',
                'KeyMarker',
                'Prefix',
                'VersionIdMarker'
            ]
        ) {
            if ( len( arguments[ key ] ) ) queryParams[ utils.parseKey( key ) ] = arguments[ key ];
        }
        if ( arguments.MaxKeys ) queryParams[ utils.parseKey( 'MaxKeys' ) ] = arguments.MaxKeys;

        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/',
            queryParams
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * This operation lists in-progress multipart uploads. An in-progress multipart upload is a multipart upload that has been initiated, using the Initiate Multipart Upload request, but has not yet been completed or aborted.
    * http://docs.aws.amazon.com/AmazonS3/latest/API/mpUploadListMPUpload.html
    * @Bucket the name of the bucket
    * @Delimiter Character you use to group keys.
    * @EncodingType Requests Amazon S3 to encode the response and specifies the encoding method to use. (Valid value: url)
    * @KeyMarker Together with UploadIdMarker, this parameter specifies the multipart upload after which listing should begin.
    * @MaxUploads Sets the maximum number of multipart uploads, from 1 to 1,000, to return in the response body.
    * @Prefix Lists in-progress uploads only for those keys that begin with the specified prefix. You can use prefixes to separate a bucket into different grouping of keys.
    * @UploadIdMarker Together with KeyMarker, specifies the multipart upload after which listing should begin. If KeyMarker is not specified, the UploadIdMarker parameter is ignored.
    */
    public any function listMultipartUploads(
        required string Bucket,
        string Delimiter = '',
        string EncodingType = '',
        string KeyMarker = '',
        numeric MaxUploads = 0,
        string Prefix = '',
        string UploadIdMarker = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'uploads': '' };
        for (
            var key in [
                'Delimiter',
                'EncodingType',
                'KeyMarker',
                'Prefix',
                'UploadIdMarker'
            ]
        ) {
            if ( len( arguments[ key ] ) ) queryParams[ utils.parseKey( key ) ] = arguments[ key ];
        }
        if ( arguments.MaxUploads ) queryParams[ utils.parseKey( 'MaxUploads' ) ] = arguments.MaxUploads;

        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/',
            queryParams
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }


    /**
    * This action initiates a multipart upload and returns an upload ID. This upload ID is used to associate all of the parts in the specific multipart upload. You specify this upload ID in each of your subsequent upload part requests (see UploadPart). You also include this upload ID in the final request to either complete or abort the multipart upload request.
    * https://docs.aws.amazon.com/AmazonS3/latest/API/API_CreateMultipartUpload.html
    * @Bucket The name of the bucket to which to initiate the upload
    * @Key Object key for which the multipart upload is to be initiated.
    */
    public any function createMultipartUpload(
        required string Bucket,
        required string Key
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'uploads': '' };

        var apiResponse = apiCall(
            requestSettings,
            'POST',
            '/#arguments.Key#',
            queryParams
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Uploads a part in a multipart upload.
    * https://docs.aws.amazon.com/AmazonS3/latest/API/API_UploadPart.html
    * @Bucket The name of the bucket to which the multipart upload was initiated.
    * @Key Object key for which the multipart upload was initiated.
    * @UploadId Upload ID identifying the multipart upload whose part is being uploaded.
    * @PartNumber Part number of part being uploaded. This is a positive integer between 1 and 10,000.
    * @body the binary content of the file part
    */
    public any function putPart(
        required string Bucket,
        required string Key,
        required string UploadId,
        required numeric PartNumber,
        required any body
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'partNumber': arguments.PartNumber, 'uploadId': arguments.UploadId };

        var apiResponse = apiCall(
            requestSettings,
            'PUT',
            '/#arguments.Key#',
            queryParams,
            { },
            arguments.body
        );
        return apiResponse;
    }

    /**
    * Completes a multipart upload by assembling previously uploaded parts.
    * https://docs.aws.amazon.com/AmazonS3/latest/API/API_CompleteMultipartUpload.html
    * @Bucket The name of the bucket to which the multipart upload was initiated.
    * @Key Object key for which the multipart upload was initiated.
    * @UploadId ID for the initiated multipart upload.
    * @Parts Array of CompletedPart data types.
    */
    public any function completeMultipartUpload(
        required string Bucket,
        required string Key,
        required string UploadId,
        required array Parts
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'uploadId': arguments.UploadId };
        var payload = getPartsPayload( Parts );

        var apiResponse = apiCall(
            requestSettings,
            'POST',
            '/#arguments.Key#',
            queryParams,
            { },
            toString( payload )
        );

        return apiResponse;
    }

    // ** modified version of generate presigned. Just for putting uploads

    public string function generatePresignedURLForPart(
        required string Bucket,
        required string Key,
        required numeric partNumber,
        required string uploadId,
        numeric Expires = 300,
        string VersionId = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var host = getHost( requestSettings );
        var path = arguments.Bucket.find( '.' ) ? '/' & arguments.Bucket : '';
        path &= '/' & Key;
        var queryParams = { 'partNumber': arguments.partNumber, 'uploadId': arguments.uploadId };
        if ( len( arguments.VersionId ) ) queryParams[ 'versionId' ] = arguments.VersionId;

        return api.signedUrl(
            variables.service,
            host,
            requestSettings.region,
            'PUT',
            path,
            queryParams,
            Expires,
            requestSettings.awsCredentials,
            false
        );
    }

    /**
    * creates a new bucket
    * http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketPUT.html
    * @Bucket the name of the bucket to create
    * @Acl The canned ACL to apply to the bucket you are creating. Valid values: private | public-read | public-read-write | authenticated-read | bucket-owner-read | bucket-owner-full-control
    * @Location Specifies the region where the bucket will be created. Valid values:  us-west-1 | us-west-2 | eu-west-1 | eu-central-1 | ap-southeast-1 | ap-northeast-1 | ap-southeast-2 | sa-east-1 (Empty for us-east-1)
    */
    public any function createBucket(
        required string Bucket,
        string Acl = '',
        string Location = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var headers = { };
        var payload = '';

        if ( len( arguments.Acl ) ) {
            headers[ 'X-Amz-Acl' ] = arguments.Acl;
        }

        if ( len( arguments.Location ) && arguments.Location != 'us-east-1' ) {
            payload = '<CreateBucketConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><LocationConstraint>#arguments.Location#</LocationConstraint></CreateBucketConfiguration>';
        }

        return apiCall(
            requestSettings,
            'PUT',
            '/',
            { },
            headers,
            payload
        );
    }

    /**
    * Deletes a bucket. All objects (including all object versions and delete markers) in the bucket must be deleted before the bucket itself can be deleted.
    * http://docs.aws.amazon.com/AmazonS3/latest/API/RESTBucketDELETE.html
    * @Bucket the name of the bucket to delete
    */
    public any function deleteBucket(
        required string Bucket
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        return apiCall( requestSettings, 'DELETE', '/' );
    }

    /**
    * Retrieve an Object from Amazon S3.
    * http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectGET.html
    * @Bucket the name of the bucket containing the object
    * @ObjectKey the object to get
    * @VersionId the specific version of an object to get (if versioning is enabled)
    */
    public any function getObject(
        required string Bucket,
        required string ObjectKey,
        string VersionId = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { };
        if ( len( arguments.VersionId ) ) queryParams[ 'versionId' ] = arguments.VersionId;
        return apiCall(
            requestSettings,
            'GET',
            '/' & ObjectKey,
            queryParams
        );
    }

    /**
    * Retrieve an Object's tags from Amazon S3.
    * https://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectGETtagging.html
    * @Bucket the name of the bucket containing the object
    * @ObjectKey the object to get
    * @VersionId the specific version of an object to get (if versioning is enabled)
    */
    public any function getObjectTagging(
        required string Bucket,
        required string ObjectKey,
        string VersionId = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'tagging': '' };
        if ( len( arguments.VersionId ) ) queryParams[ 'versionId' ] = arguments.VersionId;
        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/' & ObjectKey,
            queryParams
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Retrieves metadata from an object without returning the object itself.
    * http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectHEAD.html
    * @Bucket the name of the bucket containing the object
    * @ObjectKey the object to get metadata from
    * @VersionId the specific version of an object to get (if versioning is enabled)
    */
    public any function getObjectMetadata(
        required string Bucket,
        required string ObjectKey,
        string VersionId = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { };
        if ( len( arguments.VersionId ) ) queryParams[ 'versionId' ] = arguments.VersionId;
        var apiResponse = apiCall(
            requestSettings,
            'HEAD',
            '/' & ObjectKey,
            queryParams
        );
        return apiResponse;
    }

    /**
    * Return the access control list (ACL) of an object.
    * http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectGETacl.html
    * @Bucket the name of the bucket containing the object
    * @ObjectKey The object to get the ACL for.
    * @VersionId the specific version of an object (if versioning is enabled)
    */
    public any function getObjectAcl(
        required string Bucket,
        required string ObjectKey,
        string VersionId = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'acl': '' };
        if ( len( arguments.VersionId ) ) queryParams[ 'versionId' ] = arguments.VersionId;
        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/' & ObjectKey,
            queryParams
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * returns a pre-signed URL that can be used to access an object
    * http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-query-string-auth.html
    * https://docs.aws.amazon.com/AmazonS3/latest/API/API_GetObject.html (Overriding Response Header Values)
    * queryParams = { "response-content-disposition": "attachment" } is useful for forcing a download
    * @Bucket The name of the bucket containing the object
    * @ObjectKey The object key
    * @Expires The length of time in seconds for which the url is valid
    * @VersionId the specific version of an object to get (if versioning is enabled)
    */
    public string function generatePresignedURL(
        required string Bucket,
        required string ObjectKey,
        numeric Expires = 300,
        string VersionId = '',
        struct queryParams = { }
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var host = getHost( requestSettings );
        var path = arguments.Bucket.find( '.' ) ? '/' & arguments.Bucket : '';
        path &= '/' & arguments.ObjectKey;

        if ( len( arguments.VersionId ) ) arguments.queryParams[ 'versionId' ] = arguments.VersionId;

        return api.signedUrl(
            variables.service,
            host,
            requestSettings.region,
            'GET',
            path,
            arguments.queryParams,
            Expires,
            requestSettings.awsCredentials,
            false
        );
    }

    /**
    * adds an object to a bucket
    * http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectPUT.html
    * @Bucket the name of the bucket containing the object
    * @ObjectKey the object key
    * @FileContent the content of the file
    * @Acl Specify a canned ACL. Valid values: private | public-read | public-read-write | authenticated-read | bucket-owner-read | bucket-owner-full-control
    * @CacheControl Can be used to specify caching behavior along the request/reply chain.
    * @ContentDisposition Specifies presentational information for the object.
    * @ContentEncoding Specifies what content encodings have been applied to the object and thus what decoding mechanisms must be applied to obtain the media-type referenced by the Content-Type header field.
    * @ContentType A standard MIME type describing the format of the contents.
    * @Expires The date and time at which the object is no longer cacheable.
    * @Metadata Used to store user-defined metadata. Struct keys are prefixed with 'x-amz-meta-' and sent as headers in the put request.
    * @StorageClass The storage class for the file. Valid values: STANDARD | STANDARD_IA | REDUCED_REDUNDANCY
    * @WebsiteRedirectLocation If the bucket is configured as a website, redirects requests for this object to another object in the same bucket or to an external URL.
    *
    * Example:  aws.s3.putObject( 'your-bucket-name', 'filename.ext', fileReadBinary( pathToFile ), '', '', '', fileGetMimeType( pathToFile ) )
    * https://github.com/jcberquist/aws-cfml/issues/25
    */
    public any function putObject(
        required string Bucket,
        required string ObjectKey,
        required any FileContent,
        string Acl = '',
        string CacheControl = '',
        string ContentDisposition = '',
        string ContentEncoding = '',
        string ContentType = '',
        string Expires = '',
        struct Metadata = { },
        string StorageClass = '',
        string WebsiteRedirectLocation = '',
        numeric timeout = 0
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var headers = { };

        headers[ 'Content-MD5' ] = binaryEncode( binaryDecode( hash( FileContent, 'MD5', 'utf-8' ), 'hex' ), 'base64' );

        for (
            var key in [
                'CacheControl',
                'ContentDisposition',
                'ContentEncoding',
                'ContentType',
                'Expires'
            ]
        ) {
            if ( len( arguments[ key ] ) ) headers[ utils.parseKey( key ) ] = arguments[ key ];
        }

        for ( var key in [ 'Acl', 'StorageClass', 'WebsiteRedirectLocation' ] ) {
            if ( len( arguments[ key ] ) ) headers[ 'X-Amz-' & utils.parseKey( key ) ] = arguments[ key ];
        }

        for ( var key in arguments.Metadata ) {
            headers[ 'X-Amz-Meta-' & key ] = arguments.Metadata[ key ];
        }

        var apiResponse = apiCall(
            requestSettings,
            'PUT',
            '/' & ObjectKey,
            { },
            headers,
            FileContent,
            timeout
        );
        return apiResponse;
    }


    /**
    * Creates a copy of an object that is already stored in Amazon S3.
    * http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectCOPY.html
    * @SourceBucket the name of the bucket containing the source object
    * @SourceObjectKey the source object key
    * @DestinationBucket the name of the bucket for the destination object
    * @DestinationObjectKey the destination object key
    * @Acl Specify a canned ACL for the destination object. Valid values: private | public-read | public-read-write | authenticated-read | bucket-owner-read | bucket-owner-full-control
    * @ContentDisposition Specifies presentational information for the destination object.
    * @ContentType A standard MIME type describing the format of the destination object.
    * @StorageClass The storage class for the destination object. Valid values: STANDARD | STANDARD_IA | REDUCED_REDUNDANCY
    * @WebsiteRedirectLocation If the bucket is configured as a website, redirects requests for the destination object to another object in the same bucket or to an external URL.
    * @VersionId The specific version of the source object (if versioning is enabled).
    */
    public any function copyObject(
        required string SourceBucket,
        required string SourceObjectKey,
        required string DestinationBucket,
        required string DestinationObjectKey,
        string Acl = '',
        string ContentDisposition = '',
        string ContentType = '',
        string StorageClass = '',
        string WebsiteRedirectLocation = '',
        string VersionId = ''
    ) {
        arguments.Bucket = arguments.DestinationBucket;
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var headers = { };
        headers[ 'X-Amz-Copy-Source' ] = '/' & SourceBucket & '/' & SourceObjectKey;
        if ( len( arguments.VersionId ) ) headers[ 'X-Amz-Copy-Source' ] &= '?versionId=' & arguments.VersionId;


        for ( var key in [ 'ContentDisposition', 'ContentType' ] ) {
            if ( len( arguments[ key ] ) ) headers[ utils.parseKey( key ) ] = arguments[ key ];
        }

        for ( var key in [ 'Acl', 'StorageClass', 'WebsiteRedirectLocation' ] ) {
            if ( len( arguments[ key ] ) ) headers[ 'X-Amz-' & utils.parseKey( key ) ] = arguments[ key ];
        }

        var apiResponse = apiCall(
            requestSettings,
            'PUT',
            '/' & destinationObjectKey,
            { },
            headers
        );
        apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        return apiResponse;
    }

    /**
    * Deletes an object
    * http://docs.aws.amazon.com/AmazonS3/latest/API/RESTObjectDELETE.html
    * @Bucket the name of the bucket containing the object
    * @ObjectKey the object key
    * @VersionId the specific version of an object to delete (if versioning is enabled)
    */
    public any function deleteObject(
        required string Bucket,
        required string ObjectKey,
        string VersionId = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { };
        if ( len( arguments.VersionId ) ) queryParams[ 'versionId' ] = arguments.VersionId;
        return apiCall(
            requestSettings,
            'DELETE',
            '/' & objectKey,
            queryParams
        );
    }

    /**
    * Enables you to delete multiple objects from a bucket using a single HTTP request
    * http://docs.aws.amazon.com/AmazonS3/latest/API/multiobjectdeleteapi.html
    * @Bucket the name of the bucket containing the object
    * @ObjectKeys array of object keys to delete, elements can be any mix of string object keys or structs with 'ObjectKey' and optionally 'VersionId' keys
    * @Quiet By default, the operation uses verbose mode in which the response includes the result of deletion of each key in your request. In quiet mode the response includes only keys where the delete operation encountered an error. For a successful deletion, the operation does not return any information about the delete in the response body.
    */
    public any function deleteMultipleObjects(
        required string Bucket,
        required array ObjectKeys,
        boolean Quiet = false
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var xmlBody = '<?xml version="1.0" encoding="UTF-8"?>#chr( 10 )#<Delete>';
        xmlBody &= '<Quiet>' & ( Quiet ? 'true' : 'false' ) & '</Quiet>';
        ObjectKeys.each( function( item ) {
            // create an empty key/version struct
            var objectKey = { 'ObjectKey': '', 'VersionId': '' };
            // if the ObjectKey element is a struct, check for an object key and versionid keys/values
            if ( isStruct( item ) ) {
                objectKey[ 'ObjectKey' ] = item.keyExists( 'ObjectKey' ) ? item.ObjectKey : '';
                objectKey[ 'VersionId' ] = item.keyExists( 'VersionId' ) ? item.VersionId : '';
            }
            // if the ObjectKey element is a simple value assume it's an object key
            else if ( isSimpleValue( item ) ) {
                objectKey[ 'ObjectKey' ] = item;
            }
            // create the xml node if there is a key
            if ( len( objectKey[ 'ObjectKey' ] ) ) {
                xmlBody &= '<Object><Key>#encodeForXML( objectKey[ 'ObjectKey' ] )#</Key>';
                if ( len( objectKey.versionid ) ) {
                    xmlBody &= '<VersionId>#encodeForXML( objectKey[ 'VersionId' ] )#</VersionId>';
                }
                xmlBody &= '</Object>';
            }
        } );
        xmlBody &= '</Delete>';

        var headers = { };
        headers[ 'X-Amz-Content-Sha256' ] = hash( xmlBody, 'SHA-256' ).lcase();
        headers[ 'Content-MD5' ] = binaryEncode( binaryDecode( hash( xmlBody, 'MD5', 'utf-8' ), 'hex' ), 'base64' );

        var queryParams = { 'delete': '' };
        var apiResponse = apiCall(
            requestSettings,
            'POST',
            '/',
            queryParams,
            headers,
            xmlBody
        );
        apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        return apiResponse;
    }

    /**
    * helper function for browser based upload using POST - returns an array of structs containing 'name' and 'value' keys to be added to the browser form as input fields
    * http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-UsingHTTPPOST.html
    * @Bucket the name of the bucket containing the object.
    * @ObjectKey The object key to store the uploaded file at.
    * @FormFields An array of form fields that are are going to be included in the browser POST to s3
    * @MaxSize The maximum size in bytes that an uploaded file can be.
    * @Expires How long in seconds that the POST authorization is valid for.
    */
    public array function getFormPostParams(
        required string Bucket,
        required any ObjectKey,
        array FormFields = [ ],
        numeric MaxSize = 0,
        numeric Expires = 300
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var requestTime = now();
        var isoTime = utils.iso8601( requestTime );
        var postParams = [ ];

        var expiration = utils.iso8601Full( dateAdd( 's', expires, requestTime ) );
        var conditions = [ { 'name': 'bucket', 'value': bucket } ];
        if ( isSimpleValue( objectKey ) ) objectKey = { 'name': 'key', 'value': objectKey };
        conditions.append( objectKey );

        postParams.append( objectKey );

        // passed in form fields also need to be added to policy conditions
        conditions.append( FormFields, true );
        // is there a max size?
        if ( maxSize > 0 ) conditions.append( [ 'content-length-range', 0, maxSize ] );

        var authParams = api
            .authorizationParams(
                variables.service,
                requestSettings.region,
                isoTime,
                requestSettings.awsCredentials
            )
            .reduce( function( authParamArray, key, value ) {
                authParamArray.append( { 'name': key, 'value': value } );
                return authParamArray;
            }, [ ] );
        conditions.append( authParams, true );
        postParams.append( authParams, true );

        // build policy
        var policy = {
            'expiration': expiration,
            'conditions': conditions.map( function( item ) {
                if ( isArray( item ) ) return item;
                if ( item.keyExists( 'startsWith' ) ) return [ 'starts-with', '$' & item.name, item.startsWith ];
                return { '#item.name#': item.value };
            } )
        };
        var policyString = reReplace(
            serializeJSON( policy ),
            '[\r\n]+',
            '',
            'all'
        );
        var base64Policy = binaryEncode( charsetDecode( policyString, 'utf-8' ), 'base64' );

        postParams.append( { 'name': 'Policy', 'value': base64Policy } );
        postParams.append( {
            'name': 'X-Amz-Signature',
            'value': api.sign(
                requestSettings.awsCredentials,
                isoTime.left( 8 ),
                requestSettings.region,
                service,
                base64Policy
            )
        } );
        return postParams;
    }


    // private

    private xml function getPartsPayload(
        required Array Parts
    ) {
        var ret = '<?xml version="1.0" encoding="UTF-8"?>';
        ret &= '<CompleteMultipartUpload xmlns="http://s3.amazonaws.com/doc/2006-03-01/">';

        for ( var part in arguments.Parts ) {
            ret &= '<Part><ETag>#part.ETag#</ETag><PartNumber>#part.PartNumber#</PartNumber></Part>';
        }

        ret &= '</CompleteMultipartUpload>'
        return xmlParse( ret );
    }

    private string function getHost(
        required struct requestSettings
    ) {
        if ( structKeyExists( variables.settings, 'host' ) && len( variables.settings.host ) ) {
            var host = variables.settings.host;
        } else {
            var host = variables.service & ( requestSettings.region == 'us-east-1' ? '' : '-' & requestSettings.region ) & '.amazonaws.com';
        }
        if (
            requestSettings.keyExists( 'bucket' ) &&
            len( requestSettings.bucket ) &&
            !requestSettings.bucket.find( '.' )
        ) {
            host = listPrepend( host, requestSettings.bucket, '.' );
        }
        return host;
    }

    private any function apiCall(
        required struct requestSettings,
        string httpMethod = 'GET',
        string path = '/',
        struct queryParams = { },
        struct headers = { },
        any payload = '',
        numeric timeout = 0
    ) {
        var host = getHost( requestSettings );

        if (
            requestSettings.keyExists( 'bucket' ) &&
            len( requestSettings.bucket ) &&
            requestSettings.bucket.find( '.' )
        ) {
            path = '/' & requestSettings.bucket & path;
        }

        if ( !isSimpleValue( payload ) || len( payload ) ) {
            headers[ 'X-Amz-Content-Sha256' ] = hash( payload, 'SHA-256' ).lcase();
        } else {
            headers[ 'X-Amz-Content-Sha256' ] = variables.emptyStringHash;
        }

        var useSSL = !structKeyExists( variables.settings, 'useSSL' ) || variables.settings.useSSL;


        return api.call(
            variables.service,
            host,
            requestSettings.region,
            httpMethod,
            path,
            queryParams,
            headers,
            payload,
            requestSettings.awsCredentials,
            false,
            useSSL,
            timeout
        );
    }

}
