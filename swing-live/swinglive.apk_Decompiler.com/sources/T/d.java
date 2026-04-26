package t;

import android.content.res.Resources;
import android.os.Build;
import android.util.Log;
import e1.AbstractC0367g;
import java.lang.reflect.Method;

/* JADX INFO: loaded from: classes.dex */
public abstract class d {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final AbstractC0367g f6514a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final n.f f6515b;

    static {
        int i4 = Build.VERSION.SDK_INT;
        if (i4 >= 29) {
            f6514a = new i();
        } else if (i4 >= 28) {
            f6514a = new h();
        } else if (i4 >= 26) {
            f6514a = new g();
        } else {
            Method method = f.e;
            if (method == null) {
                Log.w("TypefaceCompatApi24Impl", "Unable to collect necessary private methods.Fallback to legacy implementation.");
            }
            if (method != null) {
                f6514a = new f();
            } else {
                f6514a = new e();
            }
        }
        f6515b = new n.f(16);
    }

    /* JADX WARN: Removed duplicated region for block: B:14:0x002e  */
    /* JADX WARN: Removed duplicated region for block: B:16:0x0031  */
    /* JADX WARN: Removed duplicated region for block: B:18:0x0043  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static android.graphics.Typeface a(android.content.Context r11, s.e r12, android.content.res.Resources r13, int r14, java.lang.String r15, int r16, int r17, k.C0502t r18) {
        /*
            Method dump skipped, instruction units count: 416
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: t.d.a(android.content.Context, s.e, android.content.res.Resources, int, java.lang.String, int, int, k.t):android.graphics.Typeface");
    }

    public static String b(Resources resources, int i4, String str, int i5, int i6) {
        return resources.getResourcePackageName(i4) + '-' + str + '-' + i5 + '-' + i4 + '-' + i6;
    }
}
