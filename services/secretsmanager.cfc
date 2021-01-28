component {

  variables.service = 'secretsmanager';

  public any function init(
      required any api,
      required struct settings
  ) {
      variables.api = arguments.api;
      variables.apiVersion = arguments.settings.apiVersion;
      return this;
  }
  /**
  * Retrieves the contents of the encrypted fields SecretString or SecretBinary from the specified version of a secret, whichever contains content.
  * https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
  * @SecretId Specifies the secret containing the version that you want to retrieve. You can specify either the Amazon Resource Name (ARN) or the friendly name of the secret.
  */
  public any function getSecretValue(
      required string SecretId
  ) {
      var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
      var payload = {
          'SecretId': arguments.SecretId
      };
      return apiCall( requestSettings, 'GetSecretValue', payload );
  }

  public string function getHost(
      required string region
  ) {
      return variables.service & '.' & region & '.amazonaws.com';
  }

  private any function apiCall(
      required struct requestSettings,
      required string target,
      struct payload = { }
  ) {
      var host = getHost( requestSettings.region );
      var payloadString = serializeJSON( payload );

      var headers = { };
      headers[ 'X-Amz-Target' ] = 'secretsmanager' & '.' & arguments.target;
      headers[ 'Content-Type' ] = 'application/x-amz-json-1.1';

      var apiResponse = api.call(
          variables.service,
          host,
          requestSettings.region,
          'POST',
          '/',
          { },
          headers,
          payloadString,
          requestSettings.awsCredentials
      );
      apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );

      return apiResponse;
  }

}
