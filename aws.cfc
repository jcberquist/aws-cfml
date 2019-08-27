component {

    variables.services = [
        'cognitoIdentity',
        'dynamodb',
        'elasticsearch',
        'elastictranscoder',
        'kms',
        'personalize',
        'personalizeEvents',
        'personalizeRuntime',
        's3',
        'sns',
        'sqs',
        'rekognition',
        'translate'
    ];

    variables.constructorArgs = {
        cognitoIdentity: { apiVersion: '2014-06-30' },
        dynamodb: { apiVersion: '20120810' },
        elastictranscoder: { apiVersion: '2012-09-25' },
        elasticsearch: { endpoint: '' },
        kms: { apiVersion: '2014-11-01' },
        personalize: { apiVersion: '2018-05-22' },
        personalizeRuntime: { apiVersion: '2018-05-22' },
        personalizeEvents: { apiVersion: '2018-03-22' },
        rekognition: { apiVersion: '2016-06-27' },
        s3: { host: '', useSSL: true },
        sns: { apiVersion: '2010-03-31' },
        sqs: { apiVersion: '2012-11-05' },
        translate: { apiVersion: '20170701', defaultSourceLanguageCode: 'es', defaultTargetLanguageCode: 'en' }
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
