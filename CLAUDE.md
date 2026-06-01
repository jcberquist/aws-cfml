# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

**aws-cfml** is a CFML library (v1.36.1) for interacting with AWS APIs. It supports Lucee 4.5+ and ColdFusion 11+, and can be used standalone or as a ColdBox module. It implements AWS Signature v4 for all authentication.

## Commands

This is a CFML library with no build step. Development requires a running CFML server (Lucee or ColdFusion).

**Install dependencies (CommandBox):**
```
box install
```

**Run tests via HTTP** (requires a running CFML server with the repo as web root):
```
http://localhost/tests/runner.cfm
```

**Run a specific test bundle:**
```
http://localhost/tests/runner.cfm?bundles=tests.specs.dynamodb
```

Tests use [TestBox](https://testbox.ortusbooks.com/). The test framework is installed to `testbox/` via `box install`.

## Architecture

### Request flow

```
aws.cfc  →  services/<service>.cfc  →  com/api.cfc  →  com/signature_v4.cfc
                                                     →  com/credentials.cfc
                                                     →  com/httpLucee.cfc | com/httpColdFusion.cfc
```

**[aws.cfc](aws.cfc)** — entry point. Instantiates `com/api.cfc` and all service components. Each service is exposed as a property (`aws.s3`, `aws.dynamodb`, etc.). `constructorArgs` in this file defines per-service defaults (apiVersion, endpoints, language codes).

**[com/api.cfc](com/api.cfc)** — core HTTP orchestrator. `call()` signs and dispatches every request; `signedUrl()` generates pre-signed URLs; `resolveRequestSettings()` normalizes per-call credential/region overrides. Detects Lucee vs ColdFusion at init to select the correct HTTP adapter.

**[com/credentials.cfc](com/credentials.cfc)** — credential resolution chain (mirrors AWS CLI precedence): explicit init args → env vars (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`) → `~/.aws/credentials` → `~/.aws/config` (including SSO and `credential_process`) → ECS container metadata → EC2 IAM role. Temporary credentials (SSO, IAM role, ECS) are cached and refreshed on expiry.

**[com/signature_v4.cfc](com/signature_v4.cfc)** — AWS Signature Version 4 implementation. Produces `Authorization` header (via `getHeadersWithAuthorization`) or pre-signed query params (via `getQueryParamsWithAuthorization`).

**[com/httpLucee.cfc](com/httpLucee.cfc) / [com/httpColdFusion.cfc](com/httpColdFusion.cfc)** — thin HTTP adapters with identical interfaces. Selected at runtime based on `server.keyExists('lucee')`.

**[com/utils.cfc](com/utils.cfc)** — shared helpers: XML parsing, URL encoding, query string serialization, header normalization, ISO 8601 timestamps.

### Service components

All services in `services/` follow the same pattern:
- Receive `api` (com/api.cfc instance) and a `settings` struct at init
- Call `api.resolveRequestSettings()` at the start of each method to normalize credentials/region
- Delegate to a private `apiCall()` method that wraps `api.call()`

**DynamoDB** (`services/dynamodb.cfc`) is the most complex service — it handles automatic type encoding/decoding between CFML native types and DynamoDB's typed JSON format (`{S: "val"}`, `{N: "1"}`, etc.). Pass `dataTypeEncoding=false` to skip auto-encoding, or `typeDefinitions={key: 'S'}` to override specific key types.

**S3** (`services/s3.cfc`) uses XML responses (not JSON), constructs bucket-specific hostnames, and supports both path-style and virtual-hosted-style requests.

**CloudSearch Domain** (`services/cloudsearch.cfc`) uses per-domain endpoints (different hostnames for search vs. document operations). Pass full endpoint hostnames via `constructorArgs` at init: `searchEndpoint` (e.g. `search-{domain}.{region}.cloudsearch.amazonaws.com`) and `docEndpoint` (e.g. `doc-{domain}.{region}.cloudsearch.amazonaws.com`). SigV4 service name is `cloudsearch`. Methods: `search()` (GET `/2013-01-01/search`) and `uploadDocuments()` (POST `/2013-01-01/documents/batch`).

### ColdBox module

[ModuleConfig.cfc](ModuleConfig.cfc) registers `aws@awscfml` as a singleton WireBox mapping. Module settings in `config/Coldbox.cfc` map to `aws.cfc` init arguments.

### Response format

Every method returns a consistent struct:
```cfml
{
    responseHeaders: {},   // HTTP response headers
    responseTime: 123,     // milliseconds
    statusCode: 200,
    rawData: '',           // raw HTTP body
    data: {}               // parsed body (XML→struct or JSON→struct); absent for binary responses
}
```

## Adding a new service

1. Create `services/<serviceName>.cfc` following the pattern of an existing simple service (e.g. `services/ssm.cfc`).
2. Add the service name to `variables.services` in [aws.cfc](aws.cfc).
3. Add default `constructorArgs` for the service in [aws.cfc](aws.cfc) if needed.
