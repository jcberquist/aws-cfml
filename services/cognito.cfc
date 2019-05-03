component {

    variables.service = 'cognito';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.argumentTypes = getArgTypes();
        variables.argumentKeys = variables.argumentTypes.keyArray();
        return this;
    }

    // https://docs.aws.amazon.com/cognitoidentity/latest/APIReference/API_GetOpenIdTokenForDeveloperIdentity.html
    public any function GetOpenIdTokenForDeveloperIdentity (
        required string IdentityPoolId,
        required struct Logins,
        string IdentityId,
        string TokenDuration
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );
        var apiResponse = apiCall( requestSettings, payload );
        return apiResponse;
    }

    //private functions

    private any function buildPayload( required any args ) {
        var payload = { };
        for ( var key in args ) {
            var keyIndex = variables.argumentKeys.findNoCase( key );
            if ( !keyIndex ) continue;
            var argType = variables.argumentTypes[ key ];
            var casedKey = variables.argumentKeys[ keyIndex ];
            switch( argType ) {
                case 'array':
                case 'string':
                    if ( args[ key ].len() ) payload[ casedKey ] = args[ key ];
                    break;
                case 'boolean':
                case 'numeric':
                    if ( args[ key ] ) payload[ casedKey ] = args[ key ];
                    break;
                case 'struct':
                    if ( !args[ key ].isEmpty() ) payload[ casedKey ] = args[ key ];
                    break;
                case 'typed':
                    if ( !args[ key ].isEmpty() ) {
                        if ( args.keyExists( 'dataTypeEncoding' ) && !args.dataTypeEncoding ) {
                            payload[ casedKey ] = args[ key ];
                        } else {
                            payload[ casedKey ] = encodeValues( args[ key ], args.keyExists( 'typeDefinitions' ) ? args.typeDefinitions : { } );
                        }
                    }
                    break;
            }
        }
        return payload;
    }

    private string function getHost(
        required string region
    ) {
        return variables.service & ( region == 'us-east-1' ? '' : '-' & region ) & '.amazonaws.com';
    }

    private any function apiCall(
        required struct requestSettings,
        struct payload = { }
    ) {
        var host = getHost(requestSettings.region);
        var payloadString = toJSON( payload );

        var headers = { };

        var apiResponse = api.call( variables.service, host, requestSettings.region, 'GET', '/', { }, headers, payloadString, requestSettings.awsCredentials );
        apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );

        return apiResponse;
    }

    private string function toJSON( required struct source ) {
        var json = serializeJSON( source );
        // clean up ColdFusion serialization
        if ( variables.platform == 'ColdFusion' ) {
            json = reReplace(json, '\{"([NS])":([^\}"]+)\}', '{"\1":"\2"}', "all");
            json = reReplace(json, '\{"BOOL":(true|false)\}', '{"BOOL":"\1"}', "all");
            json = replace( json, '{"NULL":true}', '{"NULL":"true"}' );
        }
        return json;
    }
}