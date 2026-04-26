package k1;

import com.google.android.gms.internal.p002firebaseauthapi.zzxv;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public abstract class l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0.a f5535a = new C0.a("GetTokenResultFactory", new String[0]);

    public static B.k a(String str) {
        Object map;
        try {
            map = k.b(str);
        } catch (zzxv e) {
            f5535a.b("Error parsing token claims", e, new Object[0]);
            map = new HashMap();
        }
        B.k kVar = new B.k(23, false);
        kVar.f104b = map;
        return kVar;
    }
}
