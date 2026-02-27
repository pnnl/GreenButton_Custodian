package org.greenbuttonalliance.espi.datacustodian.web.customer;

import org.greenbuttonalliance.espi.common.domain.ApplicationInformation;
import org.greenbuttonalliance.espi.common.service.ApplicationInformationService;
import org.greenbuttonalliance.espi.datacustodian.web.BaseController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@PreAuthorize("hasRole('ROLE_USER')")
@RequestMapping("/RetailCustomer/{retailCustomerId}/ThirdPartyList")
public class ThirdPartyController extends BaseController {

    @Autowired
    private ApplicationInformationService applicationInformationService;

    @GetMapping
    public String showThirdPartyList(
            @PathVariable("retailCustomerId") Long retailCustomerId,
            Model model) {

        List<ApplicationInformation> thirdParties =
            applicationInformationService.findByKind("THIRD_PARTY");

        model.addAttribute("applicationInformationList", thirdParties);
        model.addAttribute("retailCustomerId", retailCustomerId);
        return "customer/thirdparties/index";
    }

    @PostMapping
    public String connectToScopeSelection(
            @PathVariable("retailCustomerId") Long retailCustomerId,
            @RequestParam("ThirdPartyID") String thirdPartyClientId) {

        // NOTE the capital 'S' in ScopeSelection to match the controller mapping below
        String target = String.format(
            "/RetailCustomer/%d/ScopeSelection?ThirdPartyID=%s",
            retailCustomerId,
            thirdPartyClientId);

        return "redirect:" + target;
    }
}
