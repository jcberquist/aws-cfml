component {

    public any function init( string awsKey = '', string awsSecretKey = '', any httpService ) {
        variables.iamRolePath = '169.254.169.254/latest/meta-data/iam/security-credentials/';
        variables.httpService = httpService;

        variables.awsKey = '';
        variables.awsSecretKey = '';
        variables.token = '';
        variables.expires = javacast( 'null', '' );
        variables.iamRole = '';

        setAccessKeys(arguments.awsKey, arguments.awsSecretKey);
        return this;
    }

    public string function get(
        required string key
    ) {
        if ( isExpired() ) refresh();
        return variables[ key ];
    }

    private boolean function isExpired() {
        return !isNull( expires ) && expires <= now();
    }

    private void function refresh() {
        var httpArgs = { };
        httpArgs[ 'httpMethod' ] = 'get';
        httpArgs[ 'path' ] = iamRolePath & iamRole;
        httpArgs[ 'useSSL' ] = false;
        var req = httpService.makeHttpRequest( argumentCollection = httpArgs );

        var data = deserializeJSON( req.filecontent );
        awsKey = data.AccessKeyId;
        awsSecretKey = data.SecretAccessKey;
        token = data.Token;
        expires = parseDateTime( data.Expiration );
    }

    private void function setAccessKeys( awsKey, awsSecretKey ) {
        var keyNameMap = { 'awsKey': 'AWS_ACCESS_KEY_ID', 'awsSecretKey': 'AWS_SECRET_ACCESS_KEY' };
        var keys = { };

        // check for passed in keys
        for ( var key in keyNameMap ) variables[ key ] = arguments[ key ];
        if ( len( variables.awsKey ) ) return;

        var system = createObject( 'java', 'java.lang.System' );

        // environment variables
        for ( var key in keyNameMap ) variables[ key ] = system.getenv( keyNameMap[ key ] );
        if ( !isNull( variables.awsKey ) ) return;

        // java system properties
        for ( var key in keyNameMap ) variables[ key ] = system.getProperty( keyNameMap[ key ] );
        if ( !isNull( variables.awsKey ) ) return;

        // IAM role
        variables.iamRole = requestIamRole();
        if ( !len( variables.iamRole ) ) throw( type = 'aws.com.credentials', message = 'Unable to fetch IAM role.' );
        refresh();
    }

    private string function requestIamRole() {
        var httpArgs = { };
        httpArgs[ 'httpMethod' ] = 'get';
        httpArgs[ 'path' ] = iamRolePath;
        httpArgs[ 'useSSL' ] = false;
        httpArgs[ 'timeout' ] = 5;
        var req = httpService.makeHttpRequest( argumentCollection = httpArgs );
        if ( listFirst( req.statuscode, ' ' ) == 408 ) return '';
        return req.filecontent;
    }

}
