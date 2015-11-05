component {

  public any function init(
    required any utils,
    required any signer
  ) {
    variables.utils = arguments.utils;
    variables.signer = arguments.signer;
    variables.httpRequester = server.keyExists( 'lucee' ) ? new http.lucee( arguments.utils ) : new http.coldfusion( arguments.utils );
    return this;
  }

  public any function call(
    required string service,
    required string host,
    required string region,
    string httpMethod = 'GET',
    string path = '/',
    struct queryParams = { },
    struct headers = { },
    any body
  ) {
    var isoTime = utils.iso8601();
    var api_request_headers = { 'Host': host, 'X-amz-date': isoTime };
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
    var rawResponse = httpRequester.makeHttpRequest( argumentCollection = httpArgs );
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