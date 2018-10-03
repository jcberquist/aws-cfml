component {

    this.title = 'AWS CFML';
    this.author = 'John Berquist';
    this.webURL = 'https://github.com/jcberquist/aws-cfml';
    this.description = 'This module will provide you with connectivity to the AWS API for any ColdFusion (CFML) application.';

    /**
     * See README.md for the config struct options
     */
    function configure() {
        settings = {
            awsKey: '',
            awsSecretKey: '',
            defaultRegion: '',
            constructorArgs: { }
        };
    }

    function onLoad() {
        binder.map( 'aws@awscfml' )
            .to( '#moduleMapping#.aws' )
            .asSingleton()
            .initWith( argumentCollection = settings );
    }

}
