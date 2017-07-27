component {

    variables.service = 'es';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.defaultRegion = arguments.api.getDefaultRegion();
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
        if ( !structKeyExists( arguments, 'Region' ) ) arguments.Region = variables.defaultRegion;
        if ( !structKeyExists( arguments, 'EndPoint' ) ) arguments.EndPoint = variables.defaultEndPoint;

        var host = endPoint & '.' & region & '.' & variables.service & '.amazonaws.com';

        var result = api.call( variables.service, host, region, httpMethod, path, queryParams, headers, payload );
        if ( result.keyExists( 'rawData' ) && isJSON( result.rawData ) ) {
            result[ 'data' ] = deserializeJSON( result.rawData );
        }
        return result;
    }



}
