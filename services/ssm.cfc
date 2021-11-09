component {

    variables.service = 'ssm';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.apiVersion = arguments.settings.apiVersion;
        return this;
    }

    /**
    * Get information about a parameter by using the parameter name. Don't confuse this API action with the GetParameters API action.
    * https://docs.aws.amazon.com/systems-manager/latest/APIReference/API_GetParameter.html
    * @Name The name of the parameter you want to query.
    * @WithDecryption Return decrypted values for secure string parameters. This flag is ignored for String and StringList parameter types.
    */
    public any function getParameter(
        required string Name,
        boolean WithDecryption
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = { 'Name': arguments.Name };
        if ( !isNull( arguments.WithDecryption ) ) {
            payload[ 'WithDecryption' ] = arguments.WithDecryption;
        }
        return apiCall( requestSettings, 'GetParameter', payload );
    }

    /**
    * Get details of a parameter. Don't confuse this API action with the GetParameter API action.
    * https://docs.aws.amazon.com/systems-manager/latest/APIReference/API_GetParameters.html
    * @Names Names of the parameters for which you want to query information.
    * @WithDecryption Return decrypted secure string value. Return decrypted values for secure string parameters. This flag is ignored for String and StringList parameter types.
    */
    public any function getParameters(
        required array Names,
        boolean WithDecryption
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = { 'Names': arguments.Names };
        if ( !isNull( arguments.WithDecryption ) ) {
            payload[ 'WithDecryption' ] = arguments.WithDecryption;
        }
        return apiCall( requestSettings, 'GetParameters', payload );
    }


    /**
    * Get parameters by path
    * https://docs.aws.amazon.com/systems-manager/latest/APIReference/API_GetParametersByPath.html
    * @Path The path of the parameters you want to return.
    * @WithDecryption Return decrypted secure string value. Return decrypted values for secure string parameters. This flag is ignored for String and StringList parameter types.
    */
    public any function getParametersByPath(
        required string Path,
        boolean WithDecryption
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = { 'Path': arguments.Path, 'Recursive': true };
        var rtn = { };
        if ( !isNull( arguments.WithDecryption ) ) {
            payload[ 'WithDecryption' ] = arguments.WithDecryption;
        }

        var response = apiCall( requestSettings, 'GetParametersByPath', payload );

        for ( var parameter in response.data.parameters ) {
            rtn[ parameter.Name ] = parameter.value;
        }

        var nextToken = structKeyExists( response.data, 'NextToken' ) ? response.data.NextToken : '';

        while ( nextToken neq '' ) {
            payload[ 'NextToken' ] = nextToken;
            response = apiCall( requestSettings, 'GetParametersByPath', payload );

            for ( var parameter in response.data.parameters ) {
                rtn[ parameter.Name ] = parameter.value;
            }

            nextToken = structKeyExists( response.data, 'NextToken' ) ? response.data.NextToken : '';
        }

        return rtn;
    }


    /**
    * Add (or update) a parameter.  Overwrite is set to true by default to allow the same function to add or update params
    * https://docs.aws.amazon.com/systems-manager/latest/APIReference/API_PutParameter.html
    * @Path The path of the parameters you want to add/update.
    * @Value The parameter value
    * @Description A description of the parameter
    * @Type String | StringList | SecureString
    */
    public struct function putParameter(
        required string Path,
        required string Value,
        string Description = '',
        string Type = 'String',
        boolean Overwrite = true
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );

        if ( !listContainsNoCase( 'String,StringList,SecureString', arguments.Type ) ) {
            arguments.Type = 'String'
        }

        var payload = {
            'Description': left( arguments.Description, 1024 ),
            'Name': left(
                reReplace(
                    arguments.Path,
                    '[^a-zA-Z0-9_.\-\/]*',
                    '',
                    'ALL'
                ),
                2048
            ),
            'Overwrite': arguments.Overwrite,
            'Type': arguments.Type,
            'Value': arguments.Value
        }

        var response = apiCall( requestSettings, 'PutParameter', payload );

        return response[ 'data' ];
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
        headers[ 'X-Amz-Target' ] = 'AmazonSSM' & '.' & arguments.target;
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
