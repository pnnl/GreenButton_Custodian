/*
 *
 *    Copyright (c) 2018-2021 Green Button Alliance, Inc.
 *
 *    Portions (c) 2013-2018 EnergyOS.org
 *
 *     Licensed under the Apache License, Version 2.0 (the "License");
 *     you may not use this file except in compliance with the License.
 *     You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 *     Unless required by applicable law or agreed to in writing, software
 *     distributed under the License is distributed on an "AS IS" BASIS,
 *     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *     See the License for the specific language governing permissions and
 *     limitations under the License.
 *
 */

package org.greenbuttonalliance.espi.datacustodian.web.api;

import org.greenbuttonalliance.espi.common.service.RetailCustomerService;
import org.greenbuttonalliance.espi.common.service.ApplicationInformationService;
import org.greenbuttonalliance.espi.common.domain.RetailCustomer;
import org.greenbuttonalliance.espi.common.domain.ApplicationInformation;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.web.util.UriComponentsBuilder;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Map;
import java.util.List;
import java.util.LinkedHashMap;

/**
 * REST Controller providing OAuth proxy endpoints for third-party applications.
 */
@RestController
@CrossOrigin(origins = {"http://localhost:80", "http://localhost:443", "http://localhost:5173", "http://localhost:5174"}, allowedHeaders = "*", allowCredentials = "true")
public class AuthenticationRESTController {

    @Autowired
    private RetailCustomerService retailCustomerService;
    
    @Autowired
    private ApplicationInformationService applicationInformationService;
    
    @Autowired
    private RestTemplate restTemplate;

    @Autowired(required = false)
    private AuthenticationManager authenticationManager;

