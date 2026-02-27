# OAuth Flow Test Script

This script tests the proxy OAuth endpoints we implemented for the new frontend integration.

## Purpose
The script simulates the complete OAuth flow using curl requests to test:
1. User login verification via proxy
2. OAuth authorization initiation
3. Token exchange
4. Data retrieval as XML

## Endpoints Tested
- `POST /api/auth/login` - Verify user credentials
- `POST /api/auth/authorize` - Initiate OAuth flow
- `POST /api/auth/token` - Exchange code for token
- `GET /api/auth/data` - Retrieve user data
- Legacy XML endpoints for actual data retrieval

## Usage
1. Make sure the DataCustodian application is running on `http://localhost:8080`
2. Update the configuration variables in the script:
   - `USERNAME` - Test user username
   - `PASSWORD` - Test user password
   - `CLIENT_ID` - OAuth client ID
   - `CLIENT_SECRET` - OAuth client secret
3. Run the script:
   ```bash
   ./test_oauth_flow.sh
   ```

## Output
The script will:
- Test each endpoint in sequence
- Show colored output for success/failure
- Save XML files: `user_authorization.xml` and `user_energy_data.xml`
- Display the XML content for verification

## Notes
- The script uses mock authorization codes for demo purposes
- In production, the authorization code would come from the actual OAuth callback
- The XML files contain the user's energy data that the third party can consume
