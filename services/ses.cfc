component {

    variables.service = 'ses';
    variables.endpoint = 'email';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.utils = variables.api.getUtils();
        variables.apiVersion = arguments.settings.apiVersion;
        return this;
    }


    /**
    * Sends a email via Amazon SES
    * https://docs.aws.amazon.com/ses/latest/APIReference-V2/API_SendEmail.html
    * @Content An object that contains the body of the message. You can send either a Simple message Raw message or a template Message.
    * @ConfigurationSetName The name of the configuration set to use when sending the email.
    * @Destination An object that contains the recipients of the email message.
    * @EmailTags A list of tags, in the form of name/value pairs, to apply to an email that you send using the SendEmail operation. Tags correspond to characteristics of the email that you define, so that you can publish email sending events.
    * @FeedbackForwardingEmailAddress The address that you want bounce and complaint notifications to be sent to.
    * @FeedbackForwardingEmailAddressIdentityArn This parameter is used only for sending authorization. It is the ARN of the identity that is associated with the sending authorization policy that permits you to use the email address specified in the FeedbackForwardingEmailAddress parameter.
    * @FromEmailAddress The email address to use as the "From" address for the email. The address that you specify has to be verified.
    * @FromEmailAddressIdentityArn This parameter is used only for sending authorization. It is the ARN of the identity that is associated with the sending authorization policy that permits you to use the email address specified in the FromEmailAddress parameter.
    * @ListManagementOptions An object used to specify a list or topic to which an email belongs, which will be used when a contact chooses to unsubscribe.
    * @ReplyToAddresses The "Reply-to" email addresses for the message. When the recipient replies to the message, each Reply-to address receives the reply.
    */
    public any function sendEmail(
        required struct Content,
        string ConfigurationSetName,
        struct Destination,
        array EmailTags,
        string FeedbackForwardingEmailAddress,
        string FeedbackForwardingEmailAddressIdentityArn,
        string FromEmailAddress,
        string FromEmailAddressIdentityArn,
        struct ListManagementOptions,
        array ReplyToAddresses
    ) {
        var formParams = { };
        for (
            var key in [
                'Content',
                'ConfigurationSetName',
                'Destination',
                'EmailTags',
                'FeedbackForwardingEmailAddress',
                'FeedbackForwardingEmailAddressIdentityArn',
                'FromEmailAddress',
                'FromEmailAddressIdentityArn',
                'ListManagementOptions',
                'ReplyToAddresses'
            ]
        ) {
            if ( arguments.keyExists( key ) ) {
                formParams[ key ] = arguments[ key ];
            }
        }

        var requestSettings = api.resolveRequestSettings();
        var apiResponse = apiCall(
            requestSettings,
            'POST',
            '/v2/email/outbound-emails',
            { },
            { },
            serializeJSON( formParams )
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );
        }
        return apiResponse;
    }


    // private

    private string function getHost(
        required string region
    ) {
        return variables.endpoint & '.' & region & '.amazonaws.com';
    }

    private any function apiCall(
        required struct requestSettings,
        string httpMethod = 'GET',
        string path = '/',
        struct queryParams = { },
        struct headers = { },
        string payload = ''
    ) {
        var host = getHost( requestSettings.region );
        if ( !structKeyExists( headers, 'Content-Type' ) ) {
            headers[ 'Content-Type' ] = 'application/json';
        }
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
