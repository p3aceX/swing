package j1;

import android.net.Uri;
import com.google.android.gms.internal.p002firebaseauthapi.zzau;
import java.util.HashMap;
import java.util.Set;

/* JADX INFO: renamed from: j1.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0457b {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final /* synthetic */ int f5190c = 0;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final String f5191a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f5192b;

    static {
        HashMap map = new HashMap();
        map.put("recoverEmail", 2);
        map.put("resetPassword", 0);
        map.put("signIn", 4);
        map.put("verifyEmail", 1);
        map.put("verifyBeforeChangeEmail", 5);
        map.put("revertSecondFactorAddition", 6);
        zzau.zza(map);
    }

    public C0457b(String str) {
        String strA = a(str, "apiKey");
        String strA2 = a(str, "oobCode");
        String strA3 = a(str, "mode");
        if (strA == null || strA2 == null || strA3 == null) {
            throw new IllegalArgumentException("apiKey, oobCode and mode are required in a valid action code URL");
        }
        com.google.android.gms.common.internal.F.d(strA);
        com.google.android.gms.common.internal.F.d(strA2);
        this.f5191a = strA2;
        com.google.android.gms.common.internal.F.d(strA3);
        a(str, "continueUrl");
        a(str, "languageCode");
        this.f5192b = a(str, "tenantId");
    }

    public static String a(String str, String str2) {
        Uri uri = Uri.parse(str);
        try {
            Set<String> queryParameterNames = uri.getQueryParameterNames();
            if (queryParameterNames.contains(str2)) {
                return uri.getQueryParameter(str2);
            }
            if (!queryParameterNames.contains("link")) {
                return null;
            }
            String queryParameter = uri.getQueryParameter("link");
            com.google.android.gms.common.internal.F.d(queryParameter);
            return Uri.parse(queryParameter).getQueryParameter(str2);
        } catch (NullPointerException | UnsupportedOperationException unused) {
            return null;
        }
    }
}
