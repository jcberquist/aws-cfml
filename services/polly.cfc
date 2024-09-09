component {

    variables.service = 'polly';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.apiVersion = arguments.settings.apiVersion;
        variables.defaultLanguageCode = arguments.settings.defaultLanguageCode;
        variables.defaultEngine = arguments.settings.defaultEngine;

        return this;
    }

    /**
    * Returns the list of voices that are available for use when requesting speech synthesis
    * https://docs.aws.amazon.com/polly/latest/dg/API_DescribeVoices.html
    * @Engine Specifies the engine (standard or neural) used by Amazon Polly when processing input text for speech synthesis
    * @NextToken An opaque pagination token returned from the previous DescribeVoices operation
    * @IncludeAdditionalLanguageCodes Specifies the engine (standard or neural) used by Amazon Polly when processing input text for speech synthesis
    * @LanguageCode The language identification tag (ISO 639 code for the language name-ISO 3166 country code) for filtering the list of voices returned
    */
    public any function describeVoices(
        string Engine = variables.defaultEngine,
        string NextToken = '',
        boolean IncludeAdditionalLanguageCodes = false,
        string LanguageCode = variables.defaultLanguageCode
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = {
            'Engine': Engine,
            'IncludeAdditionalLanguageCodes': IncludeAdditionalLanguageCodes,
            'LanguageCode': LanguageCode
        };

        if ( len( NextToken ) ) {
            queryParams[ 'NextToken' ] = NextToken;
        }

        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/v1/voices',
            queryParams
        );

        apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );

        return apiResponse;
    }

    /**
    * Synthesizes UTF-8 input, plain text or SSML, to a stream of bytes.
    * https://docs.aws.amazon.com/polly/latest/dg/API_SynthesizeSpeech.html
    * @Text Input text to synthesize
    * @VoiceId Voice ID to use for the synthesis
    * @OutputFormat The format in which the returned output will be encoded
    * @Engine Specifies the engine (standard or neural) for Amazon Polly to use when processing input text for speech synthesis
    * @LanguageCode Optional language code for the Synthesize Speech request
    * @SampleRate The audio frequency specified in Hz
    * @TexType Specifies whether the input text is plain text or SSM
    * @LexiconNames List of one or more pronunciation lexicon names you want the service to apply during synthesis
    * @SpeechMarkTypes The type of speech marks returned for the input text
    */
    public any function synthesizeSpeech(
        required string Text,
        required string VoiceId,
        string OutputFormat = 'mp3',
        string Engine = variables.defaultEngine,
        string LanguageCode = variables.defaultLanguageCode,
        string SampleRate = '',
        string TextType = '',
        array LexiconNames = [ ],
        array SpeechMarkTypes = [ ]
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = {
            'Text': Text,
            'VoiceId': VoiceId,
            'Engine': Engine,
            'LanguageCode': Languagecode,
            'OutputFormat': OutputFormat
        };

        if ( len( SampleRate ) ) {
            payload[ 'SampleRate' ] = SampleRate;
        }

        if ( len( TextType ) ) {
            payload[ 'TextType' ] = TextType;
        }

        if ( !arrayIsEmpty( LexiconNames ) ) {
            payload[ 'LexiconNames' ] = LexiconNames;
        }

        if ( !arrayIsEmpty( SpeechMarkTypes ) ) {
            payload[ 'SpeechMarkTypes' ] = SpeechMarkTypes;
        }

        var apiResponse = apiCall(
            requestSettings,
            'POST',
            '/v1/speech',
            { },
            { },
            payload
        );

        return apiResponse;
    }


    // private

    private string function getHost(
        required string region
    ) {
        return variables.service & '.' & arguments.region & '.amazonaws.com';
    }

    private any function apiCall(
        required struct requestSettings,
        string httpMethod = 'GET',
        string path = '/',
        struct queryParams = { },
        struct headers = { },
        struct payload = { }
    ) {
        var host = getHost( requestSettings.region );
        var payloadString = payload.isEmpty() ? '' : serializeJSON( payload );

        if ( !payload.isEmpty() ) headers[ 'Content-Type' ] = 'application/json';

        return api.call(
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
    }

}
