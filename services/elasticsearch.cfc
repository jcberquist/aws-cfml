component {

    variables.service = 'es';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.defaultEndPoint = arguments.settings.endpoint;
        return this;
    }

    public any function apiCall(
        string httpMethod = 'GET',
        string path = '/',
        struct queryParams = { },
        struct headers = { },
        any payload = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        if ( !structKeyExists( arguments, 'EndPoint' ) ) arguments.EndPoint = variables.defaultEndPoint;

        var host = endPoint & '.' & requestSettings.region & '.' & variables.service & '.amazonaws.com';

        var result = api.call(
            variables.service,
            host,
            requestSettings.region,
            httpMethod,
            path,
            queryParams,
            headers,
            payload,
            requestSettings.awsCredentials
        );
        if ( result.keyExists( 'rawData' ) && isJSON( result.rawData ) ) {
            result[ 'data' ] = deserializeJSON( result.rawData );
        }
        return result;
    }



}
