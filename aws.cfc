component {

    variables.services = [
        'dynamodb',
        'elasticsearch',
        'elastictranscoder',
        's3',
        'sns',
        'sqs',
        'translate'
    ];

    variables.constructorArgs = {
        s3: { },
        dynamodb: { apiVersion: '20120810' },
        elastictranscoder: { apiVersion: '2012-09-25' },
        elasticsearch: { endpoint: '' },
        sns: { apiVersion: '2010-03-31' },
        sqs: { apiVersion: '2012-11-05' },
        translate: {
          defaultSourceLanguageCode: 'es',
          defaultTargetLanguageCode: 'en'
        }
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
