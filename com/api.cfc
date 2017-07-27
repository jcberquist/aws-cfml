component {

    public any function init(
        required string awsKey,
        required string awsSecretKey,
        required string defaultRegion
    ) {
        variables.utils = new utils();
        variables.httpService = server.keyExists( 'lucee' ) ? new http.lucee( variables.utils ) : new http.coldfusion( variables.utils );
        variables.credentials = new credentials( arguments.awsKey, arguments.awsSecretKey, variables.httpService );
        variables.signer = new signature_v4( credentials, utils );
        variables.defaultRegion = arguments.defaultRegion;
        return this;
    }

    public any function getUtils() {
        return variables.utils;
    }

    public any function getHttpService() {
        return variables.httpService;
    }

    public any function getSigner() {
        return variables.signer;
    }

    public string function getDefaultRegion() {
        return variables.defaultRegion;
    }

    public any function call(
        required string service,
        required string host,
        string region = defaultRegion,
        string httpMethod = 'GET',
        string path = '/',
        struct queryParams = { },
        struct headers = { },
        any body = ''
    ) {
        var isoTime = utils.iso8601();
        var api_request_headers = { 'Host': host, 'X-Amz-Date': isoTime };

        var token = credentials.get( 'token' );
        if ( len( token ) ) api_request_headers[ 'X-Amz-Security-Token' ] = token;

        api_request_headers.append( headers );
        api_request_headers[ 'Authorization' ] = signer.getAuthorization( service, region, isoTime, httpMethod, path, queryParams, api_request_headers, body );

        var httpArgs = { };
        httpArgs[ 'httpMethod' ] = httpMethod;
        httpArgs[ 'path' ] = host & path;
        httpArgs[ 'headers' ] = api_request_headers;
        httpArgs[ 'queryParams' ] = queryParams;
        if ( !isNull( arguments.body ) ) httpArgs[ 'body' ] = body;
        // writeDump( httpArgs );

        var requestStart = getTickCount();
        var rawResponse = httpService.makeHttpRequest( argumentCollection = httpArgs );
        // writeDump( rawResponse );

        var apiResponse = { };
        apiResponse[ 'responseTime' ] = getTickCount() - requestStart;
        apiResponse[ 'responseHeaders' ] = rawResponse.responseheader;
        apiResponse[ 'statusCode' ] = listFirst( rawResponse.statuscode, ' ' );
        apiResponse[ 'statusText' ] = listRest( rawResponse.statuscode, ' ' );
        apiResponse[ 'rawData' ] = rawResponse.filecontent;

        if ( apiResponse.statusCode != 200 && isXML( apiResponse.rawData ) ) {
                apiResponse[ 'error' ] = utils.parseXmlResponse( apiResponse.rawData, 'Error' );
        }

        return apiResponse;
    }

}
