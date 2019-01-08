<cfsilent>
<cfscript>
    testbox = new testbox.system.Testbox();
    param name="url.reporter" default="simple";
    param name="url.directory" default="tests.specs";
    args = { reporter: url.reporter, directory: url.directory };
    if ( structKeyExists( url, 'bundles' ) ) args.bundles = url.bundles;
    results = testBox.run( argumentCollection = args );
</cfscript>
</cfsilent>
<cfcontent reset="true">
<cfoutput>#trim( results )#</cfoutput>
