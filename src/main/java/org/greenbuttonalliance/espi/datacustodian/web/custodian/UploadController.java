package org.greenbuttonalliance.espi.datacustodian.web.custodian;

import org.greenbuttonalliance.espi.common.domain.Routes;
import org.greenbuttonalliance.espi.common.service.ImportService;
import org.greenbuttonalliance.espi.common.service.UsagePointService;
import org.greenbuttonalliance.espi.common.service.NotificationService;
import org.greenbuttonalliance.espi.datacustodian.web.BaseController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.http.HttpStatus;
import org.springframework.validation.BindingResult;
import org.springframework.validation.ObjectError;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.multipart.MultipartFile;
import org.xml.sax.SAXException;

import java.io.IOException;
import javax.servlet.http.HttpServletResponse;

@Controller
public class UploadController extends BaseController {

    @Autowired
    private ImportService importService;

    @Autowired
    private UsagePointService usagePointService;

    @Autowired
    private NotificationService notificationService;

    @ModelAttribute("uploadForm")
    public UploadForm uploadForm() {
        return new UploadForm();
    }

    @RequestMapping(value = Routes.DATA_CUSTODIAN_UPLOAD, method = RequestMethod.GET)
    public void upload(HttpServletResponse response) throws IOException {
        // Deprecated endpoint: guide callers to the new REST API
        response.sendError(HttpServletResponse.SC_GONE, "This endpoint is deprecated. Use POST /api/data/import?retailCustomerId={id}");
    }

    @RequestMapping(value = Routes.DATA_CUSTODIAN_UPLOAD, method = RequestMethod.POST)
    public String uploadPost(@ModelAttribute("uploadForm") UploadForm uploadForm,
                             BindingResult result) {
        MultipartFile file = uploadForm.getFile();
        if (file == null || file.isEmpty()) {
            result.addError(new ObjectError("uploadForm", "Please select a file to upload."));
            return "/custodian/upload";
        }

        try {
            // Let the XML drive its own <RetailCustomer> binding
            importService.importData(file.getInputStream(), null);
            // On success, go back to the custodian's customer list
            return "redirect:/custodian/retailcustomers";

        } catch (SAXException e) {
            result.addError(new ObjectError("uploadForm", "XML parsing error: " + e.getMessage()));
            return "/custodian/upload";

        } catch (IOException e) {
            result.addError(new ObjectError("uploadForm", "I/O error reading file: " + e.getMessage()));
            return "/custodian/upload";

        } catch (Exception e) {
            result.addError(new ObjectError("uploadForm", "Unable to process file: " + e.getMessage()));
            return "/custodian/upload";
        }
    }

    // Setters/getters for tests or overrides

    public void setImportService(ImportService importService) {
        this.importService = importService;
    }
    public ImportService getImportService() {
        return importService;
    }

    public void setUsagePointService(UsagePointService usagePointService) {
        this.usagePointService = usagePointService;
    }
    public UsagePointService getUsagePointService() {
        return usagePointService;
    }

    public void setNotificationService(NotificationService notificationService) {
        this.notificationService = notificationService;
    }
    public NotificationService getNotificationService() {
        return notificationService;
    }
}
