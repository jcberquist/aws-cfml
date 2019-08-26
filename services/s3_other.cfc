component extends="s3"{

    variables.service = 's3_other';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.utils = variables.api.getUtils();
        variables.emptyStringHash = hash( '', 'SHA-256' ).lcase();
        variables.host = arguments.settings.host;
        variables.useSSL = arguments.settings.useSSL;
        return this;
    }

    // private

    private string function getHost(
        required string region
    ) {
        return variables.host;
    }

    private any function apiCall(
        required struct requestSettings,
        string httpMethod = 'GET',
        string path = '/',
        struct queryParams = { },
        struct headers = { },
        any payload = ''
    ) {
        var host = getHost( requestSettings.region );

        if ( !isSimpleValue( payload ) || len( payload ) ) {
            headers[ 'X-Amz-Content-Sha256' ] = hash( payload, 'SHA-256' ).lcase();
        } else {
            headers[ 'X-Amz-Content-Sha256' ] = variables.emptyStringHash;
        }

        return api.call(
            "s3",
            host,
            requestSettings.region,
            httpMethod,
            path,
            queryParams,
            headers,
            payload,
            requestSettings.awsCredentials,
            true,
            variables.useSSL
        );
    }

}
