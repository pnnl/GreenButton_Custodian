package org.greenbuttonalliance.espi.datacustodian.console;

import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.mime.HttpMultipartMode;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import java.io.File;
import java.io.IOException;

public class ImportUsagePoint {
    // This matches the DataCustodian controller: POST /custodian/upload
    private static final String UPLOAD_PATH = "/custodian/upload";

    public static void upload(File file, String baseUrl) throws IOException {
        // build target URL (strip any trailing slash from baseUrl)
        String cleanBase = baseUrl.endsWith("/") 
            ? baseUrl.substring(0, baseUrl.length() - 1) 
            : baseUrl;
        String targetUrl = cleanBase + UPLOAD_PATH;

        System.out.println("=== ImportUsagePoint ===");
        System.out.printf("Preparing to upload file: %s (%,d bytes)%n",
                file.getAbsolutePath(), file.length());
        System.out.printf("Target URL: %s%n", targetUrl);

        // build multipart request
        FileBody fb = new FileBody(file, ContentType.create("application/rss+xml"), file.getName());
        HttpEntity multipart = MultipartEntityBuilder.create()
                .setMode(HttpMultipartMode.BROWSER_COMPATIBLE)
                .addPart("file", fb)
                .build();

        HttpPost post = new HttpPost(targetUrl);
        post.setEntity(multipart);

        // send request
        try (CloseableHttpClient client = HttpClients.createDefault();
             CloseableHttpResponse resp = client.execute(post)) {

            int status = resp.getStatusLine().getStatusCode();
            String reason = resp.getStatusLine().getReasonPhrase();
            System.out.printf("→ HTTP %d %s%n", status, reason);

            System.out.println("Response headers:");
            for (org.apache.http.Header h : resp.getAllHeaders()) {
                System.out.printf("  %s: %s%n", h.getName(), h.getValue());
            }

            HttpEntity respEntity = resp.getEntity();
            if (respEntity != null) {
                String body = EntityUtils.toString(respEntity, "UTF-8");
                System.out.println("Response body:");
                System.out.println("--------------------------------");
                System.out.println(body);
                System.out.println("--------------------------------");
            } else {
                System.out.println("No response body.");
            }
        }
    }

    public static void main(String[] args) {
        if (args.length != 2) {
            System.err.println("Usage: ImportUsagePoint <filename> <baseUrl>");
            System.err.println("  e.g. ImportUsagePoint "
                    + "src/fixtures/test_usage_data.xml http://localhost:8080/DataCustodian");
            System.exit(1);
        }

        File file = new File(args[0]);
        if (!file.exists() || !file.isFile()) {
            System.err.printf("ERROR: File not found: %s%n", args[0]);
            System.exit(2);
        }

        String baseUrl = args[1];
        try {
            upload(file, baseUrl);
        } catch (IOException e) {
            System.err.println("Upload failed: " + e.getMessage());
            e.printStackTrace();
            System.exit(3);
        }

        System.out.println("ImportUsagePoint main() exiting.");
    }
}
