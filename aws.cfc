component {

    variables.services = [
        's3',
        'dynamodb',
        'elastictranscoder',
        'elasticsearch'
    ];
    variables.constructorArgs = {
        s3: { },
        dynamodb: { apiVersion: '20120810' },
        elastictranscoder: { apiVersion: '2012-09-25' },
        elasticsearch: { endpoint: '' }
    };

    public struct function init(
        string awsKey = '',
        string awsSecretKey = '',
        string defaultRegion = '',
        struct constructorArgs = { }
    ) {
        this.api = new com.api( awsKey, awsSecretKey, defaultRegion );

        for ( var service in variables.services ) {
            if ( structKeyExists( arguments.constructorArgs, service ) ) {
                structAppend( variables.constructorArgs[ service ], arguments.constructorArgs[ service ] );
            }
            this[ service ] = new 'services.#service#'( this.api, variables.constructorArgs[ service ] );
        }

        return this;
    }

}
