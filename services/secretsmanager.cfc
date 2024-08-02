component {

    variables.service = 'secretsmanager';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.apiVersion = arguments.settings.apiVersion;
        return this;
    }

    /**
    * Retrieves the contents of the encrypted fields SecretString or SecretBinary from the specified version of a secret, whichever contains content.
    * https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
    * @SecretId Specifies the secret containing the version that you want to retrieve. You can specify either the Amazon Resource Name (ARN) or the friendly name of the secret.
    */
    public any function getSecretValue(
        required string SecretId
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = { 'SecretId': arguments.SecretId };
        return apiCall( requestSettings, 'GetSecretValue', payload );
    }

    /**
    * Retrieves the details of a secret. It does not include the encrypted secret value. Secrets Manager only returns fields that have a value in the response.
    * https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_DescribeSecret.html
    */
    public any function describeSecret(
        required string SecretId
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = { 'SecretId': arguments.SecretId };
        return apiCall( requestSettings, 'DescribeSecret', payload );
    }

    /**
    * Create a new secret
    * https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_CreateSecret.html
    */
    public any function createSecret(
        required string Name,
        any SecretString,
        any SecretBinary,
        string Description = '',
        string KmsKeyId,
        array Tags,
        string ClientRequestToken = createGUID(),
        array AddReplicaRegions,
        boolean ForceOverwriteReplicaSecret
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = {
            'Name': arguments.Name,
            'Description': arguments.Description,
            'ClientRequestToken': arguments.ClientRequestToken
        };
        if( structKeyExists( arguments, "SecretString" ) ) {
            payload[ "SecretString" ] = isSimpleValue( arguments.SecretString ) ? arguments.SecretString : serializeJSON( arguments.SecretString );
        }
        else if( structKeyExists( arguments, "SecretBinary" ) ) {
            payload[ "SecretBinary" ] = arguments.SecretBinary;
        }
        if( structKeyExists( arguments, "KmsKeyId" ) ) {
            payload[ "KmsKeyId" ] = arguments.KmsKeyId;
        }
        if( structKeyExists( arguments, "Tags" ) && arrayLen( arguments.Tags ) ) {
            payload[ "Tags" ] = arguments.Tags;
        }
        if( structKeyExists( arguments, "AddReplicaRegions" ) && arrayLen( arguments.AddReplicaRegions ) ) {
            payload[ "AddReplicaRegions" ] = arguments.AddReplicaRegions;
        }
        if( structKeyExists( arguments, "ForceOverwriteReplicaSecret" ) ) {
            payload[ "ForceOverwriteReplicaSecret" ] = arguments.ForceOverwriteReplicaSecret;
        }
        return apiCall( requestSettings, 'CreateSecret', payload );
    }

    /**
    * Updates an existing secret
    * https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_UpdateSecret.html
    */
    public any function updateSecret(
        required string SecretId,
        required string Name,
        any SecretString,
        any SecretBinary,
        string Description = '',
        string KmsKeyId,
        string ClientRequestToken = createGUID()
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = {
            'SecretId': arguments.SecretId,
            'Name': arguments.Name,
            'Description': arguments.Description,
            'ClientRequestToken': arguments.ClientRequestToken
        };
        if( structKeyExists( arguments, "SecretString" ) ) {
            payload[ "SecretString" ] = isSimpleValue( arguments.SecretString ) ? arguments.SecretString : serializeJSON( arguments.SecretString );
        }
        else if( structKeyExists( arguments, "SecretBinary" ) ) {
            payload[ "SecretBinary" ] = arguments.SecretBinary;
        }
        if( structKeyExists( arguments, "KmsKeyId" ) ) {
            payload[ "KmsKeyId" ] = arguments.KmsKeyId;
        }
        return apiCall( requestSettings, 'UpdateSecret', payload );
    }

    /**
    * Updates an existing secret's value only
    * https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_PutSecretValue.html
    */
    public any function PutSecretValue(
        required string SecretId,
        any SecretString,
        any SecretBinary,
        array VersionStages,
        string ClientRequestToken = createGUID()
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = {
            'SecretId': arguments.SecretId,
            'ClientRequestToken': arguments.ClientRequestToken
        };
        if( structKeyExists( arguments, "SecretString" ) ) {
            payload[ "SecretString" ] = isSimpleValue( arguments.SecretString ) ? arguments.SecretString : serializeJSON( arguments.SecretString );
        }
        else if( structKeyExists( arguments, "SecretBinary" ) ) {
            payload[ "SecretBinary" ] = arguments.SecretBinary;
        }
        if( structKeyExists( arguments, "VersionStages" ) && arrayLen( arguments.VersionStages ) ) {
            payload[ "VersionStages" ] = arguments.VersionStages;
        }
        return apiCall( requestSettings, 'PutSecretValue', payload );
    }

    /**
    * Delete a secret
    * https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_DeleteSecret.html
    */
    public any function deleteSecret(
        required string SecretId
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = { 'SecretId': arguments.SecretId };
        return apiCall( requestSettings, 'DeleteSecret', payload );
    }

    /**
    * Remove replication from a secret
    * https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_RemoveRegionsFromReplication.html
    */
    public any function removeRegionsFromReplication(
        required string SecretId,
        required array RemoveReplicaRegions
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = { 'SecretId': arguments.SecretId, 'RemoveReplicaRegions': arguments.RemoveReplicaRegions };
        return apiCall( requestSettings, 'RemoveRegionsFromReplication', payload );
    }

    /**
    * Restore a secret
    * https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_RestoreSecret.html
    */
    public any function restoreSecret(
        required string SecretId
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = { 'SecretId': arguments.SecretId };
        return apiCall( requestSettings, 'RestoreSecret', payload );
    }

    /**
    * Lists secrets
    * https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_ListSecrets.html
    */
    public any function listSecrets(
        array Filters,
        boolean IncludePlannedDeletion = false,
        numeric MaxResults, // between 1-100
        string NextToken,
        string SortOrder,
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = { "IncludePlannedDeletion": arguments.IncludePlannedDeletion };
        if( structKeyExists( arguments, "Filters" ) && arrayLen( arguments.Filters ) ) {
            payload[ "Filters" ] = arguments.Filters;
        }
        if( structKeyExists( arguments, "MaxResults" ) ) {
            payload[ "MaxResults" ] = arguments.MaxResults;
        }
        if( structKeyExists( arguments, "NextToken" ) ) {
            payload[ "NextToken" ] = arguments.NextToken;
        }
        if( structKeyExists( arguments, "SortOrder" ) ) {
            payload[ "SortOrder" ] = arguments.SortOrder;
        }
        return apiCall( requestSettings, 'ListSecrets', payload );
    }

    /**
    * Get random password
    * https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetRandomPassword.html
    */
    public any function getRandomPassword(
        required numeric PasswordLength,
        string ExcludeCharacters = '',
        boolean ExcludeLowercase = false,
        boolean ExcludeNumbers = false,
        boolean ExcludePunctuation = false,
        boolean ExcludeUppercase = false,
        boolean IncludeSpace = false,
        boolean RequireEachIncludedType = true
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = {
            'PasswordLength': arguments.PasswordLength,
            'ExcludeCharacters': arguments.ExcludeCharacters,
            'ExcludeLowercase': arguments.ExcludeLowercase,
            'ExcludeNumbers': arguments.ExcludeNumbers,
            'ExcludePunctuation': arguments.ExcludePunctuation,
            'ExcludeUppercase': arguments.ExcludeUppercase,
            'IncludeSpace': arguments.IncludeSpace,
            'RequireEachIncludedType': arguments.RequireEachIncludedType
        };
        return apiCall( requestSettings, 'GetRandomPassword', payload );
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
        headers[ 'X-Amz-Target' ] = 'secretsmanager' & '.' & arguments.target;
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
