package z0;

import android.content.Intent;

/* JADX INFO: renamed from: z0.h, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0777h extends Exception {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Intent f6962a;

    public C0777h(int i4, Intent intent) {
        super("Google Play Services not available");
        this.f6962a = intent;
    }
}
