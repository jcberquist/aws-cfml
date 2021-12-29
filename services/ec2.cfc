component {

    variables.service = 'ec2';

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
    * Describes the specified instances or all instances.
    * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeInstances.html
    * @InstanceIds The IDs of the instances one wishes to describe
    * @DryRun Checks whether you have the required permissions for the action, without actually making the request, and provides an error response. If you have the required permissions, the error response is DryRunOperation. Otherwise, it is UnauthorizedOperation.
    */
    public any function DescribeInstances(
        required array InstanceIds = [ ],
        boolean DryRun = false
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'Action': 'DescribeInstances' };

        queryParams[ 'DryRun' ] = arguments.DryRun;

        if ( len( arguments.InstanceIds ) ) {
            InstanceIds.each( ( e, i ) => {
                queryParams[ 'InstanceId.#i#' ] = e;
            } )
        }
        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/',
            queryParams
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Starts an Amazon EBS-backed instance that you've previously stopped.
    * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_StartInstances.html
    * @InstanceIds The IDs of the instances one wishes to start
    * @DryRun Checks whether you have the required permissions for the action, without actually making the request, and provides an error response. If you have the required permissions, the error response is DryRunOperation. Otherwise, it is UnauthorizedOperation.
    */
    public any function StartInstances(
        required array InstanceIds = [ ],
        boolean DryRun = false
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'Action': 'StartInstances' };

        queryParams[ 'DryRun' ] = arguments.DryRun;

        if ( len( arguments.InstanceIds ) ) {
            InstanceIds.each( ( e, i ) => {
                queryParams[ 'InstanceId.#i#' ] = e;
            } )
        }
        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/',
            queryParams
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Requests a reboot of the specified instances. This operation is asynchronous; it only queues a request to reboot the specified instances. The operation succeeds if the instances are valid and belong to you. Requests to reboot terminated instances are ignored.
    * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_RebootInstances.html
    * @InstanceIds The IDs of the instances one wishes to reboot
    * @DryRun Checks whether you have the required permissions for the action, without actually making the request, and provides an error response. If you have the required permissions, the error response is DryRunOperation. Otherwise, it is UnauthorizedOperation.
    */
    public any function RebootInstances(
        required array InstanceIds = [ ],
        boolean DryRun = false
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'Action': 'RebootInstances' };

        queryParams[ 'DryRun' ] = arguments.DryRun;

        if ( len( arguments.InstanceIds ) ) {
            InstanceIds.each( ( e, i ) => {
                queryParams[ 'InstanceId.#i#' ] = e;
            } )
        }
        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/',
            queryParams
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Stops a running Amazon EBS-backed instance.
    * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_StopInstances.html
    * @InstanceIds The ID of the instances one wishes to stop
    * @DryRun Checks whether you have the required permissions for the action, without actually making the request, and provides an error response. If you have the required permissions, the error response is DryRunOperation. Otherwise, it is UnauthorizedOperation.
    * @Force Forces the instances to stop. The instances do not have an opportunity to flush file system caches or file system metadata. If you use this option, you must perform file system check and repair procedures. This option is not recommended for Windows instances.
    * @Hibernate Hibernates the instance if the instance was enabled for hibernation at launch. If the instance cannot hibernate successfully, a normal shutdown occurs.
    */
    public any function StopInstances(
        required array InstanceIds = [ ],
        boolean Hibernate = false,
        boolean DryRun = false,
        boolean Force = false
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'Action': 'StopInstances' };

        queryParams[ 'DryRun' ] = arguments.DryRun;
        queryParams[ 'Hibernate' ] = arguments.Hibernate;
        queryParams[ 'Force' ] = arguments.Force;

        if ( len( arguments.InstanceIds ) ) {
            InstanceIds.each( ( e, i ) => {
                queryParams[ 'InstanceId.#i#' ] = e;
            } )
        }
        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/',
            queryParams
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    /**
    * Starts an Amazon EBS-backed instance that you've previously stopped.
    * https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_ModifyInstanceAttribute.html
    * @InstanceIds The IDs of the instances one wishes to start
    * @DryRun Checks whether you have the required permissions for the action, without actually making the request, and provides an error response. If you have the required permissions, the error response is DryRunOperation. Otherwise, it is UnauthorizedOperation.
    * @Attribute The name of the attribute. Valid Values: instanceType | kernel | ramdisk | userData | disableApiTermination | instanceInitiatedShutdownBehavior | rootDeviceName | blockDeviceMapping | productCodes | sourceDestCheck | groupSet | ebsOptimized | sriovNetSupport | enaSupport | enclaveOptions
    * @Value A new value for the attribute. Use only with the kernel, ramdisk, userData, disableApiTermination, or instanceInitiatedShutdownBehavior attribute.
    * @InstanceType Changes the instance type to the specified value.If the instance type is not valid, the error returned is InvalidInstanceAttributeValue.  For more information, see Instance types in the Amazon EC2 User Guide. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html
    *
    *   Type          CPU   RAM
    *   c5.large      2     4
    *   c5.xlarge     4     8
    *   c5.2xlarge    8     16
    *   c5.4xlarge    16    32
    *   c5.9xlarge    36    72
    *   c5.12xlarge   48    96
    *   c5.18xlarge   72    144
    *   c5.24xlarge   96    192
    */
    public any function ModifyInstanceAttribute(
        required array InstanceIds = [ ],
        string InstanceType = '',
        string Attribute = '',
        string Value = '',
        boolean DryRun = false
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'Action': 'StartInstances' };

        queryParams[ 'DryRun' ] = arguments.DryRun;

        if ( len( arguments.Attribute ) ) queryParams[ 'Attribute' ] = arguments.Attribute;
        if ( len( arguments.Value ) ) queryParams[ 'Value' ] = arguments.Value;
        if ( len( arguments.InstanceType ) ) queryParams[ 'InstanceType.Value' ] = arguments.InstanceType;

        if ( len( arguments.InstanceIds ) ) {
            InstanceIds.each( ( e, i ) => {
                queryParams[ 'InstanceId.#i#' ] = e;
            } )
        }

        var apiResponse = apiCall(
            requestSettings,
            'GET',
            '/',
            queryParams
        );
        if ( apiResponse.statusCode == 200 ) {
            apiResponse[ 'data' ] = utils.parseXmlDocument( apiResponse.rawData );
        }
        return apiResponse;
    }

    // private

    private string function getHost(
        required string region
    ) {
        return variables.service & '.' & region & '.amazonaws.com';
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

        if ( isStruct( payload ) ) {
            structAppend( payload, { 'Version': variables.apiVersion }, false );
            structAppend( headers, { 'Content-Type': 'application/x-www-form-urlencoded' }, false );
            payload = utils.parseQueryParams( payload );
        } else {
            structAppend( queryParams, { 'Version': variables.apiVersion }, false );
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
