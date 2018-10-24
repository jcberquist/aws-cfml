component {

    variables.service = 'translate';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.apiVersion = arguments.settings.apiVersion;
        variables.defaultSourceLanguageCode = arguments.settings.defaultSourceLanguageCode;
        variables.defaultTargetLanguageCode = arguments.settings.defaultTargetLanguageCode;
        return this;
    }

    public any function translateText(
        required string Text,
        string SourceLanguageCode = defaultSourceLanguageCode,
        string TargetLanguageCode = defaultTargetLanguageCode
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = {
            'Text': Text,
            'SourceLanguageCode': SourceLanguageCode,
            'TargetLanguageCode': TargetLanguageCode
        };
        return apiCall( requestSettings, 'TranslateText', payload );
    }

    public string function getHost(
        required string region
    ) {
        return variables.service & '.' & region & '.amazonaws.com';
    }

    private any function apiCall(
        required struct requestSettings,
        required string target,
        struct payload = { }
    ) {
        var host = getHost( requestSettings.region );
        var payloadString = serializeJSON( payload );

        var headers = { };
        headers[ 'X-Amz-Target' ] = 'AWSShineFrontendService_' & variables.apiVersion & '.' & arguments.target;
        headers[ 'Content-Type' ] = 'application/x-amz-json-1.1';

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
