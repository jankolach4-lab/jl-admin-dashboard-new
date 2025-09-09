package de.ams.Qualifizierungstool.plugins;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.util.Base64;

import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.ActivityResult;
import com.getcapacitor.annotation.ActivityCallback;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.PluginMethod;

import java.io.OutputStream;

@CapacitorPlugin(name = "SaveAs")
public class SaveAsPlugin extends Plugin {

    @PluginMethod
    public void createDocumentAndWrite(PluginCall call) {
        String filename = call.getString("filename");
        String mime = call.getString("mime", "application/octet-stream");
        String base64 = call.getString("base64");

        if (filename == null || filename.trim().isEmpty()) {
            call.reject("missing_filename");
            return;
        }
        if (base64 == null || base64.isEmpty()) {
            call.reject("missing_data");
            return;
        }

        // Save data in call for callback usage
        call.set("__mime", mime);
        call.set("__data", base64);

        Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType(mime);
        intent.putExtra(Intent.EXTRA_TITLE, filename);

        startActivityForResult(call, intent, "onSaveDocumentResult");
    }

    @ActivityCallback
    private void onSaveDocumentResult(PluginCall call, ActivityResult result) {
        if (result.getResultCode() != Activity.RESULT_OK || result.getData() == null) {
            if (call != null) call.reject("user_cancelled");
            return;
        }
        try {
            Uri uri = result.getData().getData();
            String base64 = call.getString("__data");
            byte[] bytes = Base64.decode(base64, Base64.DEFAULT);
            OutputStream os = getContext().getContentResolver().openOutputStream(uri, "w");
            if (os == null) {
                call.reject("open_output_stream_failed");
                return;
            }
            os.write(bytes);
            os.flush();
            os.close();
            call.resolve();
        } catch (Exception e) {
            if (call != null) call.reject(e.getMessage());
        }
    }
}