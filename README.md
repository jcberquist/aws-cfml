# aws-cfml

**aws-cfml** is a CFML library for interacting with the AWS S3 and AWS DynamoDB REST API's.

It is set up so that other AWS services can be added, but at the moment these services are the only ones included. (There is the stub of a CFC for interacting with the ElasticTranscoder API).

It currently supports only AWS Signature v4 for authentication.

**It will run on Lucee 4.5+ and ColdFusion 11+.**

## Getting Started

	// aws.cfc returns a struct of CFC's for interacting with AWS services
	aws = new aws( awsKey = 'YOUR_PUBLIC_KEY', awsSecretKey = 'YOUR_PRIVATE_KEY', region = 'us-east-1' );

	buckets = aws.s3.listBuckets();
	tables = aws.dynamodb.listTables();

All responses are returned as a struct with the following format:

	response = {
		responseHeaders: { } // struct containing the headers returned from the HTTP request
		responseTime: 123 // time in milliseconds of the HTTP request
		statusCode: 200 // status code returned
		statusText: 'OK' // status text returned
		rawData: bodyOfHTTPResponse // whatever was in the body of the HTTP request response
		data: parsedRawData // the rawData response parsed into CFML (from XML or JSON)
	};

_Note:_ The `data` key might not be present if the request is one where it does not make sense to parse the body of the response. (For instance when getting an object from S3.)

### DynamoDB

DynamoDB data is typed. The types supported are `Number`, `String`, `Binary`, `Boolean`, `Null`, `String Set`, `Number Set`, `Binary Set`, `List` and `Map`.
http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DataModel.html#DataModel.DataTypes

This library's DynamoDB implementation is set up to work with CFML types by default, so that you can supply data in a struct containing string, number, boolean, binary, null, array and struct values. Structs and arrays can be nested. Everything is then type encoded automatically.

_Note:_ This has worked really well for me on Lucee, however, it might not work as well with ColdFusion due to its less accurate variable typing. In both cases, keep in mind that data will typed as a `Number` if an `isNumeric()` check returns true, which it may well do in situations you do not expect. In addition, when using ColdFusion the `serializeJSON()` function seems to want to encode anything that can be cast as a number to a number in the JSON string, so the JSON string has to be edited by `dynamodb.cfc` before posting it to DynamoDB. It seems to work in my (limited) testing, but it is quite possible I have missed some of the encoding mistakes, which would lead to DynamoDB returning errors for invalidly encoded JSON strings.

Similarily when you retrieve data from a DynamoDB table, it will be automatically decoded for you, so that you get back a struct of data for each row.

Here is an example:

	// putting an item with a HASH key of `id = 1`
	// note that table HASH and RANGE key values are included in the item struct
	item = {
		'id': 1,
		'thisisnull': javaCast( 'null', '' ),
		'number': 3.45,
		'nested': {
			'list': [ 'foo', 2 ]
		}
	};
	putItemResult = aws.dynamodb.putItem( 'myTableName', item );

	// getting that item
	itemFromDynamoDB = aws.dynamodb.getItem( 'myTableName', { 'id': 1 } );

If you do not want your data to be type encoded automatically you have two options. The first is to pass the argument `typeDefinitions = typeDefStruct` into a method where `typeDefStruct` is a struct whose keys match keys in your item, and whose values are the types of the key values in your item. Where a key match is found, `dynamodb.cfc` will use the specified type for encoding rather than attempting to determine the type.

 The other option is to pass `dataTypeEncoding = false` to any method, and data will be not be encoded at all. (Thus you will need to encode items yourself.)

 _Note:_ If you want to use non-native CFML types such as the various set types, you will need to use one of these latter two options when putting items.

### S3

Most basic operations are supported for S3. However, there is currently no support for updating bucket settings. Support for encrypted buckets and objects is also missing.

TODO: provide an example for using the `getFormPostParams()` method.