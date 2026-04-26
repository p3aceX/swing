package b0;

import android.os.Trace;

/* JADX INFO: renamed from: b0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0242a {
    public static void a(int i4, String str) {
        Trace.beginAsyncSection(str, i4);
    }

    public static void b(int i4, String str) {
        Trace.endAsyncSection(str, i4);
    }

    public static boolean c() {
        return Trace.isEnabled();
    }
}
