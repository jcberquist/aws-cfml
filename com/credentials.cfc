component {

    public any function init(
        string awsKey = '',
        string awsSecretKey = '',
        any api
    ) {
        variables.api = api;
        variables.iamRolePath = '169.254.169.254/latest/meta-data/iam/security-credentials/';
        variables.iamRole = '';
        variables.credentials = resolveCredentials( awsKey, awsSecretKey );
        return this;
    }

    public struct function getCredentials() {
        if ( !isNull( credentials.expires ) && credentials.expires <= now() ) {
            refreshCredentials( credentials );
        }
        return credentials;
    }

    public struct function defaultCredentials(
        string awsKey = '',
        string awsSecretKey = '',
        string token = ''
    ) {
        return {
            awsKey: awsKey,
            awsSecretKey: awsSecretKey,
            token: token,
            expires: javacast( 'null', '' )
        };
    }

    private function resolveCredentials(
        awsKey,
        awsSecretKey
    ) {
        var credentials = defaultCredentials( awsKey, awsSecretKey );

        if ( len( credentials.awsKey ) && len( credentials.awsSecretKey ) ) {
            return credentials;
        }

        var utils = api.getUtils();

        // check environment
        credentials.awsKey = utils.getSystemSetting( 'AWS_ACCESS_KEY_ID', '' );
        credentials.awsSecretKey = utils.getSystemSetting( 'AWS_SECRET_ACCESS_KEY', '' );
        credentials.token = utils.getSystemSetting( 'AWS_SESSION_TOKEN', '' );

        if ( len( credentials.awsKey ) && len( credentials.awsSecretKey ) ) {
            return credentials;
        }

        // // check for an AWS credentials file
        var userHome = utils.getSystemSetting( 'user.home' ).replace( '\', '/', 'all' );
        var credentialsFile = utils.getSystemSetting( 'AWS_SHARED_CREDENTIALS_FILE', userHome & '/.aws/credentials' );
        var profile = utils.getSystemSetting( 'AWS_PROFILE', 'default' );
        credentials.awsKey = getProfileString( credentialsFile, profile, 'aws_access_key_id' ).trim();
        credentials.awsSecretKey = getProfileString( credentialsFile, profile, 'aws_secret_access_key' ).trim();
        credentials.token = getProfileString( credentialsFile, profile, 'aws_session_token' ).trim();

        if ( len( credentials.awsKey ) && len( credentials.awsSecretKey ) ) {
            return credentials;
        }

        // IAM role
        try {
            variables.iamRole = requestIamRole();
            if ( iamRole.len() ) {
                refreshCredentials( credentials );
            }
        } catch ( any e ) {
            // pass
        }

        if ( len( credentials.awsKey ) && len( credentials.awsSecretKey ) ) {
            return credentials;
        }

        throw( type = 'aws.com.credentials', message = 'Unable to resolve AWS credentials.' );
    }

    private string function requestIamRole() {
        var httpArgs = { };
        httpArgs[ 'httpMethod' ] = 'get';
        httpArgs[ 'path' ] = iamRolePath;
        httpArgs[ 'useSSL' ] = false;
        httpArgs[ 'timeout' ] = 1;
        var req = api.getHttpService().makeHttpRequest( argumentCollection = httpArgs );
        if ( listFirst( req.statuscode, ' ' ) == 408 ) return '';
        return req.filecontent;
    }

    private void function refreshCredentials(
        src
    ) {
        var httpArgs = { };
        httpArgs[ 'httpMethod' ] = 'get';
        httpArgs[ 'path' ] = iamRolePath & iamRole;
        httpArgs[ 'useSSL' ] = false;
        var req = api.getHttpService().makeHttpRequest( argumentCollection = httpArgs );
        var data = deserializeJSON( req.filecontent );
        src.awsKey = data.AccessKeyId;
        src.awsSecretKey = data.SecretAccessKey;
        src.token = data.Token;
        src.expires = parseDateTime( data.Expiration );
    }

}
