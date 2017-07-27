component {

	public any function init(
		required any credentials,
		required any utils
	) {
		variables.credentials = arguments.credentials;
		variables.utils = arguments.utils;
		variables.lf = chr( 10 );
		return this;
	}

	public string function getAuthorization(
		required string service,
		required string region,
		required string isoTime,
		required string httpMethod,
		required string path,
		required struct queryParams,
		required struct headers,
		required any payload
	) {
		var canonicalRequest = createCanonicalRequest( httpMethod, path, queryParams, headers, payload );
		var stringToSign = createStringToSign( region, service, isoTime, canonicalRequest );
		// writeDump( canonicalRequest );
		// writeDump( stringToSign );
		var credentialScope = stringToSign.listGetAt( stringToSign.listLen( lf ) - 1, lf );
		var signedHeaders = canonicalRequest.listGetAt( canonicalRequest.listLen( lf ) - 1, lf );
		var signature = sign( isoTime.left( 8 ), region, service, stringToSign );
		var authorization = 'AWS4-HMAC-SHA256 ';
		authorization &= 'Credential=' & credentials.get( 'awsKey' ) & '/' & credentialScope & ', ';
		authorization &= 'SignedHeaders=' & signedHeaders & ', ';
		authorization &= 'Signature=' & signature;
		return authorization;
	}

	public struct function appendAuthorizationQueryParams(
		required string service,
		required string host,
		required string region,
		required string isoTime,
		required string httpMethod,
		required string path,
		required struct queryParams
	) {
		var params = getAuthorizationParams( service, region, isoTime );
		params.append( queryParams );
		params[ 'X-Amz-SignedHeaders' ] = 'host';

		var token = credentials.get( 'token' );
    	if ( len( token ) ) params[ 'X-Amz-Security-Token' ] = token;

		var canonicalRequest = createCanonicalRequest( httpMethod, path, params, { 'Host': host }, '', true );
		var stringToSign = createStringToSign( region, service, isoTime, canonicalRequest );
		// writeDump( canonicalRequest );
		// writeDump( stringToSign );
		params[ 'X-Amz-Signature' ] = sign( isoTime.left( 8 ), region, service, stringToSign );
		return params;
	}

	public struct function getAuthorizationParams(
		required string service,
		required string region,
		required string isoTime
	) {
		var params = {
			'X-Amz-Algorithm': 'AWS4-HMAC-SHA256',
			'X-Amz-Credential': credentials.get( 'awsKey' ) & '/' & isoTime.left( 8 ) & '/' & region & '/' & service & '/aws4_request',
			'X-Amz-Date': isoTime
		};
		return params;
	}

	public string function createCanonicalRequest(
		required string httpMethod,
		required string path,
		required struct queryParams,
		required struct headers,
		required any payload,
		boolean unsignedPayload = false
	) {
		var result = [ ];
		result.append( httpMethod );
		result.append( utils.encodeUrl( path, false ) );
		result.append( utils.parseQueryParams( queryParams ) );

		var headersParsed = utils.parseHeaders( headers );
		for ( var header in headersParsed ) {
			result.append( header.name & ':' & header.value );
		}

		result.append( '' );
		result.append( headersParsed.map( function( header ) { return header.name; } ).toList( ';' ) );
		if ( unsignedPayload ) {
			result.append( 'UNSIGNED-PAYLOAD' );
		} else {
			result.append( hash( payload, 'SHA-256' ).lcase() );
		}
		return result.toList( lf );
	}

	public string function createStringToSign(
		required string region,
		required string service,
		required string isoTime,
		required string canonicalRequest
	) {
		var result = [ ];
		result.append( 'AWS4-HMAC-SHA256' );
		result.append( isoTime );
		result.append( isoTime.left( 8 ) & '/' & region & '/' & service & '/aws4_request'  );
		result.append( hash( canonicalRequest, 'SHA-256' ).lcase() );
		return result.toList( lf );
	}

	public string function sign(
		required string isoDateShort,
		required string region,
		required string service,
		required string stringToSign
	) {
		var signingKey = binaryDecode( hmac( isoDateShort, 'AWS4' & credentials.get( 'awsSecretKey' ), 'hmacSHA256', 'utf-8' ), 'hex' );
		signingKey = binaryDecode( hmac( region, signingKey, 'hmacSHA256', 'utf-8' ), 'hex' );
		signingKey = binaryDecode( hmac( service, signingKey, 'hmacSHA256', 'utf-8' ), 'hex' );
		signingKey = binaryDecode( hmac( 'aws4_request', signingKey, 'hmacSHA256', 'utf-8' ), 'hex' );
		return hmac( stringToSign, signingKey, 'hmacSHA256', 'utf-8' ).lcase();
	}

}
