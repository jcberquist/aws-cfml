component {

    variables.service = 'cognito-identity';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.apiVersion = arguments.settings.apiVersion;
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
    public any function GetOpenIdTokenForDeveloperIdentity(
        required string IdentityPoolId,
        required struct Logins,
        string IdentityId,
        numeric TokenDuration
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = { 'IdentityPoolId': arguments.IdentityPoolId, 'Logins': arguments.Logins };

        if ( !isNull( arguments.IdentityId ) ) payload[ 'IdentityId' ] = arguments.IdentityId;
        if ( !isNull( arguments.TokenDuration ) ) payload[ 'TokenDuration' ] = arguments.TokenDuration;

        return apiCall( requestSettings, 'GetOpenIdTokenForDeveloperIdentity', payload );
    }

    // private functions

    private any function apiCall(
        required struct requestSettings,
        required string target,
        struct payload = { }
    ) {
        var host = variables.service & '.' & requestSettings.region & '.amazonaws.com';
        var payloadString = payload.isEmpty() ? '' : serializeJSON( payload );
        var headers = { };
        headers[ 'X-Amz-Target' ] = 'AWSCognitoIdentityService.#target#';
        if ( !payload.isEmpty() ) headers[ 'Content-Type' ] = 'application/x-amz-json-1.1';

        var apiResponse = api.call(
            variables.service,
            host,
            requestSettings.region,
            'POST',
            '/',
            { },
            headers,
            payloadString,
            requestSettings.awsCredentials
        );
        apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );

        return apiResponse;
    }

}
