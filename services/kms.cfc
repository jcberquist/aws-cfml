component {

    variables.service = 'kms';

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

    /**
    * Returns a struct including the ciphertext blob representing the encrypted value
    * https://docs.aws.amazon.com/kms/latest/APIReference/API_Encrypt.html
    * @KeyId The AWS ID for the CMK Key, either the ID, the ARN, or an alias.
    * @Plaintext The data to be encrypted.
    * @EncryptionContext A struct of values used to validate during decryption. The values set during encryption must be the same during decryption.
    * @GrantTokens An array of strings corresponding to AWS grant tokens.
    */
    public any function encrypt(
        required string KeyId,
        required string Plaintext,
        struct EncryptionContext = { },
        array GrantTokens = [ ]
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );
        return apiCall( requestSettings, 'Encrypt', payload );
    }

    /**
    * Returns a struct including the plaintext value representing the decrypted value (may be Base64 encoded)
    * https://docs.aws.amazon.com/kms/latest/APIReference/API_Decrypt.html
    * @CiphertextBlob The data to be encrypted.
    * @EncryptionContext A struct of values used to validate during decryption. The values set during encryption must be the same during decryption.
    * @GrantTokens An array of strings corresponding to AWS grant tokens.
    */
    public any function decrypt(
        required string CiphertextBlob,
        struct EncryptionContext = { },
        array GrantTokens = [ ]
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );
        return apiCall( requestSettings, 'Decrypt', payload );
    }

    /**
    * Returns a struct including the ciphertext blob representing the re-encrypted value
    * https://docs.aws.amazon.com/kms/latest/APIReference/API_ReEncrypt.html
    * @CiphertextBlob The data to be re-encrypted.
    * @DestinationKeyId The AWS ID for the CMK Key to re-encrypt using, either the ID, the ARN, or an alias.
    * @DestinationEncryptionContext A struct of values used to validate during decryption. The values set during encryption must be the same during decryption.  This is the context to be used AFTER the value has been re-encrypted.
    * @SourceEncryptionContext A struct of values used to validate during decryption. The values set during encryption must be the same during decryption.  This is the context that was used when the value was first encrypted using the "old" key.
    * @GrantTokens An array of strings corresponding to AWS grant tokens.
    */
    public any function reEncrypt(
        required string CiphertextBlob,
        required string DestinationKeyId,
        struct DestinationEncryptionContext = { },
        struct SourceEncryptionContext = { },
        array GrantTokens = [ ]
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = buildPayload( arguments );
        return apiCall( requestSettings, 'ReEncrypt', payload );
    }

    // private methods

    private any function apiCall(
        required struct requestSettings,
        required string target,
        struct payload = { }
    ) {
        var host = variables.service & '.' & requestSettings.region & '.amazonaws.com';
        var payloadString = serializeJSON( payload );

        var headers = { };
        headers[ 'X-Amz-Target' ] = 'TrentService.' & arguments.target;
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

    private any function buildPayload(
        required any args
    ) {
        var payload = { };
        for ( var key in args ) {
            var keyIndex = variables.argumentKeys.findNoCase( key );
            if ( !keyIndex ) continue;
            var argType = variables.argumentTypes[ key ];
            var casedKey = variables.argumentKeys[ keyIndex ];
            switch ( argType ) {
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
            }
        }
        return payload;
    }

    private struct function getArgTypes() {
        var metadata = getMetadata( this );
        var typed = [ ];
        var result = { };

        for ( var funct in metadata.functions ) {
            if ( arrayFindNoCase( [ 'init' ], funct.name ) || funct.access != 'public' ) continue;
            for ( var param in funct.parameters ) {
                result[ param.name ] = typed.findNoCase( param.name ) ? 'typed' : param.type;
            }
        }

        return result;
    }

}
