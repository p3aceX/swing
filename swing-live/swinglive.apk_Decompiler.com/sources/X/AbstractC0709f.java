package x;

import D2.H;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Typeface;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import n.k;

/* JADX INFO: renamed from: x.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0709f {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final n.f f6739a = new n.f(16);

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final ThreadPoolExecutor f6740b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final Object f6741c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final k f6742d;

    static {
        ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(0, 1, 10000, TimeUnit.MILLISECONDS, new LinkedBlockingDeque(), new ThreadFactoryC0712i());
        threadPoolExecutor.allowCoreThreadTimeOut(true);
        f6740b = threadPoolExecutor;
        f6741c = new Object();
        f6742d = new k();
    }

    public static C0708e a(String str, Context context, R0.k kVar, int i4) {
        n.f fVar = f6739a;
        Typeface typeface = (Typeface) fVar.get(str);
        if (typeface != null) {
            return new C0708e(typeface);
        }
        try {
            H hA = AbstractC0705b.a(context, kVar);
            int i5 = 1;
            C0710g[] c0710gArr = (C0710g[]) hA.f164b;
            int i6 = hA.f163a;
            if (i6 != 0) {
                i5 = i6 != 1 ? -3 : -2;
            } else if (c0710gArr != null && c0710gArr.length != 0) {
                int length = c0710gArr.length;
                i5 = 0;
                int i7 = 0;
                while (true) {
                    if (i7 >= length) {
                        break;
                    }
                    int i8 = c0710gArr[i7].e;
                    if (i8 == 0) {
                        i7++;
                    } else if (i8 >= 0) {
                        i5 = i8;
                    }
                }
            }
            if (i5 != 0) {
                return new C0708e(i5);
            }
            Typeface typefaceJ = t.d.f6514a.j(context, c0710gArr, i4);
            if (typefaceJ == null) {
                return new C0708e(-3);
            }
            fVar.put(str, typefaceJ);
            return new C0708e(typefaceJ);
        } catch (PackageManager.NameNotFoundException unused) {
            return new C0708e(-1);
        }
    }
}
