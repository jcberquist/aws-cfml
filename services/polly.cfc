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

        variables.emptyStringHash = hash( '', 'SHA-256' ).lcase();

        return this;
    }

	/**
	 * Get list of available voices for the given language.
	 *
	 * @link https://docs.aws.amazon.com/polly/latest/dg/API_DescribeVoices.html
	 */
	public any function describeVoices(
		string Engine = variables.defaultEngine,
		string NextToken = "",
		boolean IncludeAdditionalLanguageCodes = false,
		string LanguageCode = variables.defaultLanguageCode
	) {
		var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
		var queryParams = {
			'Engine': Engine,
			'IncludeAdditionalLanguageCodes': IncludeAdditionalLanguageCodes,
			'LanguageCode': LanguageCode
		};

		if (Len(NextToken)) {
			queryParams['NextToken'] = NextToken;
		}

		var apiResponse = apiCall(
			requestSettings,
			'GET',
			'/v1/voices',
			queryParams
		);

		return deserializeJSON(apiResponse.rawData);
	}

	/**
	 * Synthesize text to stream of bytes.
	 *
	 * @link https://docs.aws.amazon.com/polly/latest/dg/API_SynthesizeSpeech.html
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

		if (Len(SampleRate)) {
			payload['SampleRate'] = SampleRate;
		}

		if (Len(TextType)) {
			payload['TextType'] = TextType;
		}

		if (!ArrayIsEmpty(LexiconNames)) {
			payload['LexiconNames'] = LexiconNames;
		}

		if (!ArrayIsEmpty(SpeechMarkTypes)) {
			payload['SpeechMarkTypes'] = SpeechMarkTypes;
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
        any payload = ''
    ) {
        var host = getHost( requestSettings.region );
		var payloadString = payload;

		if (!IsSimpleValue(payloadString)) {
			payloadString = serializeJSON(payloadString);
		}

        if ( len( payloadString ) ) {
			headers[ 'X-Amz-Content-Sha256' ] = hash( payloadString, 'SHA-256' ).lcase();
        } else {
            headers[ 'X-Amz-Content-Sha256' ] = variables.emptyStringHash;
        }

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
