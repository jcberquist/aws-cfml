component {

    variables.services = [ 's3', 'dynamodb', 'elastictranscoder', 'elasticsearch' ];
    variables.constructorArgs = {
        s3: { },
        dynamodb: { apiVersion: '20120810' },
        elastictranscoder: { apiVersion: '2012-09-25' },
        elasticsearch: { endpoint: '' }
    };

    public struct function init(
        string awsKey = '',
        string awsSecretKey = '',
        string defaultRegion = 'us-east-1',
        struct constructorArgs = { }
    ) {
        var aws = { 'api': new com.api( arguments.awsKey, arguments.awsSecretKey, arguments.defaultRegion ) };
        for ( var service in variables.services ) {
            if ( structKeyExists( arguments.constructorArgs, service ) ) {
                structAppend( variables.constructorArgs[ service ], arguments.constructorArgs[ service ] );
            }
            aws[ service ] = new 'services.#service#'( aws.api, variables.constructorArgs[ service ] );
        }
        return aws;
    }

}
