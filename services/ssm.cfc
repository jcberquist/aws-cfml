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
        if ( !isNull( arguments.Recursive ) ) {
            payload[ 'Recursive' ] = arguments.Recursive;
        }
        if ( !isNull( arguments.WithDecryption ) ) {
            payload[ 'WithDecryption' ] = arguments.WithDecryption;
        }
        if ( !isNull( arguments.MaxResults ) ) {
            payload[ 'MaxResults' ] = arguments.MaxResults;
        }
        if ( !isNull( arguments.NextToken ) ) {
            payload[ 'NextToken' ] = arguments.NextToken;
        }
        return apiCall( requestSettings, 'GetParametersByPath', payload );
    }

    /**
    * Retrieves all parameters from a specified path.
    * Handles pagination to ensure all parameters within the path are fetched.
    * @Path The hierarchy path to query parameters. Must start with a forward slash (e.g., "/production").
    * @Recursive If true, retrieves parameters from the entire hierarchy under the specified path.
    * @withDecryption If true, retrieves decrypted values for secure string parameters.
    */
    public array function getAllParametersByPath(
        required string path,
        required boolean recursive,
        required boolean withDecryption
    ) {
        var allParameters = [];
        var nextToken = "";
        var parametersResponse = {};

        // Initial loop condition
        var continueLoop = true;

        while (continueLoop) {
            // Make the API call to get parameters by path
            parametersResponse = getParametersByPath(
                Path = arguments.path,
                Recursive = arguments.recursive,
                WithDecryption = arguments.withDecryption,
                MaxResults = 10, // Maximum items per call
                NextToken = nextToken
            );

            // Append the retrieved parameters to the results array, merging arrays into a flat array
            if (structKeyExists(parametersResponse.data, "Parameters")) {
                arrayAppend(allParameters, parametersResponse.data.Parameters, true);
            }

            // Update nextToken and determine if the loop should continue
            if (structKeyExists(parametersResponse.data, "NextToken")) {
                nextToken = parametersResponse.data.NextToken;
            } else {
                continueLoop = false;
            }
        }

        return allParameters;
    }

    /**
    * Add or update a parameter in the Parameter Store.
    * https://docs.aws.amazon.com/systems-manager/latest/APIReference/API_PutParameter.html
    * @Name The name of the parameter to create or update.
    * @Value The parameter value.
    * @Type The type of parameter. Valid values are String, StringList, and SecureString.
    * @Overwrite Overwrite an existing parameter of the same name.
    */
    public any function putParameter(
        required string Name,
        required string Value,
        required string Type,
        boolean Overwrite
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = {
            'Name': arguments.Name,
            'Value': (len(arguments.Value) ? arguments.Value : " "),
            'Type': arguments.Type
        };
        if ( !isNull( arguments.Overwrite ) ) {
            payload[ 'Overwrite' ] = arguments.Overwrite;
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