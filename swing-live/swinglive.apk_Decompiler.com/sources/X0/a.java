package X0;

import R0.f;
import android.content.Context;
import android.preference.PreferenceManager;
import k.s0;

/* JADX INFO: loaded from: classes.dex */
public final class a {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final Object f2381b = new Object();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final f f2382a;

    public a(s0 s0Var) {
        Context context = (Context) s0Var.f5451a;
        String str = (String) s0Var.f5452b;
        String str2 = (String) s0Var.f5453c;
        if (str == null) {
            throw new IllegalArgumentException("keysetName cannot be null");
        }
        Context applicationContext = context.getApplicationContext();
        if (str2 == null) {
            PreferenceManager.getDefaultSharedPreferences(applicationContext).edit();
        } else {
            applicationContext.getSharedPreferences(str2, 0).edit();
        }
        this.f2382a = (f) s0Var.f5456g;
    }
}
