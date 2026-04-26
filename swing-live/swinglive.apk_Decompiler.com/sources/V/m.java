package V;

import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import java.io.File;
import java.io.IOException;
import o.AbstractFutureC0576h;
import o.C0577i;

/* JADX INFO: loaded from: classes.dex */
public abstract class m {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0577i f2169a = new C0577i();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final Object f2170b = new Object();

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static p1.d f2171c = null;

    public static long a(Context context) {
        PackageManager packageManager = context.getApplicationContext().getPackageManager();
        return Build.VERSION.SDK_INT >= 33 ? k.a(packageManager, context).lastUpdateTime : packageManager.getPackageInfo(context.getPackageName(), 0).lastUpdateTime;
    }

    public static p1.d b() {
        p1.d dVar = new p1.d(24);
        f2171c = dVar;
        C0577i c0577i = f2169a;
        c0577i.getClass();
        if (AbstractFutureC0576h.f5952f.e(c0577i, null, dVar)) {
            AbstractFutureC0576h.c(c0577i);
        }
        return f2171c;
    }

    public static void c(Context context, boolean z4) {
        l lVarA;
        int i4;
        if (z4 || f2171c == null) {
            synchronized (f2170b) {
                if (!z4) {
                    try {
                        if (f2171c != null) {
                            return;
                        }
                    } catch (Throwable th) {
                        throw th;
                    }
                }
                int i5 = Build.VERSION.SDK_INT;
                if (i5 >= 28 && i5 != 30) {
                    File file = new File(new File("/data/misc/profiles/ref/", context.getPackageName()), "primary.prof");
                    long length = file.length();
                    int i6 = 0;
                    boolean z5 = file.exists() && length > 0;
                    File file2 = new File(new File("/data/misc/profiles/cur/0/", context.getPackageName()), "primary.prof");
                    long length2 = file2.length();
                    boolean z6 = file2.exists() && length2 > 0;
                    try {
                        long jA = a(context);
                        File file3 = new File(context.getFilesDir(), "profileInstalled");
                        if (file3.exists()) {
                            try {
                                lVarA = l.a(file3);
                            } catch (IOException unused) {
                                b();
                                return;
                            }
                        } else {
                            lVarA = null;
                        }
                        if (lVarA != null && lVarA.f2167c == jA && (i4 = lVarA.f2166b) != 2) {
                            i6 = i4;
                        } else if (z5) {
                            i6 = 1;
                        } else if (z6) {
                            i6 = 2;
                        }
                        if (z4 && z6 && i6 != 1) {
                            i6 = 2;
                        }
                        if (lVarA != null && lVarA.f2166b == 2 && i6 == 1 && length < lVarA.f2168d) {
                            i6 = 3;
                        }
                        l lVar = new l(1, i6, jA, length2);
                        if (lVarA == null || !lVarA.equals(lVar)) {
                            try {
                                lVar.b(file3);
                            } catch (IOException unused2) {
                            }
                        }
                        b();
                        return;
                    } catch (PackageManager.NameNotFoundException unused3) {
                        b();
                        return;
                    }
                }
                b();
            }
        }
    }
}
