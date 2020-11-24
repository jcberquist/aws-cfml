component {

    variables.service = 'rekognition';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.apiVersion = arguments.settings.apiVersion;
        return this;
    }


    /**
    * Detects faces within an image that is provided as input.
    * https://docs.aws.amazon.com/rekognition/latest/dg/API_DetectFaces.html
    * @Image a struct with a "Bytes" key containing Base64-encoded binary data or an "S3Object" struct containing a "Bucket", "Key", and optional "Version" - https://docs.aws.amazon.com/rekognition/latest/dg/API_Image.html
    * @Attributes Optional. An array of facial attributes to be returned. Alternately, specify "DEFAULT" to include the default set of attributes, or "ALL" to include all attributes.
    */
    public any function detectFaces(
        required struct Image,
        array Attributes
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'Image': arguments.Image };
        if ( !isNull( arguments.Attributes ) ) args[ 'Attributes' ] = arguments.Attributes;

        return apiCall( requestSettings, 'DetectFaces', args );
    }

    /**
    * Detects instances of real-world entities within an image (JPEG or PNG) provided as input. This includes objects like flower, tree, and table; events like wedding, graduation, and birthday party; and concepts like landscape, evening, and nature.
    * https://docs.aws.amazon.com/rekognition/latest/dg/API_DetectLabels.html
    * @Image a struct with a "Bytes" key containing Base64-encoded binary data or an "S3Object" struct containing a "Bucket", "Key", and optional "Version" - https://docs.aws.amazon.com/rekognition/latest/dg/API_Image.html
    * @MaxLabels Optional numeric. Maximum number of labels you want the service to return in the response. The service returns the specified number of highest confidence labels.
    */
    public any function detectLabels(
        required struct Image,
        numeric MaxLabels
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'Image': arguments.Image };
        if ( !isNull( arguments.MaxLabels ) ) args[ 'MaxLabels' ] = arguments.MaxLabels;

        return apiCall( requestSettings, 'DetectLabels', args );
    }

    /**
    * Detects explicit or suggestive adult content in a specified JPEG or PNG format image.
    * https://docs.aws.amazon.com/rekognition/latest/dg/API_DetectModerationLabels.html
    * @Image a struct with a "Bytes" key containing Base64-encoded binary data or an "S3Object" struct containing a "Bucket", "Key", and optional "Version" - https://docs.aws.amazon.com/rekognition/latest/dg/API_Image.html
    * @MinConfidence Optional. Specifies the minimum confidence level for the labels to return. Amazon Rekognition doesn't return any labels with a confidence level lower than this specified value. Valid Values are 0 - 100. Default when argument is not provided is 50.
    */
    public any function detectModerationLabels(
        required struct Image,
        numeric MinConfidence
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'Image': arguments.Image };
        if ( !isNull( arguments.MinConfidence ) ) args[ 'MinConfidence' ] = arguments.MinConfidence;

        return apiCall( requestSettings, 'DetectModerationLabels', args );
    }

    /**
    * Detects text in the input image and converts it into machine-readable text.
    * https://docs.aws.amazon.com/rekognition/latest/dg/API_DetectText.html
    * @Image a struct with a "Bytes" key containing Base64-encoded binary data or an "S3Object" struct containing a "Bucket", "Key", and optional "Version" - https://docs.aws.amazon.com/rekognition/latest/dg/API_Image.html
    */
    public any function detectText(
        required struct Image
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        return apiCall( requestSettings, 'DetectText', { 'Image': arguments.Image } );
    }

    /**
    * Returns an array of celebrities recognized in the input image.
    * https://docs.aws.amazon.com/rekognition/latest/dg/API_RecognizeCelebrities.html
    * @Image a struct with a "Bytes" key containing Base64-encoded binary data or an "S3Object" struct containing a "Bucket", "Key", and optional "Version" - https://docs.aws.amazon.com/rekognition/latest/dg/API_Image.html
    */
    public any function recognizeCelebrities(
        required struct Image
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        return apiCall( requestSettings, 'RecognizeCelebrities', { 'Image': arguments.Image } );
    }

    /**
    * Returns an array of face matches ordered by similarity score in descending order
    * https://docs.aws.amazon.com/rekognition/latest/dg/API_CompareFaces.html
    * @SourceImage a struct with a "Bytes" key containing Base64-encoded binary data or an "S3Object" struct containing a "Bucket", "Key", and optional "Version" - https://docs.aws.amazon.com/rekognition/latest/dg/API_Image.html
    * @TargetImage a struct with a "Bytes" key containing Base64-encoded binary data or an "S3Object" struct containing a "Bucket", "Key", and optional "Version" - https://docs.aws.amazon.com/rekognition/latest/dg/API_Image.html
    * @SimilarityThreshold a numeric minimum level of confidence that a match must meet to be included. Valid Range: Minimum value of 0. Maximum value of 100.
    * @QualityFilter a string filter that specifies a quality bar for how much filtering is done to identify faces. Valid Values: NONE | AUTO | LOW | MEDIUM | HIGH
    */
    public any function compareFaces(
        required struct SourceImage,
        required struct TargetImage,
        numeric SimilarityThreshold,
        string QualityFilter
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var args = { 'SourceImage': arguments.SourceImage, 'TargetImage': arguments.TargetImage };
        if ( !isNull( arguments.SimilarityThreshold ) ) args[ 'SimilarityThreshold' ] = arguments.SimilarityThreshold;
        if ( !isNull( arguments.QualityFilter ) ) args[ 'QualityFilter' ] = arguments.QualityFilter;

        return apiCall( requestSettings, 'CompareFaces', args );
    }

    private any function apiCall(
        required struct requestSettings,
        required string target,
        struct payload = { }
    ) {
        var host = variables.service & '.' & requestSettings.region & '.amazonaws.com';

        var payloadString = payload.isEmpty() ? '' : serializeJSON( payload );
        var headers = { };
        headers[ 'X-Amz-Target' ] = 'RekognitionService.#target#';
        if ( !payload.isEmpty() ) headers[ 'Content-Type' ] = 'application/x-amz-json-1.1';

        var apiResponse = api.call(
            variables.service,
            host,
            requestSettings.region,
            'POST',
            '/',
            { },
            headers,
            payloadString,
            requestSettings.awsCredentials
        );
        apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );

        return apiResponse;
    }

}
