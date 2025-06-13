component {

    public any function init(
        string awsKey = '',
        string awsSecretKey = '',
        any api
    ) {
        variables.api = api;
        variables.iamRolePath = '169.254.169.254/latest/meta-data/iam/security-credentials/';
        variables.ecsEndpoint = '169.254.170.2';
        variables.iamRole = '';
        variables.credentialPath = '';
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

        // IAM role (ECS)
        var relativeUri = utils.getSystemSetting( 'AWS_CONTAINER_CREDENTIALS_RELATIVE_URI', '' );
        if ( len( relativeUri ) ) {
            variables.credentialPath = ecsEndpoint & relativeUri;
            refreshCredentials( credentials );
        }

        if ( len( credentials.awsKey ) && len( credentials.awsSecretKey ) ) {
            return credentials;
        }


        // IAM role (EC2)
        try {
            variables.iamRole = requestIamRole();
            if ( iamRole.len() ) {
                variables.credentialPath = iamRolePath & iamRole;
                refreshCredentials( credentials );
            }
        } catch ( any e ) {
            // pass
        }

        if ( len( credentials.awsKey ) && len( credentials.awsSecretKey ) ) {
            return credentials;
        }

        // SSO
        try {
            var configFile = utils.getSystemSetting( 'AWS_CONFIG_FILE', userHome & '/.aws/config' );
            var sso_path = getDirectoryFromPath(configFile)&'sso/cache/';
            var sso_account_id = getProfileString( configFile,'profile #profile#', 'sso_account_id' ).trim();
            var sso_role_name  = getProfileString( configFile,'profile #profile#', 'sso_role_name' ).trim();

            var files = directoryList( sso_path,false,'query','*.json','dateLastModified desc' )

            var sso_cache = deserializeJSON(fileRead( sso_path&files.name[1] ))
            var sso_access_token = sso_cache.accessToken
            var sso_region = sso_cache.region

            httpArgs = { };
            httpArgs[ 'httpMethod' ] = 'get';
            //httpArgs[ 'host' ] = 'sts.amazonaws.com';
            httpArgs[ 'path' ] = 'portal.sso.#sso_region#.amazonaws.com/federation/credentials';
            httpArgs[ 'queryParams'] = {
                'account_id':sso_account_id,
                'role_name' :sso_role_name
            }
            httpArgs[ 'useSSL' ] = true;
            httpArgs[ 'timeout' ] = 1;
            httpArgs[ 'headers' ] = {'x-amz-sso_bearer_token':sso_access_token};
            var req = api.getHttpService().makeHttpRequest( argumentCollection = httpArgs );

            if ( req.status_code eq 200 and isJson( req.filecontent ) ) {
                var r = deserializeJSON( req.filecontent );
                credentials = { 
                    awsKey       : r.roleCredentials.accessKeyId,
                    awsSecretKey : r.roleCredentials.secretAccessKey,
                    token        : r.roleCredentials.sessionToken
                };
                if ( len( credentials.awsKey ) && len( credentials.awsSecretKey ) ) {
                    return credentials;
                }
            }
        } catch ( any e ) {
            // pass
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
        httpArgs[ 'path' ] = credentialPath;
        httpArgs[ 'useSSL' ] = false;
        var req = api.getHttpService().makeHttpRequest( argumentCollection = httpArgs );
        var data = deserializeJSON( req.filecontent );
        src.awsKey = data.AccessKeyId;
        src.awsSecretKey = data.SecretAccessKey;
        src.token = data.Token;
        src.expires = parseDateTime( data.Expiration );
    }

}
