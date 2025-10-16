component {

    variables.iamRolePath = '169.254.169.254/latest/meta-data/iam/security-credentials/';
    variables.ecsEndpoint = '169.254.170.2';

    public any function init(
        string awsKey = '',
        string awsSecretKey = '',
        any api
    ) {
        variables.api = api;
        variables.credentials = resolveCredentials( awsKey, awsSecretKey );
        return this;
    }

    public struct function getCredentials() {
        if (
            !isNull( variables.credentials.expires ) &&
            variables.credentials.expires <= now()
        ) {
            variables.credentials = refreshCredentials( variables.credentials );
        }
        return variables.credentials.keys;
    }

    public struct function defaultCredentials(
        string awsKey = '',
        string awsSecretKey = '',
        string token = ''
    ) {
        return { awsKey: awsKey, awsSecretKey: awsSecretKey, token: token };
    }

    private function resolveCredentials(
        awsKey,
        awsSecretKey
    ) {
        // explicit
        var credentials = {
            keys: defaultCredentials( awsKey, awsSecretKey ),
            type: 'explicit',
            expires: javacast( 'null', '' ),
            refresh: { }
        };
        if ( validCredentials( credentials ) ) {
            return credentials;
        }

        var utils = api.getUtils();


        // environment
        var credentials = {
            keys: {
                'awsKey': utils.getSystemSetting( 'AWS_ACCESS_KEY_ID', '' ),
                'awsSecretKey': utils.getSystemSetting( 'AWS_SECRET_ACCESS_KEY', '' ),
                'token': utils.getSystemSetting( 'AWS_SESSION_TOKEN', '' )
            },
            type: 'environment',
            expires: javacast( 'null', '' ),
            refresh: { }
        };
        if ( validCredentials( credentials ) ) {
            return credentials;
        }

        var userHome = utils.getSystemSetting( 'user.home' ).replace( '\', '/', 'all' );
        var awsProfile = utils.getSystemSetting( 'AWS_PROFILE', 'default' );


        // AWS credentials file
        var credentialsFile = utils.getSystemSetting( 'AWS_SHARED_CREDENTIALS_FILE', userHome & '/.aws/credentials' );

        if ( fileExists( credentialsFile ) ) {
            var credentialProcess = getProfileString( credentialsFile, awsProfile, 'credential_process' ).trim();
            if ( len( credentialProcess ) ) {
                var credentials = credentialsFromProcess( credentialProcess );
                if ( validCredentials( credentials ) ) {
                    return credentials;
                }
            }

            var credentials = {
                keys: {
                    'awsKey': getProfileString( credentialsFile, awsProfile, 'aws_access_key_id' ).trim(),
                    'awsSecretKey': getProfileString( credentialsFile, awsProfile, 'aws_secret_access_key' ).trim(),
                    'token': getProfileString( credentialsFile, awsProfile, 'aws_session_token' ).trim()
                },
                type: 'credentialsFile',
                expires: javacast( 'null', '' ),
                refresh: { }
            };
            if ( validCredentials( credentials ) ) {
                return credentials;
            }
        }


        // AWS config file
        var configFile = utils.getSystemSetting( 'AWS_CONFIG_FILE', userHome & '/.aws/config' );
        if ( fileExists( configFile ) ) {
            var awsConfigProfile = awsProfile == 'default' ? 'default' : 'profile #awsProfile#';

            var credentialProcess = getProfileString( configFile, awsConfigProfile, 'credential_process' ).trim();
            if ( len( credentialProcess ) ) {
                var credentials = credentialsFromProcess( credentialProcess );
                if ( validCredentials( credentials ) ) {
                    return credentials;
                }
            }

            var sso_account_id = getProfileString( configFile, awsConfigProfile, 'sso_account_id' ).trim();
            var sso_role_name = getProfileString( configFile, awsConfigProfile, 'sso_role_name' ).trim();
            var sso_session = getProfileString( configFile, awsConfigProfile, 'sso_session' ).trim();

            if ( len( sso_account_id ) && len( sso_role_name ) ) {
                if ( len( sso_session ) ) {
                    var ssoSessionProfile = 'sso-session #sso_session#';
                    var sso_start_url = getProfileString( configFile, ssoSessionProfile, 'sso_start_url' ).trim();
                    var sso_region = getProfileString( configFile, ssoSessionProfile, 'sso_region' ).trim();
                    var cacheKey = lCase( hash( sso_session, 'SHA-1' ) );
                } else {
                    var sso_start_url = getProfileString( configFile, awsConfigProfile, 'sso_start_url' ).trim();
                    var sso_region = getProfileString( configFile, awsConfigProfile, 'sso_region' ).trim();
                    var cacheKey = lCase( hash( sso_start_url, 'SHA-1' ) );
                }

                if ( len( sso_start_url ) && len( sso_region ) ) {
                    var cacheFilePath = userHome & '/.aws/sso/cache/#cacheKey#.json';
                    if ( fileExists( cacheFilePath ) ) {
                        var cacheData = deserializeJSON( fileRead( cacheFilePath ) );
                        var expiresAt = parseDateTime( cacheData.expiresAt );
                        if ( expiresAt >= now() ) {
                            var httpArgs = {
                                'path': 'portal.sso.#sso_region#.amazonaws.com/federation/credentials',
                                'useSSL': true,
                                'headers': { 'x-amz-sso_bearer_token': cacheData.accessToken },
                                'queryParams': { 'account_id': sso_account_id, 'role_name': sso_role_name }
                            };

                            var credentials = fetchCredentials( sso, httpArgs );
                            if ( validCredentials( credentials ) ) {
                                return credentials;
                            }
                        }
                    }
                }
            }
        }


        // IAM role (ECS)
        var relativeUri = utils.getSystemSetting( 'AWS_CONTAINER_CREDENTIALS_RELATIVE_URI', '' );
        if ( len( relativeUri ) ) {
            var httpArgs = { 'path': variables.ecsEndpoint & relativeUri };
            var credentials = fetchCredentials( 'ecsContainer', httpArgs );
            if ( validCredentials( credentials ) ) {
                return credentials;
            }
        }


        // IAM role (EC2)
        try {
            var iamRole = requestIamRole();
            if ( len( iamRole ) ) {
                var httpArgs = { 'path': variables.iamRolePath & iamRole };
                var credentials = fetchCredentials( 'iamRole', httpArgs );
                if ( validCredentials( credentials ) ) {
                    return credentials;
                }
            }
        } catch ( any e ) {
            // pass
        }

        throw( type = 'aws.com.credentials', message = 'Unable to resolve AWS credentials.' );
    }

    private boolean function validCredentials(
        credentials
    ) {
        return len( credentials.keys.awsKey ) && len( credentials.keys.awsSecretKey );
    }

    private struct function refreshCredentials(
        credentials
    ) {
        if ( credentials.type == 'credentialProcess' ) {
            return credentialsFromProcess( credentials.refresh.credentialProcess );
        }
        if (
            credentials.type == 'ecsContainer' ||
            credentials.type == 'iamRole' ||
            credentials.type == 'sso'
        ) {
            return fetchCredentials( credentials.type, credentials.refresh.httpArgs );
        }
        throw( type = 'aws.com.credentials', message = 'Unable to refresh AWS credentials.' );
    }

    private struct function credentialsFromProcess(
        credentialProcess
    ) {
        var data = '';
        cfexecute( name = credentialProcess, variable = "data" );
        data = deserializeJSON( data );
        return {
            keys: { 'awsKey': data.AccessKeyId, 'awsSecretKey': data.SecretAccessKey, 'token': data.SessionToken },
            type: 'credentialProcess',
            expires: parseDateTime( data.Expiration ),
            refresh: { credentialProcess: credentialProcess }
        };
    }

    private struct function fetchCredentials(
        credentialsType,
        httpArgs
    ) {
        var args = { 'httpMethod': 'get', 'useSSL': false };
        structAppend( args, httpArgs );
        var req = api.getHttpService().makeHttpRequest( argumentCollection = args );
        var data = deserializeJSON( req.filecontent );

        if ( credentialsType == 'sso' ) {
            var keys = {
                'awsKey': data.roleCredentials.accessKeyId,
                'awsSecretKey': data.roleCredentials.secretAccessKey,
                'token': data.roleCredentials.sessionToken
            };
            var epochDate = createObject( 'java', 'java.util.Date' ).init( javacast( 'int', 0 ) );
            var expires = dateAdd( 'l', roleCredentials.expiration, variables.epochDate );
        } else {
            var keys = { 'awsKey': data.AccessKeyId, 'awsSecretKey': data.SecretAccessKey, 'token': data.Token };
            var expires = parseDateTime( data.Expiration );
        }

        return {
            keys: keys,
            type: credentialsType,
            expires: expires,
            refresh: { httpArgs: httpArgs }
        };
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

}
