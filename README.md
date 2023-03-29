# aws-cfml

**aws-cfml** is a CFML library for interacting with AWS APIs.

**It requires Lucee 4.5+ or ColdFusion 11+.**

It currently supports the following APIs:
 - cognitoIdentity
 - connect
 - dynamodb
 - ec2
 - ec2 auto-scaling groups
 - elasticsearch
 - elastictranscoder
 - polly
 - rekognition
 - s3
 - secretsmanager
 - sns
 - ssm
 - sqs
 - translate

_Note: It has full support for the AWS S3 and AWS DynamoDB REST APIs. Other services are supported to varying degrees - if you are using a service and add a method you need, please consider contributing it back to this project. My thanks to [@davidsf](https://github.com/davidsf) and [@sjdaniels](https://github.com/sjdaniels) who contributed the translate and rekognition service components respectively._

**aws-cfml** also supports making signed requests to arbitrary AWS endpoints. It currently supports only AWS Signature v4 for authentication.

## Installation
This wrapper can be installed as standalone library or as a ColdBox Module. Either approach requires a simple CommandBox command:

```
$ box install aws-cfml
```

Alternatively the git repository can be cloned into the desired directory.

### Standalone Usage

Once the library has been installed, the core `aws` component can be instantiated directly:

```cfc
aws = new path.to.awscfml.aws(
    awsKey = 'YOUR_PUBLIC_KEY',
    awsSecretKey = 'YOUR_PRIVATE_KEY',
    defaultRegion = 'us-east-1'
);
```

*Note: An optional `httpProxy` argument is available when initializing the core `aws` component (a struct with `server` and `port` keys).  When set this will proxy all AWS requests.*

### ColdBox Module

To use the library as a ColdBox Module, add the init arguments to the `moduleSettings` struct in `config/Coldbox.cfc`:

```cfc
moduleSettings = {
    awscfml: {
        awsKey: '',
        awsSecretKey: '',
        defaultRegion: ''
    }
}
```

You can then leverage the library via the injection DSL: `aws@awscfml`:

```cfc
property name="aws" inject="aws@awscfml";
```

*Note: You can bypass the init arguments altogether and use environment variables, a credentials file, or an IAM role with aws-cfml. See [Credentials](#credentials) below.*

## Getting Started

```cfc
// aws.cfc contains components for interacting with AWS services
aws = new aws(awsKey = 'YOUR_PUBLIC_KEY', awsSecretKey = 'YOUR_PRIVATE_KEY', defaultRegion = 'us-east-1');

buckets = aws.s3.listBuckets();
tables = aws.dynamodb.listTables();

// you can make signed requests to any AWS endpoint using the following:
response = aws.api.call(service, host, region, httpMethod, path, queryParams, headers, body, awsCredentials);

// using named arguments you can supply a `region` to any method call
// this overrides the default region set at init
response = aws.s3.listBucket(region = 'us-west-1', bucket = 'mybucket');
```

All responses are returned as a struct with the following format:

```cfc
response = {
    responseHeaders: { } // struct containing the headers returned from the HTTP request
    responseTime: 123 // time in milliseconds of the HTTP request
    statusCode: 200 // status code returned
    rawData: bodyOfHTTPResponse // whatever was in the body of the HTTP request response
    data: parsedRawData // the rawData response parsed into CFML (from XML or JSON)
};
```

_Note:_ The `data` key might not be present if the request is one where it does not make sense to parse the body of the response. (For instance when getting an object from S3.)

## Credentials

You can supply an aws key and secret key at initialization:

```cfc
aws = new aws( awsKey = 'YOUR_PUBLIC_KEY', awsSecretKey = 'YOUR_PRIVATE_KEY' )
```

If you do not then `aws-cfml` will follow the configuration resolution followed by the AWS CLI: <https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html> - see *Configuration Settings and Precedence*. In order, it will check for the presence of environment variables, a credentials file, and IAM role credentials (which are only valid on EC2).

You can also pass credentials as a named argument to any service method:

```cfc
aws = new aws();
awsCredentials = {awsKey: 'ANOTHER_PUBLIC_KEY', awsSecretKey: 'ANOTHER_PRIVATE_KEY'};
response = aws.s3.listBucket(awsCredentials = awsCredentials, region = 'us-west-1', bucket = 'mybucket');
```

### DynamoDB

DynamoDB data is typed. The types supported are `Number`, `String`, `Binary`, `Boolean`, `Null`, `String Set`, `Number Set`, `Binary Set`, `List` and `Map`.
http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DataModel.html#DataModel.DataTypes

This library's DynamoDB implementation is set up to work with CFML types by default, so that you can supply data in a struct containing string, number, boolean, binary, null, array and struct values. Structs and arrays can be nested. Everything is then type encoded automatically.

_Note:_ This has worked really well for me on Lucee, however, it might not work as well with ColdFusion due to its less accurate variable typing. In both cases, keep in mind that data will typed as a `Number` if an `isNumeric()` check returns true, which it may well do in situations you do not expect. In addition, when using ColdFusion the `serializeJSON()` function seems to want to encode anything that can be cast as a number to a number in the JSON string, so the JSON string has to be edited by `dynamodb.cfc` before posting it to DynamoDB. It seems to work in my (limited) testing, but it is quite possible I have missed some of the encoding mistakes, which would lead to DynamoDB returning errors for invalidly encoded JSON strings.

Similarly when you retrieve data from a DynamoDB table, it will be automatically decoded for you, so that you get back a struct of data for each row.

Here is an example:

```cfc
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
```

If you do not want your data to be type encoded automatically you have two options. The first is to pass the argument `typeDefinitions = typeDefStruct` into a method where `typeDefStruct` is a struct whose keys match keys in your item, and whose values are the types of the key values in your item. Where a key match is found, `dynamodb.cfc` will use the specified type for encoding rather than attempting to determine the type.

 The other option is to pass `dataTypeEncoding = false` to any method, and data will be not be encoded at all. (Thus you will need to encode items yourself.)

 _Note:_ If you want to use non-native CFML types such as the various set types, you will need to use one of these latter two options when putting items.

### Polly

The following operations have been implemented: DescribeVoices, SynthesizeSpeech.

You can configure the default language and default engine by using a `constructorArgs` struct in your module settings (or by passing this struct in at init if you are using this as a standalone library):

```cfc
{
    translate: {
        defaultLanguageCode: 'es-ES',
        defaultEngine: 'neural'
    }
}
```

Example of synthesizing text using "Kendra" voice for default language (en-US).

```cfc
response = aws.polly.synthesizeSpeech( 'Hello World', 'Kendra' );
// The stream data is in: response.rawData
```

### Rekognition

The following basic image processing operations have been implemented: DetectText, DetectFaces, RecognizeCelebrities, DetectLabels, DetectModerationLabels.

Here is an example for detecting unsafe content in an image:

```cfc
imageBinary = fileReadBinary(expandPath('/path/to/image.jpg'));
imageBase64 = binaryEncode(imageBinary, 'base64');

response = aws.rekognition.detectModerationLabels({'Bytes': imageBase64});
moderationlabels = response.data.ModerationLabels;
// moderationlabels is an array of moderation label structs
// see https://docs.aws.amazon.com/rekognition/latest/dg/moderation.html
```

### S3

Most basic operations are supported for S3. However, there is currently no support for updating bucket settings. Support for encrypted buckets and objects is also missing.

TODO: provide an example for using the `getFormPostParams()` method.

### Secrets Manager

Only the GetSecretValue operation has been implemented. Here's an example of using it:

```cfc
response = aws.secretsmanager.getSecretValue( 'YourSecretId' );
secretValue = response.data.SecretString;
```

### SSM

Only the getParameter and getParameters operations have been implemented. Here's an example of using it:

```cfc
response = aws.ssm.getParameter( 'YourParameterName', true );
decryptedValue = response.data.Parameter.Value;
```

### Translate

You can configure the default source and target languages by using a `constructorArgs` struct in your module settings (or by passing this struct in at init if you are using this as a standalone library):

```cfc
{
    translate: {
        defaultSourceLanguageCode: 'es',
        defaultTargetLanguageCode: 'en'
    }
}
```

Also you can override in the translate call:

```cfc
response = aws.translate.translateText( Text = 'house', SourceLanguageCode = 'en', TargetLanguageCode = 'de' );
// The translated text is in: response.data.TranslatedText;
```

You can see the supported language codes by the service in the api docs: <https://docs.aws.amazon.com/en_en/translate/latest/dg/API_TranslateText.html>
