package com.google.android.gms.common.internal;

import android.content.Context;
import android.content.ServiceConnection;
import android.os.HandlerThread;
import java.util.concurrent.Executor;

/* JADX INFO: renamed from: com.google.android.gms.common.internal.l, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractC0289l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final Object f3582a = new Object();

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static P f3583b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static HandlerThread f3584c;

    public static P a(Context context) {
        synchronized (f3582a) {
            try {
                if (f3583b == null) {
                    f3583b = new P(context.getApplicationContext(), context.getMainLooper());
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        return f3583b;
    }

    public abstract void b(M m4, ServiceConnection serviceConnection);

    public abstract boolean c(M m4, ServiceConnection serviceConnection, String str, Executor executor);
}