    @RequestMapping(value = "/api/auth/login", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<Map<String, Object>> login(
            @RequestBody Map<String, String> loginData,
            HttpServletRequest request,
            HttpServletResponse response) {
        
        try {
            String username = loginData.get("username");
            String password = loginData.get("password");
            
            if (username == null || password == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "Username and password required"));
            }

            UsernamePasswordAuthenticationToken authReq =
                new UsernamePasswordAuthenticationToken(username, password);
            Authentication authResult = authenticationManager.authenticate(authReq);

            SecurityContext context = SecurityContextHolder.createEmptyContext();
            context.setAuthentication(authResult);
            SecurityContextHolder.setContext(context);
            var session = request.getSession(true);
            session.setAttribute(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY, context);

            RetailCustomer customer = null;
            try {
                var userDetails = retailCustomerService.loadUserByUsername(username);
                customer = (userDetails instanceof RetailCustomer) ? (RetailCustomer) userDetails : null;
            } catch (Exception ignore) { }

            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Authentication successful",
                "user", Map.of("username", username, "id", customer != null ? customer.getId() : null)
            ));
            
        } catch (AuthenticationException ex) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("error", "Invalid credentials"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Authentication failed: " + e.getMessage()));
        }
    }

    @RequestMapping(value = "/api/auth/authorize", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<Map<String, Object>> authorize(
            @RequestBody Map<String, String> authRequest,
            HttpServletRequest request) {
        
        try {
            String clientId = authRequest.get("client_id");
            String responseType = authRequest.get("response_type");
            String redirectUri = authRequest.get("redirect_uri");
            String scope = authRequest.get("scope");
            String state = authRequest.get("state");
            
            if (clientId == null || responseType == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "client_id and response_type required"));
            }
            
            String starsPort = System.getenv().getOrDefault("VITE_STARS_PORT", "5173");
            if (!starsPort.matches("[0-9]{2,5}")) starsPort = "5173";

            StringBuilder authUrl = new StringBuilder("http://" + request.getServerName() + ":" + starsPort + "/confirmation?");
            authUrl.append("client_id=").append(clientId);
            authUrl.append("&response_type=").append(responseType);
            if (redirectUri != null) {
                authUrl.append("&redirect_uri=").append(java.net.URLEncoder.encode(redirectUri, "UTF-8"));
            }
            if (scope != null) {
                authUrl.append("&scope=").append(java.net.URLEncoder.encode(scope, "UTF-8"));
            }
            if (state != null) {
                authUrl.append("&state=").append(java.net.URLEncoder.encode(state, "UTF-8"));
            }
            
            return ResponseEntity.ok(Map.of(
                "authorization_url", authUrl.toString(),
                "message", "Redirect to Stars frontend consent page"
            ));
            
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Authorization failed: " + e.getMessage()));
        }
    }

    @RequestMapping(value = "/api/auth/consent", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<Map<String, Object>> handleConsent(
            @RequestBody Map<String, Object> consentData,
            HttpServletRequest request) {
        
        try {
            String clientId = (String) consentData.get("client_id");
            String redirectUri = (String) consentData.get("redirect_uri");
            String state = (String) consentData.get("state");
            Boolean approved = (Boolean) consentData.get("approved");
            String username = (String) consentData.get("username");
            String password = (String) consentData.get("password");
            
                                    // Use the CORRECT registered redirect URI for third_party client
            String actualRedirectUri = "http://localhost:9090/ThirdParty/espi/1_1/OAuthCallBack";
            
            System.out.println("[consent] Processing consent: clientId=" + clientId + ", user=" + username + 
                             ", approved=" + approved + ", using registered redirectUri=" + actualRedirectUri);
            
            if (clientId == null || redirectUri == null || username == null || password == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "client_id, redirect_uri, username, and password required"));
            }
            
            // Authenticate user and establish session
            try {
                UsernamePasswordAuthenticationToken authReq = new UsernamePasswordAuthenticationToken(username, password);
                Authentication authResult = authenticationManager.authenticate(authReq);
                
                SecurityContext context = SecurityContextHolder.createEmptyContext();
                context.setAuthentication(authResult);
                SecurityContextHolder.setContext(context);
                request.getSession(true).setAttribute(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY, context);
                
                System.out.println("[consent] User authenticated and session established: " + username);
            } catch (AuthenticationException ex) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid credentials"));
            }
            
            if (!Boolean.TRUE.equals(approved)) {
                // On denial, send the user back to PetSafe FE (not to ThirdParty callback)
                String petsafePort = System.getenv().getOrDefault("VITE_PETSAFE_PORT", "5174");
                if (!petsafePort.matches("[0-9]{2,5}")) petsafePort = "5174";
                StringBuilder denyUrl = new StringBuilder("http://" + request.getServerName() + ":" + petsafePort + "/");
                denyUrl.append("?error=access_denied");
                if (state != null) {
                    denyUrl.append("&state=").append(java.net.URLEncoder.encode(state, "UTF-8"));
                }
                return ResponseEntity.ok(java.util.Map.of("redirect_url", denyUrl.toString()));
            }
            
            // Generate REAL OAuth code by POSTing to DataCustodian OAuth like oauth_proxy_test.sh
            try {
                MultiValueMap<String, String> oauthParams = new LinkedMultiValueMap<>();
                oauthParams.add("user_oauth_approval", "true");
                oauthParams.add("authorize", "Submit");
                oauthParams.add("response_type", "code");
                oauthParams.add("client_id", clientId);
                oauthParams.add("redirect_uri", actualRedirectUri);
                if (state != null) oauthParams.add("state", state);
                // pass through privacy level if provided
                Object privacyLevel = consentData.get("privacy_level");
                if (privacyLevel != null) {
                    oauthParams.add("privacy_level", String.valueOf(privacyLevel));
                    
                    // Store privacy level in temp file for subscription creation
                    try {
                        String tempFile = "/tmp/espi_privacy_" + username + ".txt";
                        java.nio.file.Files.write(java.nio.file.Paths.get(tempFile), 
                            String.valueOf(privacyLevel).getBytes());
                        System.out.println("[consent] Stored privacy level " + privacyLevel + " for user " + username);
                    } catch (Exception e) {
                        System.err.println("[consent] Failed to store privacy level: " + e.getMessage());
                    }
                }
                // pass through selected scopes as scope.*=true like the confirmation form expects
                Object scopesObj = consentData.get("scopes");
                if (scopesObj instanceof Map<?, ?>) {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> scopesMap = (Map<String, Object>) scopesObj;
                    for (Map.Entry<String, Object> entry : scopesMap.entrySet()) {
                        String key = entry.getKey();
                        Object val = entry.getValue();
                        if (val instanceof Boolean && (Boolean) val) {
                            oauthParams.add(key, "true");
                        } else if (val != null && "true".equalsIgnoreCase(String.valueOf(val))) {
                            oauthParams.add(key, "true");
                        }
                    }
                }
                
                // Add privacy level to scope parameters if provided
                if (privacyLevel != null) {
                    oauthParams.add("scope.privacy:" + privacyLevel, "true");
                }
                
                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
                // Use the user's authenticated session cookie
                headers.add("Cookie", "JSESSIONID=" + request.getSession().getId());
                
                HttpEntity<MultiValueMap<String, String>> requestEntity = new HttpEntity<>(oauthParams, headers);
                
                // Step 1: GET to initialize the OAuth authorization request (like oauth proxy test)
                UriComponentsBuilder builder = UriComponentsBuilder
                        .fromHttpUrl(request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/DataCustodian/oauth/authorize")
                        .queryParam("client_id", clientId)
                        .queryParam("response_type", "code")
                        .queryParam("redirect_uri", actualRedirectUri);
                if (state != null && !state.isEmpty()) {
                    builder.queryParam("state", state);
                }
                String oauthGetUrl = builder.build().toUriString();
                
                System.out.println("[consent] Step 1 - GET to initialize OAuth: " + oauthGetUrl);
                
                // Make GET request to initialize authorization (creates session)
                HttpHeaders getHeaders = new HttpHeaders();
                getHeaders.add("Cookie", "JSESSIONID=" + request.getSession().getId());
                ResponseEntity<String> getResponse = restTemplate.exchange(
                    oauthGetUrl, HttpMethod.GET, new HttpEntity<>(getHeaders), String.class);
                
                System.out.println("[consent] GET response: " + getResponse.getStatusCode());
                
                // Step 2: POST to approve the initialized request
                String oauthUrl = request.getScheme() + "://" + request.getServerName() + 
                                ":" + request.getServerPort() + "/DataCustodian/oauth/authorize";
                
                System.out.println("[consent] Step 2 - POST to approve OAuth: " + oauthUrl);
                
                // Use regular RestTemplate - handle redirects via exception
                RestTemplate oauthRestTemplate = new RestTemplate();
                
                ResponseEntity<String> oauthResponse = oauthRestTemplate.exchange(
                    oauthUrl, HttpMethod.POST, requestEntity, String.class);
                
                if (oauthResponse.getStatusCode().is3xxRedirection()) {
                    String location = oauthResponse.getHeaders().getFirst("Location");
                    if (location != null) {
                        System.out.println("[consent] REAL OAuth code generated: " + location);
                        
                        // Send the callback URL directly to ThirdParty backend (server-to-server)
                        // Don't return any URL to Stars FE
                        try {
                            // Make a GET request to the ThirdParty callback URL
                            ResponseEntity<String> callbackResponse = restTemplate.exchange(
                                location, HttpMethod.GET, null, String.class);
                            
                            System.out.println("[consent] ThirdParty callback completed: " + callbackResponse.getStatusCode());
                            
                        } catch (Exception callbackEx) {
                            System.out.println("[consent] ThirdParty callback failed: " + callbackEx.getMessage());
                        }
                        
                        // Return success to Stars FE (no redirect URL)
                        return ResponseEntity.ok(Map.of(
                            "success", true,
                            "message", "OAuth authorization completed"
                        ));
                    }
                }
                
                System.out.println("[consent] OAuth failed - status: " + oauthResponse.getStatusCode());
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "OAuth authorization failed"));
                
            } catch (Exception e) {
                System.out.println("[consent] OAuth error: " + e.getMessage());
                e.printStackTrace();
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "OAuth failed: " + e.getMessage()));
            }
            
        } catch (Exception e) {
            System.out.println("[consent] Error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Consent processing failed: " + e.getMessage()));
        }
    }

    @RequestMapping(value = "/api/auth/token", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<Map<String, Object>> token(
            @RequestBody Map<String, String> tokenRequest,
            HttpServletRequest request) {
        
        try {
            String grantType = tokenRequest.get("grant_type");
            String code = tokenRequest.get("code");
            String clientId = tokenRequest.get("client_id");
            String clientSecret = tokenRequest.get("client_secret");
            String redirectUri = tokenRequest.get("redirect_uri");
            
            if (grantType == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "grant_type required"));
            }
            
            String tokenUrl = request.getScheme() + "://" + request.getServerName() + 
                            ":" + request.getServerPort() + "/DataCustodian/oauth/token";
            
            System.out.println("[token] Proxying token request to: " + tokenUrl + " with code: " + code);
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
            
            if (clientId != null && clientSecret != null) {
                String basicAuth = java.util.Base64.getEncoder().encodeToString((clientId + ":" + clientSecret).getBytes());
                headers.add("Authorization", "Basic " + basicAuth);
            }
            
            MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
            params.add("grant_type", grantType);
            if (code != null) params.add("code", code);
            if (clientId != null) params.add("client_id", clientId);
            if (redirectUri != null) params.add("redirect_uri", redirectUri);
            
            HttpEntity<MultiValueMap<String, String>> requestEntity = 
                new HttpEntity<>(params, headers);
            
            @SuppressWarnings("unchecked")
            ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                tokenUrl, HttpMethod.POST, requestEntity, (Class<Map<String, Object>>) (Class<?>) Map.class);
            
            System.out.println("[token] Got response: " + response.getBody());
            return ResponseEntity.status(response.getStatusCode())
                .body(response.getBody());
            
        } catch (Exception e) {
            System.out.println("[token] Error: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Token exchange failed: " + e.getMessage()));
        }
    }

    @GetMapping("/api/auth/scopes")
    @ResponseBody
    public ResponseEntity<Map<String,Object>> availableScopes() {
        try {
            ApplicationInformation thirdPartyApp = applicationInformationService.findByClientId("third_party");
            List<String> allScopes = thirdPartyApp != null ? 
                    new java.util.ArrayList<>(thirdPartyApp.getScope()) : List.of();
            
            List<String> fbScopes = allScopes.stream()
                    .filter(scope -> scope.startsWith("FB="))
                    .collect(java.util.stream.Collectors.toList());
            
            List<String> privacyScopes = allScopes.stream()
                    .filter(scope -> scope.startsWith("privacy:"))
                    .collect(java.util.stream.Collectors.toList());
            
            List<Map<String,String>> privacyLevels = privacyScopes.stream()
                    .map(scope -> {
                        String level = scope.replace("privacy:", "");
                        String label = level.substring(0, 1).toUpperCase() + level.substring(1) + " Privacy";
                        return Map.of("value", level, "label", label);
                    })
                    .collect(java.util.stream.Collectors.toList());
            
            Map<String,Object> resp = new LinkedHashMap<>();
            resp.put("fb_scopes", fbScopes);
            resp.put("privacy_levels", privacyLevels);
            return ResponseEntity.ok(resp);
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error","Failed to list scopes: "+ex.getMessage()));
        }
    }

    @GetMapping("/api/auth/session")
    @ResponseBody
    public ResponseEntity<Map<String,Object>> session(HttpServletRequest request) {
        try {
            var ctx = SecurityContextHolder.getContext();
            var auth = ctx != null ? ctx.getAuthentication() : null;
            boolean authenticated = auth != null && auth.isAuthenticated() && !("anonymousUser".equals(String.valueOf(auth.getPrincipal())));
            String username = null;
            Long userId = null;
            if (authenticated) {
                Object principal = auth.getPrincipal();
                if (principal instanceof RetailCustomer) {
                    RetailCustomer rc = (RetailCustomer) principal;
                    username = rc.getUsername();
                    userId = rc.getId();
                } else {
                    username = String.valueOf(principal);
                }
            }
            return ResponseEntity.ok(java.util.Map.of(
                "authenticated", authenticated,
                "username", username,
                "userId", userId,
                "sessionId", request.getSession(false) != null ? request.getSession(false).getId() : null
            ));
        } catch (Exception ex) {
            return ResponseEntity.status(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(java.util.Map.of("error", ex.getMessage()));
        }
    }
}
