package org.greenbuttonalliance.espi.datacustodian.web.api;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import java.util.HashMap;
import java.util.Map;

@Controller
public class TestController {

    @RequestMapping(value = "/api/test", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<Map<String, Object>> test() {
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Test endpoint working");
        response.put("status", "success");
        return ResponseEntity.ok(response);
    }
}
