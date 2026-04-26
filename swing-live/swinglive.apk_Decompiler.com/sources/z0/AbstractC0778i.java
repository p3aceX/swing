package z0;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInstaller;
import android.content.pm.PackageManager;
import com.google.crypto.tink.shaded.protobuf.S;
import java.util.Iterator;
import java.util.concurrent.atomic.AtomicBoolean;

/* JADX INFO: renamed from: z0.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0778i {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static boolean f6964b = false;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static boolean f6965c = false;
    public static final /* synthetic */ int e = 0;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final AtomicBoolean f6963a = new AtomicBoolean();

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final AtomicBoolean f6966d = new AtomicBoolean();

    public static void a(Context context) throws C0776g, C0777h {
        C0775f c0775f = C0775f.f6961b;
        int iC = c0775f.c(context, 8400000);
        if (iC != 0) {
            Intent intentA = c0775f.a(context, iC, "e");
            S.j("GooglePlayServices not available due to error ", iC, "GooglePlayServicesUtil");
            if (intentA != null) {
                throw new C0777h(iC, intentA);
            }
            throw new C0776g();
        }
    }

    public static boolean b(Context context) {
        try {
            Iterator<PackageInstaller.SessionInfo> it = context.getPackageManager().getPackageInstaller().getAllSessions().iterator();
            while (it.hasNext()) {
                if ("com.google.android.gms".equals(it.next().getAppPackageName())) {
                    return true;
                }
            }
            return context.getPackageManager().getApplicationInfo("com.google.android.gms", 8192).enabled;
        } catch (PackageManager.NameNotFoundException | Exception unused) {
            return false;
        }
    }
}
