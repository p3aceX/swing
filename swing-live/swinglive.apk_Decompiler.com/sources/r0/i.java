package R0;

import java.security.GeneralSecurityException;
import java.util.Locale;
import java.util.concurrent.CopyOnWriteArrayList;

/* JADX INFO: loaded from: classes.dex */
public abstract class i {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final CopyOnWriteArrayList f1689a = new CopyOnWriteArrayList();

    public static X0.c a(String str) throws GeneralSecurityException {
        boolean zStartsWith;
        for (X0.c cVar : f1689a) {
            synchronized (cVar) {
                zStartsWith = str.toLowerCase(Locale.US).startsWith("android-keystore://");
            }
            if (zStartsWith) {
                return cVar;
            }
        }
        throw new GeneralSecurityException(B1.a.m("No KMS client does support: ", str));
    }
}
