// android/src/main/java/com/your/plugin/CertificateChecker.java

package com.tonybluckdruck.certificatechecker;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

import java.net.URL;
import java.security.MessageDigest;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

@CapacitorPlugin(name = "SSLCertificateChecker")
public class SSLCertificateChecker extends Plugin {

    @PluginMethod
    public void checkCertificate(PluginCall call) {
        String url = call.getString("url");
        String expectedFingerprint = call.getString("fingerprint").replace(":", "");
        
        if (url == null || expectedFingerprint == null) {
            call.reject("URL and fingerprint are required");
            return;
        }

        try {
            Certificate cert = getCertificate(url);
            String actualFingerprint = getFingerprint(cert);
            
            JSObject result = new JSObject();
            if (cert instanceof X509Certificate) {
                X509Certificate x509cert = (X509Certificate) cert;
                result.put("subject", x509cert.getSubjectDN().getName());
                result.put("issuer", x509cert.getIssuerDN().getName());
                result.put("validFrom", x509cert.getNotBefore().toString());
                result.put("validTo", x509cert.getNotAfter().toString());
                result.put("fingerprint", actualFingerprint);
                result.put("fingerprintMatched", expectedFingerprint.equalsIgnoreCase(actualFingerprint));
            }
            call.resolve(result);
        } catch (Exception e) {
            call.reject("Certificate check failed: " + e.getMessage());
        }
    }

    private Certificate getCertificate(String urlString) throws Exception {
        URL url = new URL(urlString);
        HttpsURLConnection connection = (HttpsURLConnection) url.openConnection();

        TrustManager[] trustManagers = new TrustManager[] {
            new X509TrustManager() {
                public X509Certificate[] getAcceptedIssuers() { return null; }
                public void checkClientTrusted(X509Certificate[] certs, String authType) throws CertificateException { }
                public void checkServerTrusted(X509Certificate[] certs, String authType) throws CertificateException { 
                    if (certs == null || certs.length == 0) {
                        throw new CertificateException("No certificate found");
                    }
                }
            }
        };

        SSLContext sslContext = SSLContext.getInstance("TLS");
        sslContext.init(null, trustManagers, new java.security.SecureRandom());
        connection.setSSLSocketFactory(sslContext.getSocketFactory());

        connection.connect();
        Certificate cert = connection.getServerCertificates()[0];
        connection.disconnect();

        return cert;
    }

    private String getFingerprint(Certificate cert) throws Exception {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] der = cert.getEncoded();
        md.update(der);
        byte[] digest = md.digest();
        return bytesToHex(digest);
    }

    private String bytesToHex(byte[] bytes) {
        StringBuilder result = new StringBuilder();
        for (byte b : bytes) {
            result.append(String.format("%02X", b));
        }
        return result.toString();
    }
}