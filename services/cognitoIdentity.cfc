component {

    variables.service = 'cognito-identity';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.apiVersion = arguments.settings.apiVersion;
        variables.platform = server.keyExists( 'lucee' ) ? 'Lucee' : 'ColdFusion';
        return this;
    }

    /*
    * Returns an IdentityId and a Token
    * https://docs.aws.amazon.com/cognitoidentity/latest/APIReference/API_GetOpenIdTokenForDeveloperIdentity.html
    * @IdentityPoolId An identity pool ID in the format REGION:GUID.
    * @Logins A set of optional name-value pairs that map provider names to provider tokens.
    * @IdentityId A unique identifier in the format REGION:GUID.
    * @TokenDuration The expiration time of the token, in seconds.
    */
    public any function GetOpenIdTokenForDeveloperIdentity (
        required string IdentityPoolId,
        required struct Logins,
        string IdentityId,
        numeric TokenDuration
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = "{#Chr(34)#Operation#Chr(34)#:#Chr(34)#com.amazonaws.cognito.identity.model#Chr(35)#GetOpenIdTokenForDeveloperIdentity#Chr(34)#,";
        payload &= "#Chr(34)#Service#Chr(34)#:#Chr(34)#com.amazonaws.cognito.identity.model#Chr(35)#AWSCognitoIdentityService#Chr(34)#,";
        payload &= "#Chr(34)#Input#Chr(34)#:{";
        if (structKeyExists(arguments, "IdentityId") and IdentityId != "") {
            payload &= "#Chr(34)#IndentityId#Chr(34)#:#Chr(34)##IdentityId##Chr(34)#,";
        }
        payload &= "#Chr(34)#IdentityPoolId#Chr(34)#:#Chr(34)##IdentityPoolId##Chr(34)#,";
        payload &= "#Chr(34)#Logins#Chr(34)#: {";
        for (key in Logins) {
            payload &= "#Chr(34)##key##Chr(34)#:#Chr(34)##Logins[key]##Chr(34)#";
        }
        payload &= "}";
        if (structKeyExists(arguments,"TokenDuration") and TokenDuration>0) {
            payload &= ",#Chr(34)#TokenDuration#Chr(34)#:#TokenDuration#";
        }
        payload &= "}}"
        writeDump(payload);
        var apiResponse = apiCall( requestSettings, payload);
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
        required string payload
    ) {
        var host = getHost(requestSettings.region);
        queryParams['Version'] = apiVersion;

        var apiResponse = api.call( variables.service, host, requestSettings.region, 'POST', '/', { }, {"Content-Type" : "application/json" }, payload, requestSettings.awsCredentials );
        apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );

        return apiResponse;
    }
}