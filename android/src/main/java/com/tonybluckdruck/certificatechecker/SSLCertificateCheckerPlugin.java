package com.tonybluckdruck.certificatechecker;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "SSLCertificateChecker")
public class SSLCertificateCheckerPlugin extends Plugin {

    private SSLCertificateChecker implementation = new SSLCertificateChecker();

    @PluginMethod
    public void checkCertificate(PluginCall call) {
        implementation.checkCertificate(call);
    }
}
