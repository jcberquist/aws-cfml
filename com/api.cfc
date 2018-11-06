component accessors="true" {

    property utils;
    property httpService;
    property credentials;
    property signer;
    property defaultRegion;

    public any function init( required string awsKey, required string awsSecretKey, required string defaultRegion ) {
        variables.utils = new utils();
        variables.httpService = server.keyExists( 'lucee' ) ? new http.lucee( utils ) : new http.coldfusion( utils );
        variables.credentials = new credentials( awsKey, awsSecretKey, this );
        variables.signer = new signature_v4( this );
        variables.defaultRegion = arguments.defaultRegion.len() ? arguments.defaultRegion : utils.getSystemSetting( 'AWS_DEFAULT_REGION', '' );

        if ( !variables.defaultRegion.len() ) {
            var profile = utils.getSystemSetting( 'AWS_PROFILE', 'default' );
            var userHome = utils.getSystemSetting( 'user.home' ).replace( '\', '/', 'all' );
            var configFile = utils.getSystemSetting( 'AWS_CONFIG_FILE', userHome & '/.aws/config' );
            var region = getProfileString( configFile, profile, 'region' ).trim();
            variables.defaultRegion = region.len() ? region : 'us-east-1';
        }

        return this;
    }

    public struct function resolveRequestSettings( struct awsCredentials = { }, string region = defaultRegion ) {
        if ( !awsCredentials.isEmpty() ) {
            awsCredentials = credentials.defaultCredentials( argumentCollection = awsCredentials );
        }
        return { awsCredentials: awsCredentials, region: region };
    }

    public any function call(
        required string service,
        required string host,
        string region = defaultRegion,
        string httpMethod = 'GET',
        string path = '/',
        struct queryParams = { },
        struct headers = { },
        any body = '',
        struct awsCredentials = { }
    ) {
        if ( awsCredentials.isEmpty() ) {
            awsCredentials = credentials.getCredentials();
        }

        var signedRequestHeaders = signer.getHeadersWithAuthorization(
            service,
            host,
            region,
            httpMethod,
            path,
            queryParams,
            headers,
            body,
            awsCredentials
        );

        var httpArgs = { };
        httpArgs[ 'httpMethod' ] = httpMethod;
        httpArgs[ 'path' ] = host & path;
        httpArgs[ 'headers' ] = signedRequestHeaders;
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
        apiResponse[ 'rawData' ] = rawResponse.filecontent;

        if ( apiResponse.statusCode != 200 && isXML( apiResponse.rawData ) ) {
            apiResponse[ 'error' ] = utils.parseXmlResponse( apiResponse.rawData, 'Error' );
        }

        return apiResponse;
    }

    public any function signedUrl(
        required string service,
        required string host,
        string region = defaultRegion,
        string httpMethod = 'GET',
        string path = '/',
        struct queryParams = { },
        numeric expires = 300,
        struct awsCredentials = { }
    ) {
        if ( awsCredentials.isEmpty() ) {
            awsCredentials = credentials.getCredentials();
        }

        var signedQueryParams = signer.getQueryParamsWithAuthorization(
            service,
            host,
            region,
            httpMethod,
            path,
            queryParams,
            expires,
            awsCredentials
        );

        return host & utils.encodeurl( path, false ) & '?' & utils.parseQueryParams( signedQueryParams );
    }

    public any function authorizationParams(
        required string service,
        string region = defaultRegion,
        string isoTime = '',
        struct awsCredentials = { }
    ) {
        if ( awsCredentials.isEmpty() ) {
            awsCredentials = credentials.getCredentials();
        }

        return signer.getAuthorizationParams(
            service,
            region,
            isoTime,
            awsCredentials
        );
    }

    public any function sign(
        required struct awsCredentials,
        required string isoDateShort,
        required string region,
        required string service,
        required string stringToSign
    ) {
        if ( awsCredentials.isEmpty() ) {
            awsCredentials = credentials.getCredentials();
        }
        return signer.sign( argumentCollection = arguments );
    }

}
