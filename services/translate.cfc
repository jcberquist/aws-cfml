component {

  variables.service = 'translate';

  public any function init(
      required any api,
      required struct settings
  ) {
      variables.api = arguments.api;
      return this;
  }

  public any function translate(required string text, string sourceLang='es', string targetLang='en' ){
    var payload = {};
    payload[ 'SourceLanguageCode' ] = sourceLang;
    payload[ 'TargetLanguageCode'] = targetLang;
    payload[ 'Text' ] = text;

    var apiResponse = apiCall( payload = serializeJSON(payload) );
    if ( apiResponse.statusCode == 200 ) {
      apiResponse[ 'data' ] = deserializeJSON(apiResponse.rawData).TranslatedText;
    }
    return apiResponse;
  }

  public string function getHost(
      required string region
  ) {
      return variables.service & '.' & region & '.amazonaws.com';
  }

  private any function apiCall(
      string httpMethod = 'POST',
      string path = '/',
      struct queryParams = { },
      struct headers = { },
      any payload = ''
  ) {
    var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
    var host = getHost( requestSettings.region );

    headers[ 'X-Amz-Target' ] = 'AWSShineFrontendService_20170701.TranslateText';
    headers[ 'Content-Type' ] = 'application/x-amz-json-1.1';

    return api.call(
        variables.service,
        host,
        requestSettings.region,
        httpMethod,
        path,
        queryParams,
        headers,
        payload,
        requestSettings.awsCredentials
    );
  }

}
