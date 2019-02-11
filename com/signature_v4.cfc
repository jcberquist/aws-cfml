component {

    public any function init( required any api ) {
        variables.utils = api.getUtils();
        variables.lf = chr( 10 );
        return this;
    }

    public struct function getHeadersWithAuthorization(
        required string service,
        required string host,
        required string region,
        required string httpMethod,
        required string path,
        required struct queryParams,
        required struct headers,
        required any payload,
        required struct awsCredentials
    ) {
        var isoTime = utils.iso8601();
        var requestHeaders = { 'X-Amz-Date': isoTime, 'Host': host };

        if ( len( awsCredentials.token ) ) {
            requestHeaders[ 'X-Amz-Security-Token' ] = awsCredentials.token;
        }
        requestHeaders.append(headers);

        var canonicalRequest = createCanonicalRequest( httpMethod, path, queryParams, requestHeaders, payload );
        var stringToSign = createStringToSign( region, service, isoTime, canonicalRequest );
        var credentialScope = stringToSign.listGetAt( stringToSign.listLen( lf ) - 1, lf );
        var signedHeaders = canonicalRequest.listGetAt( canonicalRequest.listLen( lf ) - 1, lf );
        var signature = sign( awsCredentials, isoTime.left( 8 ), region, service, stringToSign );

        var authorization = 'AWS4-HMAC-SHA256 ';
        authorization &= 'Credential=' & awsCredentials.awsKey & '/' & credentialScope & ', ';
        authorization &= 'SignedHeaders=' & signedHeaders & ', ';
        authorization &= 'Signature=' & signature;

        requestHeaders[ 'Authorization' ] = authorization;
        return requestHeaders;
    }

    public struct function getQueryParamsWithAuthorization(
        required string service,
        required string host,
        required string region,
        required string httpMethod,
        required string path,
        required struct queryParams,
        required numeric expires,
        required struct awsCredentials
    ) {
        var isoTime = utils.iso8601();
        var params = {};
        params.append( queryParams );
        params.append( getAuthorizationParams( service, region, isoTime, awsCredentials ) );
        params[ 'X-Amz-SignedHeaders' ] = 'host';
        params[ 'X-Amz-Expires' ] = expires;

        var canonicalRequest = createCanonicalRequest( httpMethod, path, params, { 'Host': host }, '', true );
        var stringToSign = createStringToSign( region, service, isoTime, canonicalRequest );
        // writeDump( canonicalRequest );
        // writeDump( stringToSign );
        params[ 'X-Amz-Signature' ] = sign( awsCredentials, isoTime.left( 8 ), region, service, stringToSign );
        return params;
    }

    public struct function getAuthorizationParams(
        required string service,
        required string region,
        required string isoTime,
        required struct awsCredentials
    ) {
        var params = {
            'X-Amz-Algorithm': 'AWS4-HMAC-SHA256',
            'X-Amz-Credential': awsCredentials.awsKey & '/' & isoTime.left( 8 ) & '/' & region & '/' & service & '/aws4_request',
            'X-Amz-Date': isoTime
        };

        if ( len( awsCredentials.token ) ) {
            params[ 'X-Amz-Security-Token' ] = awsCredentials.token;
        }

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
        required struct awsCredentials,
        required string isoDateShort,
        required string region,
        required string service,
        required string stringToSign
    ) {
        var signingKey = binaryDecode( hmac( isoDateShort, 'AWS4' & awsCredentials.awsSecretKey, 'hmacSHA256', 'utf-8' ), 'hex' );
        signingKey = binaryDecode( hmac( region, signingKey, 'hmacSHA256', 'utf-8' ), 'hex' );
        signingKey = binaryDecode( hmac( service, signingKey, 'hmacSHA256', 'utf-8' ), 'hex' );
        signingKey = binaryDecode( hmac( 'aws4_request', signingKey, 'hmacSHA256', 'utf-8' ), 'hex' );
        return hmac( stringToSign, signingKey, 'hmacSHA256', 'utf-8' ).lcase();
    }

}
