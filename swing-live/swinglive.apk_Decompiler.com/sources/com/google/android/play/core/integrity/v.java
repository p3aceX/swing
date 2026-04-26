package com.google.android.play.core.integrity;

import android.content.Context;

/* JADX INFO: loaded from: classes.dex */
final class v {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    private static o f3719a;

    public static synchronized o a(Context context) {
        try {
            if (f3719a == null) {
                m mVar = new m(null);
                Context applicationContext = context.getApplicationContext();
                if (applicationContext != null) {
                    context = applicationContext;
                }
                mVar.a(context);
                f3719a = mVar.b();
            }
        } catch (Throwable th) {
            throw th;
        }
        return f3719a;
    }
}
