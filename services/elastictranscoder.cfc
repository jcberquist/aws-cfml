component {

	variables.service = 'elastictranscoder';

	public any function init(
		required any api,
		string region = 'us-east-1',
		string apiVersion = '2012-09-25'
	) {
		variables.apiVersion = arguments.apiVersion;
		variables.host = variables.service & '.' & arguments.region & '.amazonaws.com';
		variables.region = arguments.region;
		variables.api = arguments.api;
		return this;
	}

	/**
	* Gets a list of the pipelines associated with the current AWS account
	* http://docs.aws.amazon.com/elastictranscoder/latest/developerguide/list-pipelines.html
	* @Ascending To list pipelines in chronological order by the date and time that they were submitted, enter true. To list pipelines in reverse chronological order, enter false.
	* @PageToken When Elastic Transcoder returns more than one page of results, use PageToken in subsequent GET requests to get each successive page of results.
	*/
	public any function listPipelines(
		boolean Ascending,
		string PageToken
	) {
		var queryString = { };
		if ( !isNull( arguments.Ascending ) ) queryString[ 'Ascending' ] = Ascending;
		if ( !isNull( arguments.PageToken ) ) queryString[ 'PageToken' ] = PageToken;
		var apiResponse = apiCall( 'GET', '/pipelines', queryString );
		return apiResponse;
	}

	/**
	* Gets a list of all presets associated with the current AWS account
	* http://docs.aws.amazon.com/elastictranscoder/latest/developerguide/list-presets.html
	* @Ascending To list presets in chronological order by the date and time that they were submitted, enter true. To list presets in reverse chronological order, enter false.
	* @PageToken When Elastic Transcoder returns more than one page of results, use PageToken in subsequent GET requests to get each successive page of results.
	*/
	public any function listPresets(
		boolean Ascending,
		string PageToken
	) {
		var queryString = { };
		if ( !isNull( arguments.Ascending ) ) queryString[ 'Ascending' ] = ( Ascending ? 'true' : 'false' );
		if ( !isNull( arguments.PageToken ) ) queryString[ 'PageToken' ] = PageToken;
		return apiCall( 'GET', '/presets', queryString );
	}

	/**
	* Creates a job
	* http://docs.aws.amazon.com/elastictranscoder/latest/developerguide/create-job.html
	* @Job See http://docs.aws.amazon.com/elastictranscoder/latest/developerguide/create-job.html for the correct job format
	*/
	public any function createJob(
		required struct Job
	) {
		return apiCall( 'POST', '/jobs', { }, Job );
	}

	private any function apiCall(
		required string httpMethod,
		required string path,
		struct queryString = { },
		struct payload = { }
	) {

		var payloadString = payload.isEmpty() ? '' : serializeJSON( payload );

		var headers = { };
		if ( !payload.isEmpty() ) headers[ 'Content-Type' ] = 'application/x-amz-json-1.0';

		var apiResponse = api.call( variables.service, variables.host, variables.region, httpMethod, '/' & variables.apiVersion & path, queryString, headers, payloadString );
		apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );

		return apiResponse;
	}


}