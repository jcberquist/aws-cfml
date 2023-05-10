component {

    variables.service = 'connect';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.utils = variables.api.getUtils();
        variables.settings = arguments.settings;
        return this;
    }

    /**
    * Return a list of instances which are in active state, creation-in-progress state, and failed state.
    * Instances that aren't successfully created (they are in a failed state) are returned only for 24 hours
    * after the CreateInstance API was invoked.
    * https://docs.aws.amazon.com/connect/latest/APIReference/API_ListInstances.html
    *
    * @maxResults The maximum number of results to return per page. Valid Range: Minimum value of 1. Maximum value of 10.
    * @nextToken  The token for the next set of results. Use the value returned in the previous response in the next request to retrieve the next set of results.
    *
    * @preview
    */
    public any function listInstances(
        maxResults = 10,
        nextToken
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'maxResults': arguments.maxResults };
        if ( !isNull( arguments.nextToken ) ) {
            queryParams[ 'nextToken' ] = arguments.maxResults;
        }
        var apiResponse = apiCall(
            requestSettings = requestSettings,
            httpMethod = 'GET',
            path = '/instance',
            queryParams = queryParams
        );
        return apiResponse;
    }

    /**
    * Describes the specified contact.
    * Contact information remains available in Amazon Connect for 24 months, and then it is deleted.
    * Only data from November 12, 2021, and later is returned by this API.
    * https://docs.aws.amazon.com/connect/latest/APIReference/API_DescribeContact.html
    *
    * @instanceId The identifier of the Amazon Connect instance. You can find the instance ID in the Amazon Resource Name (ARN) of the instance.
    * @contactId  The identifier of the contact.
    *
    * @preview
    */
    public any function describeContact(
        required string instanceId,
        required string contactId
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var apiResponse = apiCall(
            requestSettings = requestSettings,
            httpMethod = 'GET',
            path = '/contacts/#arguments.instanceId#/#arguments.contactId#'
        );
        return apiResponse;
    }

    /**
    * Assigns the specified routing profile to the specified user.
    * https://docs.aws.amazon.com/connect/latest/APIReference/API_UpdateUserRoutingProfile.html
    *
    * @instanceId       The identifier of the Amazon Connect instance. You can find the instance ID in the Amazon Resource Name (ARN) of the instance.
    * @userId           The identifier of the user account.
    * @routingProfileId The identifier of the routing profile for the user.
    */
    public any function updateUserRoutingProfile(
        required string instanceId,
        required string userId,
        required string routingProfileId
    ) {
        return apiCall(
            requestSettings = api.resolveRequestSettings( argumentCollection = arguments ),
            httpMethod = 'POST',
            path = '/users/#arguments.instanceId#/#arguments.userId#/routing-profile',
            payload = serializeJSON( { 'RoutingProfileId': arguments.routingProfileId } )
        );
    }

    /**
    * Places an outbound call to a contact, and then initiates the flow.
    * It performs the actions in the flow that's specified (in ContactFlowId).
    * Agents do not initiate the outbound API, which means that they do not dial the contact.
    * If the flow places an outbound call to a contact, and then puts the contact in queue, the call is then routed to the agent, like any other inbound case.
    * There is a 60-second dialing timeout for this operation. If the call is not connected after 60 seconds, it fails.
    * https://docs.aws.amazon.com/connect/latest/APIReference/API_StartOutboundVoiceContact.html
    *
    * @instanceId                              The identifier of the Amazon Connect instance. You can find the instance ID in the Amazon Resource Name (ARN) of the instance.
    * @contactFlowId                           The identifier of the flow for the outbound call.
    *                                          To see the ContactFlowId in the Amazon Connect console user interface, on the navigation menu go to Routing, Contact Flows.
    *                                          Choose the flow. On the flow page, under the name of the flow, choose Show additional flow information.
    *                                          The ContactFlowId is the last part of the ARN.
    * @destinationPhoneNumber                  The phone number of the customer, in E.164 format.
    * @campaignId                   (Optional) The campaign identifier of the outbound communication.
    * @awaitAnswerMachinePrompt     (Optional) Flag to wait for the answering machine prompt.
    * @enableAnswerMachineDetection (Optional) The flag to indicate if answer machine detection analysis needs to be performed for a voice call.
    *                                          If set to true, TrafficType must be set as CAMPAIGN.
    * @queueId                      (Optional) The queue for the call. If you specify a queue, the phone displayed for caller ID is the phone number specified in the queue.
    *                                          If you do not specify a queue, the queue defined in the flow is used.
    *                                          If you do not specify a queue, you must specify a source phone number.
    * @sourcePhoneNumber            (Optional) The phone number associated with the Amazon Connect instance, in E.164 format.
    *                                          If you do not specify a source phone number, you must specify a queue.
    * @clientToken                  (Optional) A unique, case-sensitive identifier that you provide to ensure the idempotency of the request.
    *                                          If not provided, the AWS SDK populates this field.
    * @attributes                   (Optional) A custom key-value pair using a struct. The attributes are standard Amazon Connect attributes,
    *                                          and can be accessed in flows just like any other contact attributes.
    *                                          There can be up to 32,768 UTF-8 bytes across all key-value pairs per contact.
    *                                          Attribute keys can include only alphanumeric, dash, and underscore characters.
    */
    public any function startOutboundVoiceContact(
        required string instanceId,
        required string contactFlowId,
        required string destinationPhoneNumber,
        string campaignId,
        boolean awaitAnswerMachinePrompt,
        boolean enableAnswerMachineDetection,
        string queueId,
        string sourcePhoneNumber,
        string clientToken,
        struct attributes = { }
    ) {
        if ( isNull( arguments.queueId ) && isNull( arguments.sourcePhoneNumber ) ) {
            throw( 'Either a queueId or a sourcePhoneNumber must be provided' );
        }

        // Denotes the class of traffic. Calls with different traffic types are handled differently by Amazon Connect.
        // The default value is GENERAL. Use CAMPAIGN if `EnableAnswerMachineDetection` is set to true. For all other cases, use GENERAL.
        var trafficType = 'GENERAL';
        if ( !isNull( arguments.enableAnswerMachineDetection ) && arguments.enableAnswerMachineDetection ) {
            trafficType = 'CAMPAIGN';
        }

        var payload = {
            'InstanceId': arguments.instanceId,
            'ContactFlowId': arguments.contactFlowId,
            'Attributes': arguments.attributes,
            'DestinationPhoneNumber': arguments.destinationPhoneNumber,
            'TrafficType': trafficType
        };

        // Optional Keys
        if ( !isNull( arguments.campaignId ) ) {
            payload[ 'CampaignId' ] = arguments.campaignId;
        }
        if ( !isNull( arguments.queueId ) ) {
            payload[ 'QueueId' ] = arguments.queueId;
        }
        if ( !isNull( arguments.sourcePhoneNumber ) ) {
            payload[ 'SourcePhoneNumber' ] = arguments.sourcePhoneNumber;
        }
        if ( !isNull( arguments.clientToken ) ) {
            payload[ 'ClientToken' ] = arguments.clientToken;
        }

        if ( !isNull( arguments.awaitAnswerMachinePrompt ) || !isNull( arguments.enableAnswerMachineDetection ) ) {
            payload[ 'AnswerMachineDetectionConfig' ] = { };
            if ( !isNull( arguments.awaitAnswerMachinePrompt ) ) {
                payload[ 'AnswerMachineDetectionConfig' ][ 'AwaitAnswerMachinePrompt' ] = arguments.awaitAnswerMachinePrompt;
            }
            if ( !isNull( arguments.enableAnswerMachineDetection ) ) {
                payload[ 'AnswerMachineDetectionConfig' ][ 'EnableAnswerMachineDetection' ] = arguments.enableAnswerMachineDetection;
            }
        }

        return apiCall(
            requestSettings = api.resolveRequestSettings( argumentCollection = arguments ),
            httpMethod = 'PUT',
            path = '/contact/outbound-voice',
            payload = serializeJSON( payload )
        );
    }

    /**
    * Creates a user account for the specified Amazon Connect instance.
    *
    * @instanceId                The identifier of the Amazon Connect instance. You can find the instance ID in the Amazon Resource Name (ARN) of the instance.
    * @routingProfileId          The identifier of the routing profile for the user.
    * @securityProfileIds        The identifier of the security profile for the user.
    * @username                  The user name for the account. For instances not using SAML for identity management, the user name can include up to 20 characters.
    *                            If you are using SAML for identity management, the user name can include up to 64 characters from [a-zA-Z0-9_-.\@]+.
    * @phoneType                 The phone type. Valid values are: `SOFT_PHONE` and `DESK_PHONE`
    * @password                  (Optional) The password for the user account. A password is required if you are using Amazon Connect for identity management.
    *                            Otherwise, it is an error to include a password.
    * @afterContactWorkTimeLimit (Optional) The After Call Work (ACW) timeout setting, in seconds.
    * @autoAccept                (Optional) The Auto accept setting.
    * @deskPhoneNumber           (Optional) The phone number for the user's desk phone.
    * @directoryUserId           (Optional) The identifier of the user account in the directory used for identity management. If Amazon Connect cannot access the directory, you can specify this identifier to authenticate users.
    *                            If you include the identifier, we assume that Amazon Connect cannot access the directory. Otherwise, the identity information is used to authenticate users from your directory.
    *                            This parameter is required if you are using an existing directory for identity management in Amazon Connect when Amazon Connect cannot access your directory to authenticate users.
    *                            If you are using SAML for identity management and include this parameter, an error is returned.
    * @hierarchyGroupId          (Optional) The identifier of the hierarchy group for the user.
    * @firstName                 (Optional) The first name. This is required if you are using Amazon Connect or SAML for identity management.
    * @lastName                  (Optional) The last name. This is required if you are using Amazon Connect or SAML for identity management.
    * @mobileNumber              (Optional) The user's mobile number.
    * @email                     (Optional) The email address. If you are using SAML for identity management and include this parameter, an error is returned.
    * @secondaryEmail            (Optional) The user's secondary email address. If you provide a secondary email, the user receives email notifications - other than password reset notifications - to this email address instead of to their primary email address.
    * @tags                      (Optional) The tags used to organize, track, or control access for this resource. For example, { "tags": {"key1":"value1", "key2":"value2"} }.
    */
    public any function createUser(
        required string instanceId,
        required string routingProfileId,
        required array securityProfileIds,
        required string username,
        string phoneType = 'SOFT_PHONE',
        string password,
        numeric afterContactWorkTimeLimit,
        boolean autoAccept,
        string deskPhoneNumber,
        string directoryUserId,
        string hierarchyGroupId,
        string firstName,
        string lastName,
        string mobileNumber,
        string email,
        string secondaryEmail,
        struct tags = { }
    ) {
        var payload = {
            'RoutingProfileId': arguments.routingProfileId,
            'SecurityProfileIds': arguments.securityProfileIds,
            'Username': arguments.username,
            'PhoneConfig': { 'PhoneType': arguments.phoneType },
            'Tags': arguments.tags
        };

        if ( !isNull( arguments.password ) ) {
            payload[ 'Password' ] = arguments.password;
        }

        if ( !isNull( arguments.directoryUserId ) ) {
            payload[ 'DirectoryUserId' ] = arguments.directoryUserId;
        }

        if ( !isNull( arguments.hierarchyGroupId ) ) {
            payload[ 'HierarchyGroupId' ] = arguments.hierarchyGroupId;
        }

        if ( !isNull( arguments.afterContactWorkTimeLimit ) ) {
            payload[ 'PhoneConfig' ][ 'AfterContactWorkTimeLimit' ] = arguments.afterContactWorkTimeLimit;
        }

        if ( !isNull( arguments.autoAccept ) ) {
            payload[ 'PhoneConfig' ][ 'AutoAccept' ] = arguments.autoAccept;
        }

        if ( !isNull( arguments.deskPhoneNumber ) ) {
            payload[ 'PhoneConfig' ][ 'DeskPhoneNumber' ] = arguments.deskPhoneNumber;
        }

        if ( !isNull( arguments.firstName ) ) {
            if ( !structKeyExists( payload, 'IdentityInfo' ) ) {
                payload[ 'IdentityInfo' ] = { };
            }
            payload[ 'IdentityInfo' ][ 'FirstName' ] = arguments.firstName;
        }

        if ( !isNull( arguments.lastName ) ) {
            if ( !structKeyExists( payload, 'IdentityInfo' ) ) {
                payload[ 'IdentityInfo' ] = { };
            }
            payload[ 'IdentityInfo' ][ 'LastName' ] = arguments.lastName;
        }

        if ( !isNull( arguments.mobileNumber ) ) {
            if ( !structKeyExists( payload, 'IdentityInfo' ) ) {
                payload[ 'IdentityInfo' ] = { };
            }
            payload[ 'IdentityInfo' ][ 'Mobile' ] = arguments.mobileNumber;
        }

        if ( !isNull( arguments.email ) ) {
            if ( !structKeyExists( payload, 'IdentityInfo' ) ) {
                payload[ 'IdentityInfo' ] = { };
            }
            payload[ 'IdentityInfo' ][ 'Email' ] = arguments.email;
        }

        if ( !isNull( arguments.secondaryEmail ) ) {
            if ( !structKeyExists( payload, 'IdentityInfo' ) ) {
                payload[ 'IdentityInfo' ] = { };
            }
            payload[ 'IdentityInfo' ][ 'SecondaryEmail' ] = arguments.secondaryEmail;
        }

        return apiCall(
            requestSettings = api.resolveRequestSettings( argumentCollection = arguments ),
            httpMethod = 'PUT',
            path = '/users/#arguments.instanceId#',
            payload = serializeJSON( payload )
        );
    }

    /**
    * Changes the current status of a user or agent in Amazon Connect. If the agent is currently handling a contact, this sets the agent's next status.
    * https://docs.aws.amazon.com/connect/latest/APIReference/API_PutUserStatus.html
    *
    * @instanceId     The identifier of the Amazon Connect instance. You can find the instance ID in the Amazon Resource Name (ARN) of the instance.
    * @userId         The identifier of the user account.
    * @agentStatusId  The identifier of the agent status.
    */
    public any function putUserStatus(
        required string instanceId,
        required string userId,
        required string agentStatusId
    ) {
        return apiCall(
            requestSettings = api.resolveRequestSettings( argumentCollection = arguments ),
            httpMethod = 'PUT',
            path = '/users/#arguments.instanceId#/#arguments.userId#/status',
            payload = serializeJSON( { 'AgentStatusId': arguments.agentStatusId } )
        );
    }

    /**
    * Updates the phone configuration settings for the specified user.
    * https://docs.aws.amazon.com/connect/latest/APIReference/API_UpdateUserPhoneConfig.html
    *
    * @instanceId                 The identifier of the Amazon Connect instance. You can find the instance ID in the Amazon Resource Name (ARN) of the instance.
    * @userId                     The identifier of the user account.
    * @phoneType                  The phone type. Valid values are: `SOFT_PHONE` and `DESK_PHONE`
    * @afterContactWorkTimeLimit  The After Call Work (ACW) timeout setting, in seconds. Minimum value of 0.
    * @autoAccept                 The auto accept setting for having the agent auto accept incoming calls routed to them.
    * @deskPhoneNumber            The phone number for the user's desk phone.
    */
    public any function updateUserPhoneConfig(
        required string instanceId,
        required string userId,
        string phoneType = 'SOFT_PHONE',
        numeric afterContactWorkTimeLimit,
        boolean autoAccept,
        string deskPhoneNumber
    ) {
        var phoneConfig = { 'PhoneType': arguments.phoneType };
        if ( !isNull( arguments.afterContactWorkTimeLimit ) ) {
            phoneConfig[ 'AfterContactWorkTimeLimit' ] = arguments.afterContactWorkTimeLimit;
        }
        if ( !isNull( arguments.autoAccept ) ) {
            phoneConfig[ 'AutoAccept' ] = arguments.autoAccept;
        }
        if ( !isNull( arguments.deskPhoneNumber ) ) {
            phoneConfig[ 'DeskPhoneNumber' ] = arguments.deskPhoneNumber;
        }

        return apiCall(
            requestSettings = api.resolveRequestSettings( argumentCollection = arguments ),
            httpMethod = 'POST',
            path = '/users/#arguments.instanceId#/#arguments.userId#/phone-config',
            payload = serializeJSON( { 'PhoneConfig': phoneConfig } )
        );
    }

    private any function apiCall(
        required struct requestSettings,
        string httpMethod = 'GET',
        string path = '/',
        struct queryParams = { },
        struct headers = { },
        any payload = ''
    ) {
        var host = variables.service & '.' & requestSettings.region & '.amazonaws.com';
        if ( !structKeyExists( headers, 'Content-Type' ) ) {
            headers[ 'Content-Type' ] = 'application/json';
        }
        var useSSL = !structKeyExists( variables.settings, 'useSSL' ) || variables.settings.useSSL;
        var apiResponse = api.call(
            variables.service,
            host,
            requestSettings.region,
            httpMethod,
            path,
            queryParams,
            headers,
            payload,
            requestSettings.awsCredentials,
            false,
            useSSL
        );
        apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );
        return apiResponse;
    }

}
