package y0;

import com.google.android.gms.common.api.Status;
import com.google.android.gms.common.api.internal.C0272u;
import com.google.android.gms.common.internal.F;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

/* JADX INFO: renamed from: y0.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class RunnableC0739c implements Runnable {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final C0.a f6810c = new C0.a("RevokeAccessOperation", new String[0]);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f6811a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final C0272u f6812b;

    public RunnableC0739c(String str) {
        F.d(str);
        this.f6811a = str;
        this.f6812b = new C0272u(null, 0);
    }

    @Override // java.lang.Runnable
    public final void run() {
        C0.a aVar = f6810c;
        Status status = Status.f3374n;
        try {
            HttpURLConnection httpURLConnection = (HttpURLConnection) new URL("https://accounts.google.com/o/oauth2/revoke?token=" + this.f6811a).openConnection();
            httpURLConnection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            int responseCode = httpURLConnection.getResponseCode();
            if (responseCode == 200) {
                status = Status.f3372f;
            } else {
                aVar.c("Unable to revoke access!", new Object[0]);
            }
            aVar.a("Response Code: " + responseCode, new Object[0]);
        } catch (IOException e) {
            aVar.c("IOException when revoking access: ".concat(String.valueOf(e.toString())), new Object[0]);
        } catch (Exception e4) {
            aVar.c("Exception when revoking access: ".concat(String.valueOf(e4.toString())), new Object[0]);
        }
        this.f6812b.setResult(status);
    }
}
