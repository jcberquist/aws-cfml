component {

    variables.service = 'cognito-identity';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.apiVersion = arguments.settings.apiVersion;
        variables.argumentTypes = getArgTypes();
        variables.argumentKeys = variables.argumentTypes.keyArray();
        variables.platform = server.keyExists( 'lucee' ) ? 'Lucee' : 'ColdFusion';
        return this;
    }

    // https://docs.aws.amazon.com/cognitoidentity/latest/APIReference/API_GetOpenIdTokenForDeveloperIdentity.html
    public any function GetOpenIdTokenForDeveloperIdentity (
        required string IdentityPoolId,
        required struct Logins,
        string IdentityId,
        int TokenDuration
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payloadStruct = StructNew("ordered");
        StructInsert(payloadStruct, "Operation", "com.amazonaws.cognito.identity.model#Chr(35)#GetOpenIdTokenForDeveloperIdentity");
        StructInsert(payloadStruct, "Service", "com.amazonaws.cognito.identity.model#Chr(35)#AWSCognitoIdentityService");
        var inputStruct = StructNew("ordered");
        if (structKeyExists(arguments, "IdentityId")) {
            structInsert(inputStruct, "IdentityId", IdentityId);
        }
        structInsert(inputStruct, "IdentityPoolId", IdentityPoolId);
        structInsert(inputStruct, "Logins", Logins);
        if (structKeyExists(arguments,"TokenDuration")) {
            structInsert(inputStruct, "TokenDuration", TokenDuration);
        }
        StructInsert(payloadStruct, "Input", inputStruct);

        writeDump(payloadStruct);
        var apiResponse = apiCall( requestSettings, payloadStruct);
        return apiResponse;
    }

    //private functions

    private string function getHost(
        required string region
    ) {
        return variables.service & ( region == 'us-east-1' ? '' : '-' & region ) & '.amazonaws.com';
    }

    private any function apiCall(
        required struct requestSettings,
        required struct payload
    ) {
        var host = getHost(requestSettings.region);
        var payloadString = toJSON( payload );
        writeDump(payloadString);
        queryParams['Version'] = apiVersion;

        var apiResponse = api.call( variables.service, host, requestSettings.region, 'POST', '/', { }, {"Content-Type" : "application/json" }, payloadString, requestSettings.awsCredentials );
        writeDump(apiResponse);
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

    private struct function getArgTypes() {
        var metadata = getMetadata( this );
        var typed = [ 'ExclusiveStartKey','ExpressionAttributeValues','Item','Key' ];
        var result = { };

        for ( var funct in metadata.functions ) {
            if ( arrayFindNoCase( [ 'init','encodeValues','decodeValues' ], funct.name ) || funct.access != 'public' ) continue;
            for ( var param in funct.parameters ) {
                result[ param.name ] = typed.findNoCase( param.name ) ? 'typed' : param.type;
            }
        }

        return result;
    }
}