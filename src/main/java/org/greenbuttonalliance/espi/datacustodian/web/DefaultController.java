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

package org.greenbuttonalliance.espi.datacustodian.web;

import org.greenbuttonalliance.espi.common.domain.RetailCustomer;
import org.greenbuttonalliance.espi.common.domain.Routes;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpServletRequest;
import java.security.Principal;

@Controller
public class DefaultController extends BaseController {

    @RequestMapping(Routes.DEFAULT)
    public String defaultAfterLogin(HttpServletRequest request, Principal principal) {
        // Check if user is in the Custodian role
        if (request.isUserInRole(RetailCustomer.ROLE_CUSTODIAN)) {
            return "redirect:/custodian/home";
        }
        
        // Check if user is in the RetailCustomer role
        else if (request.isUserInRole(RetailCustomer.ROLE_USER)) {
            // Null check for Principal
            if (principal == null) {
                System.err.println("Error: Principal is null. Redirecting to /home.");
                return "redirect:/home";
            }

            // Attempt to get the current customer
            RetailCustomer customer = currentCustomer(principal);
            if (customer == null) {
                System.err.println("Error: currentCustomer() returned null for principal: " + principal.getName());
                return "redirect:/home";
            }

            // Check if customer ID is null
            if (customer.getId() == null) {
                System.err.println("Error: Customer ID is null for customer: " + customer);
                return "redirect:/home";
            }

            // Redirect to the RetailCustomer home
            return "redirect:/RetailCustomer/" + customer.getId() + "/home";
        }

        // Default fallback redirect
        return "redirect:/home";
    }
}
