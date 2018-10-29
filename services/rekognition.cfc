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
	* Detects text in the input image and converts it into machine-readable text.
	* https://docs.aws.amazon.com/rekognition/latest/dg/API_DetectText.html
	* @Image See https://docs.aws.amazon.com/rekognition/latest/dg/API_DetectText.html for supported Image argument format
	*/
	public any function detectText(
		required struct Image
	) {
		var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
		return apiCall( requestSettings, 'POST', 'DetectText', { }, { "Image":arguments.Image } );
	}

	/**
	* Detects faces within an image that is provided as input.
	* https://docs.aws.amazon.com/rekognition/latest/dg/API_DetectFaces.html
	* @Attributes Optional. An array of string attributes you would like returned. Valid values are DEFAULT or ALL. 
	* @Image Required. https://docs.aws.amazon.com/rekognition/latest/dg/API_DetectFaces.html for supported Image argument format
	*/
	public any function detectFaces(
		required struct Image,
		array Attributes
	) {
		var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
		var args = {"Image":arguments.Image}
		if (!isnull(arguments.Attributes))
			args["Attributes"] = arguments.Attributes;
		
		return apiCall( requestSettings, 'POST', 'DetectFaces', { }, args );
	}

	/**
	* Returns an array of celebrities recognized in the input image.
	* https://docs.aws.amazon.com/rekognition/latest/dg/API_RecognizeCelebrities.html
	* @Image https://docs.aws.amazon.com/rekognition/latest/dg/API_RecognizeCelebrities.html for supported Image argument format
	*/
	public any function recognizeCelebrities(
		required struct Image
	) {
		var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
		return apiCall( requestSettings, 'POST', 'RecognizeCelebrities', { }, { "Image":arguments.Image } );
	}

	/**
	* Detects instances of real-world entities within an image (JPEG or PNG) provided as input. This includes objects like flower, tree, and table; events like wedding, graduation, and birthday party; and concepts like landscape, evening, and nature.
	* https://docs.aws.amazon.com/rekognition/latest/dg/API_DetectLabels.html
	* @Image Required. https://docs.aws.amazon.com/rekognition/latest/dg/API_DetectLabels.html for supported Image argument format
	* @MaxLabels Optional numeric. Maximum number of labels you want the service to return in the response. The service returns the specified number of highest confidence labels. 
	*/
	public any function detectLabels(
		required struct Image,
		numeric MaxLabels
	) {
		var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
		var args = {"Image":arguments.Image}
		if (!isnull(arguments.MaxLabels))
			args["MaxLabels"] = arguments.MaxLabels;
		
		return apiCall( requestSettings, 'POST', 'DetectLabels', { }, args );
	}

	/**
	* Detects explicit or suggestive adult content in a specified JPEG or PNG format image.
	* https://docs.aws.amazon.com/rekognition/latest/dg/API_DetectModerationLabels.html
	* @Image Required. https://docs.aws.amazon.com/rekognition/latest/dg/API_DetectModerationLabels.html for supported Image argument format
	* @MinConfidence Optional. Specifies the minimum confidence level for the labels to return. Amazon Rekognition doesn't return any labels with a confidence level lower than this specified value. Valid Values are 0 - 100. Default when argument is not provided is 50. 
	*/
	public any function detectModerationLabels(
		required struct Image,
		numeric MinConfidence
	) {
		var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
		var args = {"Image":arguments.Image}
		if (!isnull(arguments.MinConfidence))
			args["MinConfidence"] = arguments.MinConfidence;
		
		return apiCall( requestSettings, 'POST', 'DetectModerationLabels', { }, args );
	}

	private any function apiCall(
		required struct requestSettings,
		required string httpMethod,
		required string target,
		struct queryString = { },
		struct payload = { }
	) {
		var host = variables.service & '.' & requestSettings.region & '.amazonaws.com';

		var payloadString = payload.isEmpty() ? '' : serializeJSON( payload );
		var headers = { };
		headers[ 'X-Amz-Target' ] = "RekognitionService.#target#";
		if ( !payload.isEmpty() ) headers[ 'Content-Type' ] = 'application/x-amz-json-1.1';

		var apiResponse = api.call(
			variables.service,
			host,
			requestSettings.region,
			httpMethod,
			'/' & variables.apiVersion,
			queryString,
			headers,
			payloadString,
			requestSettings.awsCredentials
		);
        apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );

		return apiResponse;
	}


}
