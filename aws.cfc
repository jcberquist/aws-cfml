component {

    // Docs: https://github.com/jcberquist/aws-cfml

    variables.services = [
        'autoscaling',
        'cognitoIdentity',
        'dynamodb',
        'ec2',
        'elasticsearch',
        'elastictranscoder',
        'kms',
        'personalize',
        'personalizeEvents',
        'personalizeRuntime',
        'polly',
        'rekognition',
        's3',
        'secretsmanager',
        'sns',
        'sqs',
        'ssm',
        'translate'
    ];

    variables.constructorArgs = {
        autoscaling: { apiVersion: '2011-01-01' },
        cognitoIdentity: { apiVersion: '2014-06-30' },
        dynamodb: { apiVersion: '20120810' },
        elastictranscoder: { apiVersion: '2012-09-25' },
        elasticsearch: { endpoint: '' },
        kms: { apiVersion: '2014-11-01' },
        personalize: { apiVersion: '2018-05-22' },
        personalizeRuntime: { apiVersion: '2018-05-22' },
        personalizeEvents: { apiVersion: '2018-03-22' },
        polly: { apiVersion: '2016-06-10', defaultLanguageCode: 'en-US', defaultEngine: 'standard' },
        rekognition: { apiVersion: '2016-06-27' },
        s3: { host: '', useSSL: true },
        secretsmanager: { apiVersion: '2017-10-17' },
        sns: { apiVersion: '2010-03-31' },
        ssm: { apiVersion: '2014-11-06' },
        sqs: { apiVersion: '2012-11-05' },
        translate: { apiVersion: '20170701', defaultSourceLanguageCode: 'es', defaultTargetLanguageCode: 'en' },
        ec2: { apiVersion: '2016-11-15' }
    };

    public struct function init(
        string awsKey = '',
        string awsSecretKey = '',
        string defaultRegion = '',
        struct constructorArgs = { },
        struct httpProxy = { server: '', port: 80 },
        string libraryMapping = ''
    ) {
        if ( len( arguments.libraryMapping ) && mid( arguments.libraryMapping, len( arguments.libraryMapping ), 1 ) != '.' ) {
            arguments.libraryMapping &= '.';
        }

        this.api = new '#arguments.libraryMapping#com.api'(
            awsKey,
            awsSecretKey,
            defaultRegion,
            httpProxy,
            libraryMapping
        );

        for ( var service in variables.services ) {
            if ( structKeyExists( arguments.constructorArgs, service ) ) {
                structAppend( variables.constructorArgs[ service ], arguments.constructorArgs[ service ] );
            }
            this[ service ] = new '#arguments.libraryMapping#services.#service#'(
                this.api, variables.constructorArgs[ service ]
            );
        }

        return this;
    }

}
