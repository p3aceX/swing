package io.flutter.plugin.platform;

import android.app.AlertDialog;
import android.content.Context;
import android.content.ContextWrapper;

/* JADX INFO: loaded from: classes.dex */
public final class u extends ContextWrapper {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final D f4689a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public D f4690b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final Context f4691c;

    public u(Context context, D d5, Context context2) {
        super(context);
        this.f4689a = d5;
        this.f4691c = context2;
    }

    @Override // android.content.ContextWrapper, android.content.Context
    public final Object getSystemService(String str) {
        if (!"window".equals(str)) {
            return super.getSystemService(str);
        }
        StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
        for (int i4 = 0; i4 < stackTrace.length && i4 < 11; i4++) {
            if (stackTrace[i4].getClassName().equals(AlertDialog.class.getCanonicalName()) && stackTrace[i4].getMethodName().equals("<init>")) {
                return this.f4691c.getSystemService(str);
            }
        }
        if (this.f4690b == null) {
            this.f4690b = this.f4689a;
        }
        return this.f4690b;
    }
}
