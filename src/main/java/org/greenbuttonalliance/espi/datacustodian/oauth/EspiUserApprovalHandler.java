package org.greenbuttonalliance.espi.datacustodian.oauth;

import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.provider.AuthorizationRequest;
import org.springframework.security.oauth2.provider.ClientDetails;
import org.springframework.security.oauth2.provider.ClientDetailsService;
import org.springframework.security.oauth2.provider.ClientRegistrationException;
import org.springframework.security.oauth2.provider.approval.ApprovalStoreUserApprovalHandler;

import java.util.Collection;

/**
 * Custom UserApprovalHandler that can be toggled on/off
 * so you can force a consent screen even if the client
 * has already been auto‑approved.
 */
public class EspiUserApprovalHandler extends ApprovalStoreUserApprovalHandler {

    private boolean useApprovalStore = true;        // <— default: enforce stored approvals
    private ClientDetailsService clientDetailsService;

    /**
     * Set whether to consult the approvalStore at all.
     * When false we skip super.checkForPreApproval(...) and
     * only honor the client.isAutoApprove(...) flags.
     */
    public void setUseApprovalStore(boolean useApprovalStore) {
        this.useApprovalStore = useApprovalStore;
    }

    @Override
    public void setClientDetailsService(ClientDetailsService clientDetailsService) {
        super.setClientDetailsService(clientDetailsService);
        this.clientDetailsService = clientDetailsService;
    }

    @Override
    public AuthorizationRequest checkForPreApproval(AuthorizationRequest authorizationRequest,
                                                    Authentication userAuthentication) {
        // Test-only override: allow fully headless OAuth flow when enabled
        String auto = System.getProperty("espi.autoapprove", "false");
        if ("true".equalsIgnoreCase(auto)) {
            authorizationRequest.setApproved(true);
            return authorizationRequest;
        }

        boolean approved = false;

        if (useApprovalStore) {
            // consult the approvalStore (i.e. persist approvals in the database)
            authorizationRequest = super.checkForPreApproval(authorizationRequest, userAuthentication);
            approved = authorizationRequest.isApproved();
        } else if (clientDetailsService != null) {
            // skip the approvalStore; only auto‑approve scopes marked in clientDetails
            Collection<String> scopes = authorizationRequest.getScope();
            try {
                ClientDetails client = clientDetailsService
                        .loadClientByClientId(authorizationRequest.getClientId());
                for (String scope : scopes) {
                    if (client.isAutoApprove(scope) || client.isAutoApprove("all")) {
                        approved = true;
                        break;
                    }
                }
            } catch (ClientRegistrationException e) {
                // ignore, leave approved = false
            }
        }

        authorizationRequest.setApproved(approved);
        return authorizationRequest;
    }
}
