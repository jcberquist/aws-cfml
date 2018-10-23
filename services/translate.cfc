component {

  variables.service = 'translate';

  public any function init(
      required any api,
      required struct settings
  ) {
      variables.api = arguments.api;
      variables.defaultSourceLanguageCode = arguments.settings.defaultSourceLanguageCode;
      variables.defaultTargetLanguageCode = arguments.settings.defaultTargetLanguageCode;
      return this;
  }

  public any function translate(
      required string Text,
      string SourceLanguageCode = defaultSourceLanguageCode,
      string TargetLanguageCode = defaultTargetLanguageCode) {
    var payload = {};
    payload[ 'SourceLanguageCode' ] = SourceLanguageCode;
    payload[ 'TargetLanguageCode'] = TargetLanguageCode;
    payload[ 'Text' ] = text;

    var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
    var apiResponse = apiCall( requestSettings = requestSettings, payload = payload );
    if ( apiResponse.statusCode == 200 ) {
      apiResponse[ 'translatedText' ] = apiResponse[ 'data' ].TranslatedText;
    }
    return apiResponse;
  }

  public string function getHost(
      required string region
  ) {
      return variables.service & '.' & region & '.amazonaws.com';
  }

  private any function apiCall(
      required struct requestSettings,
      string httpMethod = 'POST',
      string path = '/',
      struct queryParams = { },
      struct headers = { },
      any payload = { }
  ) {
    var host = getHost( requestSettings.region );
    var payloadString = serializeJSON( payload );

    headers[ 'X-Amz-Target' ] = 'AWSShineFrontendService_20170701.TranslateText';
    headers[ 'Content-Type' ] = 'application/x-amz-json-1.1';

    var apiResponse = api.call(
        variables.service,
        host,
        requestSettings.region,
        httpMethod,
        path,
        queryParams,
        headers,
        payloadString,
        requestSettings.awsCredentials
    );
    apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );

    return apiResponse;
  }

}
