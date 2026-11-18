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
    * Get parameters by path.
    * https://docs.aws.amazon.com/systems-manager/latest/APIReference/API_GetParametersByPath.html
    * @Path The hierarchy for the parameter. Hierarchies start with a forward slash (/).
    * @Recursive Retrieve all parameters within a hierarchy.
    * @WithDecryption Return decrypted secure string value. Return decrypted values for secure string parameters.
    * @MaxResults The maximum number of items to return.
    * @NextToken The token for the next set of items to return. (For pagination.)
    */
    public any function getParametersByPath(
        required string Path,
        boolean Recursive,
        boolean WithDecryption,
        numeric MaxResults,
        string NextToken
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = { 'Path': arguments.Path };
        for (
            var key in [
                'Recursive',
                'WithDecryption',
                'MaxResults',
                'NextToken'
            ]
        ) {
            if ( structKeyExists( arguments, key ) ) {
                payload[ key ] = arguments[ key ];
            }
        }
        return apiCall( requestSettings, 'GetParametersByPath', payload );
    }

    /**
    * Add or update a parameter in the Parameter Store.
    * https://docs.aws.amazon.com/systems-manager/latest/APIReference/API_PutParameter.html
    * @Name The name of the parameter to create or update.
    * @Value The parameter value.
    * @Type The type of parameter. Valid values are String, StringList, and SecureString.
    * @Overwrite Overwrite an existing parameter of the same name.
    * @KeyId The ID, ARN or alias of the KMS key used to encrypt a SecureString parameter. If omitted, the AWS managed key (aws/ssm) is used.
    * @Description Information about the parameter.
    */
    public any function putParameter(
        required string Name,
        required string Value,
        required string Type,
        boolean Overwrite,
        string KeyId,
        string Description
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = {
            'Name': arguments.Name,
            'Value': arguments.Value,
            'Type': arguments.Type
        };
        for (
            var key in [
                'Overwrite',
                'KeyId',
                'Description'
            ]
        ) {
            if ( structKeyExists( arguments, key ) ) {
                payload[ key ] = arguments[ key ];
            }
        }
        return apiCall( requestSettings, 'PutParameter', payload );
    }

    /**
    * Delete a parameter from the Parameter Store.
    * https://docs.aws.amazon.com/systems-manager/latest/APIReference/API_DeleteParameter.html
    * @Name The name of the parameter to delete.
    */
    public any function deleteParameter(
        required string Name
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = { 'Name': arguments.Name };
        return apiCall( requestSettings, 'DeleteParameter', payload );
    }

    /**
    * Delete multiple parameters from the Parameter Store.
    * https://docs.aws.amazon.com/systems-manager/latest/APIReference/API_DeleteParameters.html
    * @Names The names of the parameters to delete.
    */
    public any function deleteParameters(
        required array Names
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = { 'Names': arguments.Names };
        return apiCall( requestSettings, 'DeleteParameters', payload );
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
