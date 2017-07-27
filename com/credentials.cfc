component {

    public any function init(
        string awsKey = '',
        string awsSecretKey = '',
        any httpService
    ) {
        variables.iamRolePath = '169.254.169.254/latest/meta-data/iam/security-credentials/';
        variables.awsKey = arguments.awsKey;
        variables.awsSecretKey = arguments.awsSecretKey;
        variables.token = '';
        variables.expires = len( arguments.awsKey ) ? javacast('null', '') : now();
        variables.iamRole = '';
        variables.httpService = httpService;
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
        if ( len( iamRole ) == 0 ) requestIamRole();

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

    private void function requestIamRole() {
        var httpArgs = { };
        httpArgs[ 'httpMethod' ] = 'get';
        httpArgs[ 'path' ] = iamRolePath;
        httpArgs[ 'useSSL' ] = false;
        var req = httpService.makeHttpRequest( argumentCollection = httpArgs );
        iamRole = req.filecontent;
    }

}
