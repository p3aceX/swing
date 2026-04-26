package h3;

import android.os.SystemClock;

/* JADX INFO: renamed from: h3.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0415a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final long f4419a = SystemClock.elapsedRealtime();

    public final boolean a() {
        return SystemClock.elapsedRealtime() - this.f4419a > 3000;
    }
}
