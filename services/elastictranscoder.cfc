component {

    variables.service = 'elastictranscoder';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.defaultRegion = variables.api.getDefaultRegion();
        variables.apiVersion = arguments.settings.apiVersion;
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
        if ( !structKeyExists( arguments, 'Region' ) ) arguments.Region = variables.defaultRegion;
        var queryString = { };
        if ( !isNull( arguments.Ascending ) ) queryString[ 'Ascending' ] = Ascending;
        if ( !isNull( arguments.PageToken ) ) queryString[ 'PageToken' ] = PageToken;
        var apiResponse = apiCall( region, 'GET', '/pipelines', queryString );
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
        if ( !structKeyExists( arguments, 'Region' ) ) arguments.Region = variables.defaultRegion;
        var queryString = { };
        if ( !isNull( arguments.Ascending ) ) queryString[ 'Ascending' ] = ( Ascending ? 'true' : 'false' );
        if ( !isNull( arguments.PageToken ) ) queryString[ 'PageToken' ] = PageToken;
        return apiCall( region, 'GET', '/presets', queryString );
    }

    /**
    * Creates a job
    * http://docs.aws.amazon.com/elastictranscoder/latest/developerguide/create-job.html
    * @Job See http://docs.aws.amazon.com/elastictranscoder/latest/developerguide/create-job.html for the correct job format
    */
    public any function createJob(
        required struct Job
    ) {
        if ( !structKeyExists( arguments, 'Region' ) ) arguments.Region = variables.defaultRegion;
        return apiCall( region, 'POST', '/jobs', { }, Job );
    }

    private any function apiCall(
        required string region,
        required string httpMethod,
        required string path,
        struct queryString = { },
        struct payload = { }
    ) {
        var host = variables.service & '.' & region & '.amazonaws.com';

        var payloadString = payload.isEmpty() ? '' : serializeJSON( payload );

        var headers = { };
        if ( !payload.isEmpty() ) headers[ 'Content-Type' ] = 'application/x-amz-json-1.0';

        var apiResponse = api.call( variables.service, host, region, httpMethod, '/' & variables.apiVersion & path, queryString, headers, payloadString );
        apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );

        return apiResponse;
    }


}
