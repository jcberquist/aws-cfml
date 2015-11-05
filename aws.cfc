component {

	public struct function init( required string awsKey, required string awsSecretKey, string region = 'us-east-1' ) {
		var utils = new com.utils();
		var signature_v4 = new com.signature_v4( awsKey, awsSecretKey, utils );
		var api = new com.api( utils, signature_v4 );
		var aws = { };
		aws[ 's3' ] = new services.s3( api, signature_v4, utils, arguments.region );
		aws[ 'dynamodb' ] = new services.dynamodb( api, arguments.region );
		aws[ 'elastictranscoder' ] = new services.elastictranscoder( api, arguments.region );
		return aws;
	}

}