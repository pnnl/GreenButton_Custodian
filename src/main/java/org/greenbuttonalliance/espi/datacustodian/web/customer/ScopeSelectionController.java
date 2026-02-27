package org.greenbuttonalliance.espi.datacustodian.web.customer;

import org.greenbuttonalliance.espi.common.domain.ApplicationInformation;
import org.greenbuttonalliance.espi.common.domain.Authorization;
import org.greenbuttonalliance.espi.common.domain.RetailCustomer;
import org.greenbuttonalliance.espi.common.service.ApplicationInformationService;
import org.greenbuttonalliance.espi.common.service.AuthorizationService;
import org.greenbuttonalliance.espi.common.service.RetailCustomerService;
import org.greenbuttonalliance.espi.datacustodian.web.BaseController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.GregorianCalendar;
import java.util.List;
import java.util.UUID;

@Controller
@PreAuthorize("hasRole('ROLE_USER')")
@RequestMapping("/RetailCustomer/{retailCustomerId}/ScopeSelection")
public class ScopeSelectionController extends BaseController {

    @Autowired
    private ApplicationInformationService applicationInformationService;

    @Autowired
    private AuthorizationService authorizationService;

    @Autowired
    private RetailCustomerService retailCustomerService;

    @GetMapping
    public String showScopeSelection(
            @PathVariable("retailCustomerId") Long retailCustomerId,
            @RequestParam("ThirdPartyID") String thirdPartyClientId,
            Model model) {

        ApplicationInformation appInfo =
            applicationInformationService.findByClientId(thirdPartyClientId);

        model.addAttribute("applicationInformation", appInfo);
        model.addAttribute("availableScopes", appInfo.getScope());
        model.addAttribute("retailCustomerId", retailCustomerId);
        return "customer/thirdparties/selectScope";
    }

    @PostMapping("/startAuth")
    public String startAuth(
            @PathVariable Long retailCustomerId,
            @RequestParam String clientId,
            @RequestParam String redirectUri,
            @RequestParam("scope") List<String> scopes)
            throws UnsupportedEncodingException {

        // ① Generate and persist a pending Authorization (same as before)
        String state = UUID.randomUUID().toString();
        Authorization pending = new Authorization();
        RetailCustomer rc = retailCustomerService.findById(retailCustomerId);
        pending.setRetailCustomer(rc);
        pending.setApplicationInformation(
                applicationInformationService.findByClientId(clientId));
        String scopeJoined = String.join(" ", scopes);
        if (scopeJoined.length() > 250) {
            scopeJoined = scopeJoined.substring(0, 250);
        }
        pending.setScope(scopeJoined);
        pending.setState(state);
        pending.setGrantType("authorization_code");
        pending.setStatus("0");                // 0 = pending
        pending.setUpdated(new GregorianCalendar());
        authorizationService.persist(pending);

        // ② Build the /oauth/authorize URL *without* auto‑approval flags
        String enc = StandardCharsets.UTF_8.name();
        StringBuilder url = new StringBuilder("/oauth/authorize")
                .append("?response_type=code")
                .append("&client_id=").append(URLEncoder.encode(clientId, enc))
                .append("&redirect_uri=").append(URLEncoder.encode(redirectUri, enc))
                .append("&state=").append(state)
                .append("&scope=").append(URLEncoder.encode(scopeJoined, enc));

        return "redirect:" + url;
    }
}
