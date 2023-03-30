component {

    variables.service = 'autoscaling';

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
    * Sets the size of the specified Auto Scaling group.
    * https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_SetDesiredCapacity.html
    * @AutoScalingGroupName The name of the Auto Scaling group.
    * @DesiredCapacity The desired capacity is the initial capacity of the Auto Scaling group after this operation completes and the capacity it attempts to maintain.
    * @HonorCooldown Indicates whether Amazon EC2 Auto Scaling waits for the cooldown period to complete before initiating a scaling activity to set your Auto Scaling group to its new capacity. By default, Amazon EC2 Auto Scaling does not honor the cooldown period during manual scaling activities.
    */
    public any function SetDesiredCapacity(
        string AutoScalingGroupName = '',
        numeric DesiredCapacity = 1,
        boolean HonorCooldown = false
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'Action': 'SetDesiredCapacity' };

        queryParams[ 'HonorCooldown' ] = arguments.HonorCooldown;
        queryParams[ 'AutoScalingGroupName' ] = arguments.AutoScalingGroupName;
        queryParams[ 'DesiredCapacity' ] = arguments.DesiredCapacity;

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
    * Gets information about the Auto Scaling instances in the account and Region.
    * https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_DescribeAutoScalingInstances.html
    * @InstanceIds The IDs of the instances one wishes to describe
    * @MaxRecords The maximum number of items to return with this call. The default value is 50 and the maximum value is 50.
    * @NextToken The token for the next set of items to return. (You received this token from a previous call.)
    */
    public any function DescribeAutoScalingInstances(
        required array InstanceIds = [ ],
        numeric MaxRecords = 50,
        string NextToken = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'Action': 'DescribeAutoScalingInstances' };

        queryParams[ 'MaxRecords' ] = arguments.MaxRecords;

        if ( len( arguments.NextToken ) ) queryParams[ 'NextToken' ] = arguments.NextToken;

        parseIds( arguments.InstanceIds, queryParams );

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
    * Gets information about the Auto Scaling groups in the account and Region.
    * https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_DescribeAutoScalingGroups.html
    * @InstanceIds The IDs of the instances one wishes to describe
    * @MaxRecords The maximum number of items to return with this call. The default value is 50 and the maximum value is 50.
    * @NextToken The token for the next set of items to return. (You received this token from a previous call.)
    */
    public any function DescribeAutoScalingGroups(
        required array AutoScalingGroupNames = [ ],
        array Filters = [ ], // no support yet
        numeric MaxRecords = 50,
        string NextToken = ''
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var queryParams = { 'Action': 'DescribeAutoScalingGroups' };

        queryParams[ 'MaxRecords' ] = arguments.MaxRecords;

        if ( len( arguments.NextToken ) ) queryParams[ 'NextToken' ] = arguments.NextToken;

        parseIds( arguments.AutoScalingGroupNames, queryParams, AutoScalingGroupNames.member );

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

    private void function parseIds(
        required array IDs = [ ],
        struct queryParams,
        string prefix = 'InstanceID'
    ) {
        if ( len( arguments.IDs ) ) {
            IDs.each( function( e, i ) {
                queryParams[ '#prefix#.#i#' ] = e;
            } );
        }
    }

}
